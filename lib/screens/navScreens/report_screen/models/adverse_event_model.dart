class AdverseEventReport {
  String? id;
  String patientName;
  int age;
  String gender;
  double weight;
  String medicineName;
  String manufacturer;
  String batchNumber;
  DateTime manufacturingDate;
  DateTime expiryDate;
  String placeOfPurchase;
  DateTime purchaseDate;
  String natureOfIssue;
  String description;
  DateTime incidentDate;
  List<String>? photoUrls;
  Map<String, dynamic> adrResponses;
  int adrScore;
  String causalityAssessment;
  DateTime reportDate;

  AdverseEventReport({
    this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.weight,
    required this.medicineName,
    required this.manufacturer,
    required this.batchNumber,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.placeOfPurchase,
    required this.purchaseDate,
    required this.natureOfIssue,
    required this.description,
    required this.incidentDate,
    this.photoUrls,
    required this.adrResponses,
    required this.adrScore,
    required this.causalityAssessment,
    required this.reportDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'age': age,
      'gender': gender,
      'weight': weight,
      'medicineName': medicineName,
      'manufacturer': manufacturer,
      'batchNumber': batchNumber,
      'manufacturingDate': manufacturingDate.millisecondsSinceEpoch,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'placeOfPurchase': placeOfPurchase,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'natureOfIssue': natureOfIssue,
      'description': description,
      'incidentDate': incidentDate.millisecondsSinceEpoch,
      'photoUrls': photoUrls ?? [],
      'adrResponses': adrResponses,
      'adrScore': adrScore,
      'causalityAssessment': causalityAssessment,
      'reportDate': reportDate.millisecondsSinceEpoch,
    };
  }

  factory AdverseEventReport.fromMap(Map<String, dynamic> map, String id) {
    return AdverseEventReport(
      id: id,
      patientName: map['patientName'],
      age: map['age'],
      gender: map['gender'],
      weight: map['weight'].toDouble(),
      medicineName: map['medicineName'],
      manufacturer: map['manufacturer'],
      batchNumber: map['batchNumber'],
      manufacturingDate: DateTime.fromMillisecondsSinceEpoch(map['manufacturingDate']),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      placeOfPurchase: map['placeOfPurchase'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchaseDate']),
      natureOfIssue: map['natureOfIssue'],
      description: map['description'],
      incidentDate: DateTime.fromMillisecondsSinceEpoch(map['incidentDate']),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      adrResponses: Map<String, dynamic>.from(map['adrResponses']),
      adrScore: map['adrScore'],
      causalityAssessment: map['causalityAssessment'],
      reportDate: DateTime.fromMillisecondsSinceEpoch(map['reportDate']),
    );
  }
}