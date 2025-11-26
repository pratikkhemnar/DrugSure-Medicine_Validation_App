// lib/models/medicine_info.dart

class MedicineInfo {
  final String serialNumber;
  final String uniqueId;
  final String genericName;
  final String brandName;
  final String manufacturer;
  final String batchNumber;
  final String mfgDate;
  final String expiryDate;
  final String licenseNumber;
  final String authenticity;

  MedicineInfo({
    required this.serialNumber,
    required this.uniqueId,
    required this.genericName,
    required this.brandName,
    required this.manufacturer,
    required this.batchNumber,
    required this.mfgDate,
    required this.expiryDate,
    required this.licenseNumber,
    required this.authenticity,
  });
}
