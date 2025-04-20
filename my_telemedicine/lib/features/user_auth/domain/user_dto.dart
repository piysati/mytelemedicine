abstract class UserDTO {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;

  UserDTO(this.fullName, this.email, this.phoneNumber, this.role);

  Map<String, dynamic> toJson();
}

class PatientDTO extends UserDTO {
  final int age;
  final String gender;
  final List<String> healthConditions;
  final String emergencyContact;
  final String preferredLanguage;

  PatientDTO({
    required String fullName,
    required String email,
    required String phoneNumber,
    required this.age,
    required this.gender,
    required this.healthConditions,
    required this.emergencyContact,
    required this.preferredLanguage,
  }) : super(fullName, email, phoneNumber, 'Patient');

  @override
  Map<String, dynamic> toJson() => {
        "fullName": fullName,
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

class DoctorDTO extends UserDTO {
  final String specialization;
  final int experience;
  final String affiliation;
  final String licenseId;
  final String availableTimings;
  final double consultationFee;

  DoctorDTO({
    required String fullName,
    required String email,
    required String phoneNumber,
    required this.specialization,
    required this.experience,
    required this.affiliation,
    required this.licenseId,
    required this.availableTimings,
    required this.consultationFee,
  }) : super(fullName, email, phoneNumber, 'Doctor');

  @override
  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "email": email,
        "phoneNumber": phoneNumber,
        "role": role,
        "specialization": specialization,
        "experience": experience,
        "affiliation": affiliation,
        "licenseId": licenseId,
        "availableTimings": availableTimings,
        "consultationFee": consultationFee,
      };
}

class CaretakerDTO extends UserDTO {
  final String patientName;
  final String relationToPatient;
  final String patientContact;
  final String accessPermissions;

  CaretakerDTO({
    required String fullName,
    required String email,
    required String phoneNumber,
    required this.patientName,
    required this.relationToPatient,
    required this.patientContact,
    required this.accessPermissions,
  }) : super(fullName, email, phoneNumber, 'Caretaker');

  @override
  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "email": email,
        "phoneNumber": phoneNumber,
        "role": role,
        "patientName": patientName,
        "relationToPatient": relationToPatient,
        "patientContact": patientContact,
        "accessPermissions": accessPermissions,
      };
}