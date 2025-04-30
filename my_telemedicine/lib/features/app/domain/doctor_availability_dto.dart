class DoctorAvailabilityDTO {
  String id; // documentId
  String doctorId; // UID of doctor
  DateTime startTime;
  DateTime endTime;
  String? appointmentId; // if booked, the appointmentId. Null otherwise

  DoctorAvailabilityDTO({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    this.appointmentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'appointmentId': appointmentId,
    };
  }

  factory DoctorAvailabilityDTO.fromJson(Map<String, dynamic> json) {
    return DoctorAvailabilityDTO(
      id: json['id'],
      doctorId: json['doctorId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      appointmentId: json['appointmentId'],
    );
  }
}