import 'package:cloud_firestore/cloud_firestore.dart';

class MessageDTO {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final Timestamp timestamp;
  final String appointmentId;

  MessageDTO({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.appointmentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'appointmentId': appointmentId,
    };
  }

  factory MessageDTO.fromMap(Map<String, dynamic> map) {
    return MessageDTO(
      messageId: map['messageId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      timestamp: map['timestamp'],
      appointmentId: map['appointmentId'],
    );
  }
}