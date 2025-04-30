class PatientHistoryDTO {
  final String id;
  final String patientId;
  final List<String> pastDiseases;
  final List<String> allergies;
  final List<String> surgeries;
  final String? familyHistoryNotes;
  final List<String>? chronicDiseases;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PatientHistoryDTO({
    required this.id,
    required this.patientId,
    required this.pastDiseases,
    required this.allergies,
    required this.surgeries,
    this.familyHistoryNotes,
    this.chronicDiseases,
    required this.createdAt,
    this.updatedAt,
  });

  factory PatientHistoryDTO.fromJson(Map<String, dynamic> json) {
    return PatientHistoryDTO(
      id: json['id'],
      patientId: json['patientId'],
      pastDiseases: List<String>.from(json['pastDiseases']),
      allergies: List<String>.from(json['allergies']),
      surgeries: List<String>.from(json['surgeries']),
      familyHistoryNotes: json['familyHistoryNotes'],
      chronicDiseases: json['chronicDiseases'] != null ? List<String>.from(json['chronicDiseases']) : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'pastDiseases': pastDiseases,
      'allergies': allergies,
      'surgeries': surgeries,
      'familyHistoryNotes': familyHistoryNotes,
      'chronicDiseases': chronicDiseases,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}