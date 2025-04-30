class AppointmentDTO {
  String id;
  String patientId;
  String doctorId;
  DateTime startTime;
  DateTime endTime;
  String status;           // pending, confirmed, completed, cancelled
  String? diagnosisSummary;
  String? prescriptionId;  // Link to prescription document
  String? prescriptionStatus; // Pending or issued
  String? notes;
  DateTime createdAt;

  AppointmentDTO({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.diagnosisSummary,
    this.prescriptionId,
    this.prescriptionStatus,
    this.notes,
    required this.createdAt,
  });

    Map<String, dynamic> toJson() => {
          'id': id,
          'patientId': patientId,
          'doctorId': doctorId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'status': status,
          'diagnosisSummary': diagnosisSummary,
          'prescriptionId': prescriptionId,
          'prescriptionStatus': prescriptionStatus,
          'notes': notes,
          'createdAt': createdAt.toIso8601String(),
        };

    factory AppointmentDTO.fromJson(Map<String, dynamic> json) => AppointmentDTO(
          id: json['id'],
          patientId: json['patientId'],
          doctorId: json['doctorId'],
          startTime: DateTime.parse(json['startTime']),
          endTime: DateTime.parse(json['endTime']),
          status: json['status'],
          diagnosisSummary: json['diagnosisSummary'],
          prescriptionId: json['prescriptionId'],
          prescriptionStatus: json['prescriptionStatus'],
          notes: json['notes'],
          createdAt: DateTime.parse(json['createdAt']),
        );
}

