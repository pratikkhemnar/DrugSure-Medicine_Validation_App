// file: nearby_pharmacies_pro.dart
// Drop into lib/ and import where needed.
// IMPORTANT: replace googleApiKey with your real API key (Maps+Places+Directions enabled)

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


const String googleApiKey = 'AIzaSyCQcDBXxZd2nwUUIpVGZFR-lSQ-L54q5pQ'; // ← REPLACE

class NearbyPharmaciesPro extends StatefulWidget {
  @override
  _NearbyPharmaciesProState createState() => _NearbyPharmaciesProState();
}

class _NearbyPharmaciesProState extends State<NearbyPharmaciesPro> {
  GoogleMapController? _mapController;
  LatLng _initialCamera = const LatLng(18.5204, 73.8567); // Pune fallback
  LatLng? _currentLocation;
  bool _loading = true;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final PolylinePoints _polylinePoints = PolylinePoints();

  List<Place> _places = []; // master list
  List<Place> _filtered = [];

  // UI state
  String _search = '';
  bool _filterOpenNow = false;
  bool _filter24Hours = false;
  bool _filterRating4plus = false;
  bool _sortByDistance = true; // default
  Place? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
    await _fetchNearbyPlaces(radius: 3000);
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
      // keep default
    }
  }

  Future<void> _fetchNearbyPlaces({int radius = 2000}) async {
    if (_currentLocation == null) return;

    final loc = '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$loc&radius=$radius&type=pharmacy&key=$googleApiKey';

    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final results = data['results'] as List<dynamic>? ?? [];
        _places.clear();

        for (var r in results) {
          final geometry = r['geometry'];
          final lat = geometry['location']['lat'] + 0.0;
          final lng = geometry['location']['lng'] + 0.0;
          final placeId = r['place_id'] ?? '';
          final name = r['name'] ?? '';
          final vicinity = r['vicinity'] ?? '';
          final rating = (r['rating'] != null) ? (r['rating'] + 0.0) : 0.0;
          final userRatingsTotal = (r['user_ratings_total'] ?? 0);
          final opening = r['opening_hours']?['open_now'] == true;
          final photos = r['photos'] as List<dynamic>?;

          final photoRef =
          (photos != null && photos.isNotEmpty) ? photos[0]['photo_reference'] : null;

          final place = Place(
            placeId: placeId,
            name: name,
            address: vicinity,
            location: LatLng(lat, lng),
            rating: rating,
            userRatingsTotal: userRatingsTotal,
            isOpenNow: opening,
            is24Hours: false, // NearbySearch doesn't tell 24h reliably
            phone: '',
            photoReference: photoRef,
            distanceText: '',
          );

          _places.add(place);
        }

        // For richer data (phone, opening_hours, full photos) request Place Details for top N (to limit quota)
        await _fetchPlaceDetailsForTop(n: 10);
        _applyDistanceAndSort();
        _addMarkers();
        setState(() {});
      } else {
        debugPrint('Places nearby error: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Fetch nearby error: $e');
    }
  }

  // Fetch Place Details for first n places to get phone & precise opening hours & photos
  Future<void> _fetchPlaceDetailsForTop({int n = 5}) async {
    final count = _places.length < n ? _places.length : n;
    for (int i = 0; i < count; i++) {
      final p = _places[i];
      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=${p.placeId}&fields=name,formatted_phone_number,opening_hours,photos,formatted_address,utc_offset,rating,user_ratings_total,geometry&key=$googleApiKey';
      try {
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          final result = data['result'];
          if (result != null) {
            p.phone = result['formatted_phone_number'] ?? p.phone;
            if (result['opening_hours'] != null) {
              p.isOpenNow = result['opening_hours']['open_now'] == true;
              // There's no explicit 24h boolean — some places show weekday_text with 24 hours wording
              final weekdayText = result['opening_hours']['weekday_text'] as List<dynamic>?;
              if (weekdayText != null) {
                p.is24Hours = weekdayText.any((t) => t.toString().toLowerCase().contains('24 hours'));
              }
            }
            if (result['photos'] != null && result['photos'].isNotEmpty) {
              p.photoReference = result['photos'][0]['photo_reference'];
            }
            p.rating = (result['rating'] != null) ? (result['rating'] + 0.0) : p.rating;
            p.userRatingsTotal = result['user_ratings_total'] ?? p.userRatingsTotal;
            p.address = result['formatted_address'] ?? p.address;
          }
        }
      } catch (e) {
        debugPrint('Place details error: $e');
      }
      // small delay to avoid quota spikes
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  void _addMarkers() {
    _markers.clear();
    for (var p in _places) {
      _markers.add(Marker(
        markerId: MarkerId(p.placeId),
        position: p.location,
        infoWindow: InfoWindow(title: p.name, snippet: p.address),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            _selectedPlace == p ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueGreen),
        onTap: () => _onSelectPlace(p),
      ));
    }
    setState(() {});
  }

  void _onSelectPlace(Place p) {
    setState(() {
      _selectedPlace = p;
      _addMarkers();
    });
    _moveCamera(p.location, zoom: 16);
    _drawRouteTo(p);
  }

  Future<void> _moveCamera(LatLng target, {double zoom = 14}) async {
    if (_mapController == null) return;
    await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  void _applyDistanceAndSort() {
    if (_currentLocation == null) {
      _filtered = List.from(_places);
      return;
    }
    for (var p in _places) {
      final d = Geolocator.distanceBetween(_currentLocation!.latitude,
          _currentLocation!.longitude, p.location.latitude, p.location.longitude);
      p.distanceMeters = d;
      p.distanceText = d >= 1000 ? '${(d / 1000).toStringAsFixed(2)} km' : '${d.toStringAsFixed(0)} m';
    }

    // initial sort
    _places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    List<Place> temp = List.from(_places);

    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      temp = temp.where((p) => p.name.toLowerCase().contains(q) || p.address.toLowerCase().contains(q)).toList();
    }
    if (_filterOpenNow) temp = temp.where((p) => p.isOpenNow == true).toList();
    if (_filter24Hours) temp = temp.where((p) => p.is24Hours == true).toList();
    if (_filterRating4plus) temp = temp.where((p) => p.rating >= 4.0).toList();

    if (_sortByDistance) {
      temp.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    } else {
      temp.sort((b, a) => a.rating.compareTo(b.rating));
    }

    setState(() {
      _filtered = temp;
    });
  }

  /// Directions & polyline
  Future<void> _drawRouteTo(Place destination) async {
    if (_currentLocation == null) return;
    _polylines.clear();

    final origin = '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    final dest = '${destination.location.latitude},${destination.location.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&mode=driving&key=$googleApiKey';

    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final List<PointLatLng> result = _polylinePoints.decodePolyline(points);
          final List<LatLng> coords =
          result.map((e) => LatLng(e.latitude, e.longitude)).toList();

          final poly = Polyline(
            polylineId: const PolylineId('route'),
            points: coords,
            width: 6,
            color: Colors.blue,
          );
          _polylines.add(poly);
          // move camera to show both origin and destination (simple approach: center dest)
          await _moveCamera(destination.location, zoom: 14.5);
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

  String? _photoUrlFromRef(String? ref, {int maxWidth = 400}) {
    if (ref == null) return null;
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$ref&key=$googleApiKey';
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DrugSure — Nearby Pharmacies'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _fetchNearbyPlaces(radius: 3000);
              _applyDistanceAndSort();
              _addMarkers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null) _moveCamera(_currentLocation!, zoom: 15);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialCamera, zoom: 13.5),
              onMapCreated: (ctrl) {
                _mapController = ctrl;
                if (_currentLocation != null) {
                  _moveCamera(_currentLocation!, zoom: 14);
                }
              },
              markers: _markers,
              myLocationEnabled: true,
              polylines: _polylines,
              myLocationButtonEnabled: false,
            ),
          ),

          // Top search & filter overlay
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
                        hintText: 'Search pharmacies, e.g., Apollo',
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
                          label: const Text('Open Now'),
                          selected: _filterOpenNow,
                          onSelected: (v) {
                            setState(() {
                              _filterOpenNow = v;
                              _applyFiltersAndSearch();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
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
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Rating 4+'),
                          selected: _filterRating4plus,
                          onSelected: (v) {
                            setState(() {
                              _filterRating4plus = v;
                              _applyFiltersAndSearch();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(Icons.sort),
                          label: Text(_sortByDistance ? 'Sort: Distance' : 'Sort: Rating'),
                          onPressed: () {
                            setState(() {
                              _sortByDistance = !_sortByDistance;
                              _applyFiltersAndSearch();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(Icons.place),
                          label: const Text('Refresh Nearby'),
                          onPressed: () async {
                            await _fetchNearbyPlaces(radius: 3000);
                            _applyDistanceAndSort();
                            _addMarkers();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nearby refreshed')));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Draggable bottom sheet with list
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.12,
            maxChildSize: 0.78,
            builder: (context, scrollCtrl) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                          const Text('Pharmacies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Spacer(),
                          if (_currentLocation != null)
                            Text('${_places.length} found • ${_filtered.length} shown', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _filtered.isEmpty
                          ? const Center(child: Text('No pharmacies found'))
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
    final photoUrl = _photoUrlFromRef(p.photoReference);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isSelected ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? const Icon(Icons.local_pharmacy, color: Colors.teal) : null,
            ),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${p.rating.toStringAsFixed(1)} (${p.userRatingsTotal})'),
                    const SizedBox(width: 10),
                    Icon(p.isOpenNow ? Icons.check_circle : Icons.cancel, color: p.isOpenNow ? Colors.green : Colors.red, size: 16),
                    Text(p.isOpenNow ? ' Open' : ' Closed', style: TextStyle(color: p.isOpenNow ? Colors.green : Colors.red)),
                    const SizedBox(width: 10),
                    if (p.distanceText.isNotEmpty) Text(' • ${p.distanceText}'),
                  ],
                ),
              ],
            ),
            onTap: () {
              _onSelectPlace(p);
            },
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
                  label: const Text('Directions', style: TextStyle(color: Colors.teal)),
                ),
                TextButton.icon(
                  onPressed: () => _callPhone(p.phone),
                  icon: const Icon(Icons.call, color: Colors.teal),
                  label: Text(p.phone.isEmpty ? 'No phone' : 'Call', style: const TextStyle(color: Colors.teal)),
                ),
                TextButton.icon(
                  onPressed: () {
                    _moveCamera(p.location, zoom: 16);
                    setState(() {
                      _selectedPlace = p;
                      _addMarkers();
                    });
                    _drawRouteTo(p);
                  },
                  icon: const Icon(Icons.location_on, color: Colors.teal),
                  label: const Text('Center', style: TextStyle(color: Colors.teal)),
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
  double rating;
  int userRatingsTotal;
  bool isOpenNow;
  bool is24Hours;
  String phone;
  String? photoReference;
  double distanceMeters;
  String distanceText;

  Place({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
    required this.rating,
    required this.userRatingsTotal,
    required this.isOpenNow,
    required this.is24Hours,
    required this.phone,
    required this.photoReference,
    required this.distanceText,
  })  : distanceMeters = double.infinity;
}
