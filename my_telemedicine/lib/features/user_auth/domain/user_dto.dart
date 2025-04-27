abstract class UserDTO {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;

  UserDTO(this.fullName, this.email, this.phoneNumber, this.role);

  Map<String, dynamic> toJson();

    // Factory constructor to be implemented by subclasses
  static UserDTO fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String;
    
    switch (role) {
      case 'Patient':
        return PatientDTO.fromJson(json);
      case 'Doctor':
        return DoctorDTO.fromJson(json);
      case 'Caretaker':
        return CaretakerDTO.fromJson(json);
      default:
        throw FormatException('Unknown role: $role');
    }
  }
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

    // Factory constructor for creating a PatientDTO from JSON
  factory PatientDTO.fromJson(Map<String, dynamic> json) {
    return PatientDTO(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      healthConditions: List<String>.from(json['healthConditions']),
      emergencyContact: json['emergencyContact'] as String,
      preferredLanguage: json['preferredLanguage'] as String,
    );
  }

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
    required String this.specialization,
    required this.experience,
    required this.affiliation,
    required this.licenseId,
    required this.availableTimings,
    required this.consultationFee,
  }) : super(fullName, email, phoneNumber, 'Doctor');

    // Factory constructor for creating a DoctorDTO from JSON
  factory DoctorDTO.fromJson(Map<String, dynamic> json) {
    return DoctorDTO(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      specialization: json['specialization'] as String,
      experience: json['experience'] as int,
      affiliation: json['affiliation'] as String,
      licenseId: json['licenseId'] as String,
      availableTimings: json['availableTimings'] as String,
      consultationFee: (json['consultationFee'] is int) 
          ? (json['consultationFee'] as int).toDouble() 
          : json['consultationFee'] as double,
    );
  }

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

    // Factory constructor for creating a CaretakerDTO from JSON
  factory CaretakerDTO.fromJson(Map<String, dynamic> json) {
    return CaretakerDTO(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      patientName: json['patientName'] as String,
      relationToPatient: json['relationToPatient'] as String,
      patientContact: json['patientContact'] as String,
      accessPermissions: json['accessPermissions'] as String,
    );
  }

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