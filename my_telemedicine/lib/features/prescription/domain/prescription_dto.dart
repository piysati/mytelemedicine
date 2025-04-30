class MedicineItem {
  String name;
  String dosage;
  String frequency;
  String duration; // e.g., 5 days

  MedicineItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
      };

  factory MedicineItem.fromJson(Map<String, dynamic> json) => MedicineItem(
        name: json['name'],
        dosage: json['dosage'],
        frequency: json['frequency'],
        duration: json['duration'],
      );
}

class PrescriptionDTO {
  String id;
  String patientId;
  String doctorId;
  String appointmentId;
  List<MedicineItem> medicines;
  String advice; // Doctor's notes
  DateTime issuedAt;
  List<String>? caregiverIds;

  PrescriptionDTO(
      {required this.id,
    required this.patientId,
    required this.doctorId,
    required this.medicines,
    required this.advice,
    required this.issuedAt,
    required this.appointmentId,
    this.caregiverIds
  });

  Map<String, dynamic> toJson() {
    return {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'medicines': medicines.map((item) => item.toJson()).toList(),
        'advice': advice,
        'issuedAt': issuedAt.toIso8601String(),
        'appointmentId': appointmentId,
        'caregiverIds': caregiverIds,
    };
  }

  factory PrescriptionDTO.fromJson(Map<String, dynamic> json) => PrescriptionDTO(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      medicines: (json['medicines'] as List).map((item) => MedicineItem.fromJson(item)).toList(),
      advice: json['advice'],
      issuedAt: DateTime.parse(json['issuedAt']),
      appointmentId: json['appointmentId'],
      caregiverIds: json['caregiverIds'] != null ? List<String>.from(json['caregiverIds']) : null,);
}