class ChatRoomDTO {
  String id; // chatroomId = appointmentId
  String patientId;
  String doctorId;
  String appointmentId;
  String? lastMessage;

  ChatRoomDTO({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentId,
    this.lastMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'lastMessage': lastMessage,
    };
  }

  factory ChatRoomDTO.fromJson(Map<String, dynamic> json) {
    return ChatRoomDTO(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      appointmentId: json['appointmentId'],
      lastMessage: json['lastMessage'],
    );
  }
}