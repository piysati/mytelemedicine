class DoctorDTO {
  final String uid;
  final String fullName;
  final String specialization;
  final String email;
  final String role;

  DoctorDTO({
    required this.uid,
    required this.fullName,
    required this.specialization,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'specialization': specialization,
      'email': email,
      'role': role,
    };
  }

  factory DoctorDTO.fromJson(Map<String, dynamic> json) {
    return DoctorDTO(
      uid: json['uid'] ?? '',
      fullName: json['fullName'] ?? '',
      specialization: json['specialization'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}