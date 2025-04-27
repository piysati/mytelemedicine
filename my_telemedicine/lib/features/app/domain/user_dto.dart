class UserDTO {
  String uid;
  String fullName;
  String email;
  String role;
  String? doctorId;
  String? specialization;
  List<String> caregiverIds;

  UserDTO({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.doctorId,
    this.specialization,
    required this.caregiverIds,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'role': role,
        'doctorId': doctorId,
        'specialization': specialization,
        'caregiverIds': caregiverIds,
      };

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
        uid: json['uid'],
        fullName: json['fullName'],
        email: json['email'],
        role: json['role'],
        doctorId: json['doctorId'],
        specialization: json['specialization'],
        caregiverIds: json['caregiverIds'] == null ? [] : List<String>.from(json['caregiverIds']),
      );
}