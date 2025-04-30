import 'package:my_telemedicine/features/user_auth/domain/user_dto.dart';

class PatientDTO extends UserDTO {
  final int age;
  final String gender;
  final List<String> healthConditions;
  final String emergencyContact;
  final String preferredLanguage;

  PatientDTO({
    required super.name,
    required super.email,
    required super.phoneNumber,
    required this.age,
    required this.gender,
    required this.healthConditions,
    required this.emergencyContact,
    required this.preferredLanguage,
  });

  factory PatientDTO.fromJson(Map<String, dynamic> json) {
    return PatientDTO(
      name: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      emergencyContact: json['emergencyContact'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
        "role": role,
        "age": age,
        "gender": gender,
        "healthConditions": healthConditions,
        "emergencyContact": emergencyContact,
        "preferredLanguage": preferredLanguage,
      };
}