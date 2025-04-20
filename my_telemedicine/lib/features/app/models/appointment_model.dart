class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String date;
  final String time;
  final String reason;

  AppointmentModel({
    required this.id,
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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        id: json["id"],
        patientId: json["patientId"],
        doctorId: json["doctorId"],
        date: json["date"],
        time: json["time"],
        reason: json["reason"],
      );
}