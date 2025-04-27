import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionDTO {
  String prescriptionId;
  String doctorId;
  String patientId;
  Timestamp date;
  List<String> medications;
  String notes;
  String pdfUrl;
  String appointmentId;

  PrescriptionDTO({
    required this.prescriptionId,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.medications,
    required this.notes,
    required this.pdfUrl,
    required this.appointmentId,
  });

  Map<String, dynamic> toJson() => {
        'prescriptionId': prescriptionId,
        'doctorId': doctorId,
        'patientId': patientId,
        'date': date,
        'medications': medications,
        'notes': notes,
        'pdfUrl': pdfUrl,
        'appointmentId': appointmentId,
      };

  factory PrescriptionDTO.fromJson(Map<String, dynamic> json) =>
      PrescriptionDTO(
        prescriptionId: json['prescriptionId'],
        doctorId: json['doctorId'],
        patientId: json['patientId'],
        date: json['date'],
        medications: List<String>.from(json['medications']),
        notes: json['notes'],
        pdfUrl: json['pdfUrl'],
        appointmentId: json['appointmentId'],
      );
}