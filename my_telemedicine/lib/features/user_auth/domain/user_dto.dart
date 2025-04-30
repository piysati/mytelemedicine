class UserDTO {
  String uid;              // Firebase UID
  String name;
  String email;
  String phoneNumber; 
  String role;             // patient, doctor, caregiver only role not //separate dtois
  String? specialization;  // Only for doctors
  double? rating;          // Only for doctors
  List<String>? caregiverFor;    // UIDs of patients (for caregiver role)
  String? patientId;
  String profilePictureUrl; 
  DateTime createdAt; 
  bool? isBlocked; 

  UserDTO({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.specialization,
    this.rating,
    this.caregiverFor,
    this.patientId,
    required this.profilePictureUrl,
    required this.createdAt,
    this.isBlocked
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      uid: json['uid'] as String,
      name: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      specialization: json['specialization'] as String?,
      rating: json['rating'] as double?,
      caregiverFor: json['caregiverFor'] == null ? null : List<String>.from(json['caregiverFor']),
      patientId: json['patientId'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isBlocked: json['isBlocked'] as bool?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'specialization': specialization,
      'rating': rating,
      'caregiverFor': caregiverFor,
      'patientId': patientId,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt,
      'isBlocked': isBlocked,
  };
  }
}