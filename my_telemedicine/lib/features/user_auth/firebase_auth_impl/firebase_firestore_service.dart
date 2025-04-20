import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
import 'package:my_telemedicine/features/chat/domain/message_dto.dart';

import '../../domain/user_dto.dart';

class FirebaseFirestoreService {
  Future<void> addUserToFirestore(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
  }

  Future<void> addAppointment(AppointmentDTO appointmentDTO) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .add(appointmentDTO.toJson());
  }

  Future<List<DoctorDTO>> getDoctorsBySpecialization(String specialization) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Doctor')
          .where('specialization', isEqualTo: specialization)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return DoctorDTO.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error fetching doctors: $e");
      return [];
    }
  }

  Future<void> sendMessage(MessageDTO message) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Stream<List<MessageDTO>> getMessages(String appointmentId) {
    try {
      return FirebaseFirestore.instance
          .collection('messages')
          .where('appointmentId', isEqualTo: appointmentId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return MessageDTO.fromMap(doc.data());
          } catch (e) {
            print("Error parsing message: $e");
            return MessageDTO(
                messageId: "",
                senderId: "", receiverId: "", content: "Error", timestamp: Timestamp.now(), appointmentId: "");
          }
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }
}