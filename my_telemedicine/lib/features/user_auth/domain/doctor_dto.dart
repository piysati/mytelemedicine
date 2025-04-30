import 'package:my_telemedicine/features/user_auth/domain/user_dto.dart';

class DoctorDTO extends UserDTO {
  @override
  String? specialization;
  int? experience;
  String? affiliation;
  String? licenseId;
  String? availableTimings;
  double? consultationFee;

  DoctorDTO({
    required super.name,
    required super.email,
    required super.phoneNumber,
    this.specialization,
    this.experience,
    this.affiliation,
    this.licenseId,
    this.availableTimings,
    this.consultationFee,
  }) : super(role: 'Doctor');

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        "specialization": specialization,
        "experience": experience,
        "affiliation": affiliation,
        "licenseId": licenseId,
        "availableTimings": availableTimings,
        "consultationFee": consultationFee,
      };

  factory DoctorDTO.fromJson(Map<String, dynamic> json) {
    return DoctorDTO(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      specialization: json['specialization'] ?? '',
      experience: json['experience'] ?? 0,
      affiliation: json['affiliation'] ?? '',
      licenseId: json['licenseId'] ?? '',
      availableTimings: json['availableTimings'] ?? '',
      consultationFee: json['consultationFee'] != null ? json['consultationFee'].toDouble() : 0.0,
    );
  }
}