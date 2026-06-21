// file: nearby_pharmacies_pro.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NearbyPharmaciesPro extends StatefulWidget {
  @override
  _NearbyPharmaciesProState createState() => _NearbyPharmaciesProState();
}

class _NearbyPharmaciesProState extends State<NearbyPharmaciesPro> {
  final MapController _mapController = MapController();
  LatLng _initialCamera = const LatLng(18.5204, 73.8567); // Pune fallback
  LatLng? _currentLocation;
  bool _loading = true;
  String _errorMessage = '';

  List<Marker> _markers = [];
  List<Polyline> _polylines = [];

  List<Place> _places = []; // master list
  List<Place> _filtered = [];

  // UI state
  String _search = '';
  bool _filter24Hours = false;
  Place? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
    // Defaulting to 5km to catch more local shops
    await _fetchNearbyPlaces(radius: 5000);
    _applyDistanceAndSort();
    _addMarkers();
    setState(() => _loading = false);
  }

  Future<void> _requestLocationPermission() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position p = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      _currentLocation = LatLng(p.latitude, p.longitude);
      _initialCamera = _currentLocation!;
    } catch (e) {
      debugPrint("Could not get current location: $e");
    }
  }

  // 100% FREE API: Overpass API (OpenStreetMap Data)
  Future<void> _fetchNearbyPlaces({int radius = 5000}) async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    final targetLoc = _currentLocation ?? _initialCamera;

    // Expanded query to find both 'pharmacy' and 'chemist' within the radius
    final query = '''
      [out:json][timeout:15];
      (
        node["amenity"="pharmacy"](around:$radius,${targetLoc.latitude},${targetLoc.longitude});
        way["amenity"="pharmacy"](around:$radius,${targetLoc.latitude},${targetLoc.longitude});
        node["shop"="chemist"](around:$radius,${targetLoc.latitude},${targetLoc.longitude});
        way["shop"="chemist"](around:$radius,${targetLoc.latitude},${targetLoc.longitude});
      );
      out center;
    ''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');

    try {
      // Required headers to bypass the 406 Error
      final resp = await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'DrugSureApp/1.0 (Pratik)',
          },
          body: {'data': query}
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final elements = data['elements'] as List<dynamic>? ?? [];
        _places.clear();

        for (var el in elements) {
          final lat = el['lat'] ?? el['center']?['lat'];
          final lon = el['lon'] ?? el['center']?['lon'];
          if (lat == null || lon == null) continue;

          final tags = el['tags'] ?? {};
          final name = tags['name'] ?? 'Medical Shop (Unnamed)';

          List<String> addrParts = [];
          if (tags['addr:street'] != null) addrParts.add(tags['addr:street']);
          if (tags['addr:city'] != null) addrParts.add(tags['addr:city']);
          final address = addrParts.isNotEmpty ? addrParts.join(', ') : 'Local Pharmacy';

          final phone = tags['phone'] ?? tags['contact:phone'] ?? '';
          final openingHours = tags['opening_hours'] ?? '';

          final is24 = openingHours.toLowerCase().contains('24/7');

          final place = Place(
            placeId: el['id'].toString(),
            name: name,
            address: address,
            location: LatLng(lat, lon),
            isOpenNow: true,
            is24Hours: is24,
            phone: phone,
            distanceText: '',
          );

          _places.add(place);
        }

        _applyDistanceAndSort();
        _addMarkers();
      } else {
        setState(() => _errorMessage = 'OSM API Error: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network Error: Check internet connection');
    }

    setState(() => _loading = false);
  }

  void _addMarkers() {
    _markers.clear();

    // Add User Location Marker
    if (_currentLocation != null) {
      _markers.add(Marker(
        point: _currentLocation!,
        width: 40,
        height: 40,
        child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
      ));
    }

    // Add Pharmacy Markers
    for (var p in _filtered) {
      final isSelected = _selectedPlace == p;
      _markers.add(Marker(
        point: p.location,
        width: isSelected ? 50 : 40,
        height: isSelected ? 50 : 40,
        child: GestureDetector(
          onTap: () => _onSelectPlace(p),
          child: Icon(
            Icons.local_pharmacy,
            color: isSelected ? Colors.red : Colors.teal,
            size: isSelected ? 40 : 32,
          ),
        ),
      ));
    }
    setState(() {});
  }

  void _onSelectPlace(Place p) {
    setState(() {
      _selectedPlace = p;
      _addMarkers();
    });
    _mapController.move(p.location, 15.5); // Zoom slightly when tapped
    _drawRouteTo(p);
  }

  void _applyDistanceAndSort() {
    final targetLoc = _currentLocation ?? _initialCamera;

    for (var p in _places) {
      final d = Geolocator.distanceBetween(
          targetLoc.latitude, targetLoc.longitude,
          p.location.latitude, p.location.longitude);
      p.distanceMeters = d;
      p.distanceText = d >= 1000 ? '${(d / 1000).toStringAsFixed(2)} km' : '${d.toStringAsFixed(0)} m';
    }

    _places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    List<Place> temp = List.from(_places);

    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      temp = temp.where((p) => p.name.toLowerCase().contains(q) || p.address.toLowerCase().contains(q)).toList();
    }
    if (_filter24Hours) temp = temp.where((p) => p.is24Hours == true).toList();

    setState(() {
      _filtered = temp;
      _addMarkers();
    });
  }

  // 100% FREE API: OSRM (Open Source Routing Machine)
  Future<void> _drawRouteTo(Place destination) async {
    final startLoc = _currentLocation ?? _initialCamera;
    _polylines.clear();

    // OSRM requires coordinates in longitude,latitude order
    final startUrl = '${startLoc.longitude},${startLoc.latitude}';
    final destUrl = '${destination.location.longitude},${destination.location.latitude}';

    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$startUrl;$destUrl?overview=full&geometries=geojson');

    try {
      // Added User-Agent header here to prevent blocking
      final resp = await http.get(
          url,
          headers: {
            'User-Agent': 'DrugSureApp/1.0 (Pratik)',
          }
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List<dynamic>;

          List<LatLng> routePoints = coordinates.map((coord) {
            return LatLng(coord[1] as double, coord[0] as double);
          }).toList();

          _polylines.add(Polyline(
            points: routePoints,
            strokeWidth: 5.0,
            color: Colors.blueAccent,
          ));
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
    }
    setState(() {});
  }

  Future<void> _openMapsExternal(Place p) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${p.location.latitude},${p.location.longitude}&travelmode=driving');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  Future<void> _callPhone(String phone) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number not available')));
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not place call')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DrugSure — Nearby Pharmacies'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchNearbyPlaces(radius: 5000),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              final target = _currentLocation ?? _initialCamera;
              _mapController.move(target, 15.0);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCamera,
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.drugsure', // Replace with your app package
                ),
                PolylineLayer(polylines: _polylines),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Filter by name...',
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _search = '';
                              _applyFiltersAndSearch();
                            });
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _search = v;
                          _applyFiltersAndSearch();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('24 Hours'),
                          selected: _filter24Hours,
                          onSelected: (v) {
                            setState(() {
                              _filter24Hours = v;
                              _applyFiltersAndSearch();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.12,
            maxChildSize: 0.78,
            builder: (context, scrollCtrl) {
              return Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          const Text('Pharmacies (OpenStreetMap)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Spacer(),
                          Text('${_places.length} found', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                          : _filtered.isEmpty && _errorMessage.isEmpty
                          ? const Center(child: Text('No mapped shops nearby. Try zooming out.'))
                          : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final p = _filtered[i];
                          return _buildPlaceCard(p);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place p) {
    final isSelected = _selectedPlace == p;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isSelected ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? const BorderSide(color: Colors.teal, width: 2) : BorderSide.none,
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.teal[50],
              child: const Icon(Icons.local_pharmacy, color: Colors.teal),
            ),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(p.is24Hours ? Icons.check_circle : Icons.info_outline, color: p.is24Hours ? Colors.green : Colors.grey, size: 16),
                    Text(p.is24Hours ? ' 24/7' : ' Hours vary', style: TextStyle(color: p.is24Hours ? Colors.green : Colors.grey)),
                    const SizedBox(width: 10),
                    if (p.distanceText.isNotEmpty) Text(' • ${p.distanceText}'),
                  ],
                ),
              ],
            ),
            onTap: () => _onSelectPlace(p),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _openMapsExternal(p),
                  icon: const Icon(Icons.directions, color: Colors.teal),
                  label: const Text('Open in App', style: TextStyle(color: Colors.teal)),
                ),
                TextButton.icon(
                  onPressed: p.phone.isEmpty ? null : () => _callPhone(p.phone),
                  icon: Icon(Icons.call, color: p.phone.isEmpty ? Colors.grey : Colors.teal),
                  label: Text(p.phone.isEmpty ? 'No phone' : 'Call', style: TextStyle(color: p.phone.isEmpty ? Colors.grey : Colors.teal)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Data model ----
class Place {
  final String placeId;
  String name;
  String address;
  LatLng location;
  bool isOpenNow;
  bool is24Hours;
  String phone;
  double distanceMeters;
  String distanceText;

  Place({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
    required this.isOpenNow,
    required this.is24Hours,
    required this.phone,
    required this.distanceText,
  })  : distanceMeters = double.infinity;
}