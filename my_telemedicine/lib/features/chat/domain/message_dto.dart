class MessageDTO {
  String id;
  String chatRoomId;
  String senderId;
  String receiverId;
  String message;
  DateTime sentAt;
  String? fileUrl; // For file sharing
  String messageType; // text, image, pdf, file
  bool isRead;

  MessageDTO({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.sentAt,
    this.fileUrl,
    required this.messageType,
    required this.isRead,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'fileUrl': fileUrl,
      'messageType': messageType,
      'isRead': isRead,
    };
  }

  factory MessageDTO.fromJson(Map<String, dynamic> map) {
    return MessageDTO(
      id: map['id'],
      chatRoomId: map['chatRoomId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      sentAt: DateTime.parse(map['sentAt']),
      fileUrl: map['fileUrl'],
      messageType: map['messageType'],
      isRead: map['isRead'],
    );
  }
}