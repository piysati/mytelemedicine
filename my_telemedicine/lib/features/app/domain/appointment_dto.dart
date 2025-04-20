class AppointmentDTO {
  final String id;
  final String patientId;
  final String doctorId;
  final String date;
  final String time;
  final String reason;

  AppointmentDTO({
    this.id = '',
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.time,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "patientId": patientId,
        "doctorId": doctorId,
        "date": date,
        "time": time,
        "reason": reason,
      };
}