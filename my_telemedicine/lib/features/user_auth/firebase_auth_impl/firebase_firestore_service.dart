import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
import 'package:my_telemedicine/features/chat/domain/message_dto.dart';

import 'package:my_telemedicine/features/user_auth/domain/user_dto.dart';

class FirebaseFirestoreService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current authenticated user - Added for ChatPage compatibility
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // Added alias for sendMessage to support ChatPage
  Future<void> addMessage(MessageDTO message) async {
    return sendMessage(message);
  }


  Future<void> addUserToFirestore(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
  }

  Future<void> addAppointment(AppointmentDTO appointmentDTO) async {
     await FirebaseFirestore.instance.collection('appointments').add({
      'patientId': appointmentDTO.patientId,
      'doctorId': appointmentDTO.doctorId,
      'date': appointmentDTO.date,
      'time': appointmentDTO.time,
      'reason': appointmentDTO.reason,
    });
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

  Future<void> saveDoctorAvailabilitySlot(
      String doctorId, String date, String startTime, String endTime) async {
    try {
      // Create or get the doctor document
      final doctorDoc =
          FirebaseFirestore.instance.collection('doctors').doc(doctorId);

      // Set the profile document.
      await FirebaseFirestore.instance.collection('doctors').doc(doctorId).set({});

      // Create or get the availability document for the specific date
      final availabilityDoc = doctorDoc.collection('availability').doc(date);

      // Get the current data to add the new slot
      final currentAvailability = await availabilityDoc.get();

      List<Map<String, dynamic>> currentSlots = [];
      if(currentAvailability.exists && currentAvailability.data()?.containsKey('slots') == true){
         currentSlots = List<Map<String, dynamic>>.from(currentAvailability.data()?['slots']);
      }

      // Add the new slot
      currentSlots.add({
        'startTime': startTime,
        'endTime': endTime,
        'isBooked': false,
      });

      // Update the document with the new slots array
      await availabilityDoc.set({'slots': currentSlots});
    } catch (e) {
      print("Error saving doctor availability: $e");
    }
  }

   Future<List<Map<String, dynamic>>> getDoctorAvailabilityByDate(
      String doctorId, String date) async {
    try {
      final availabilityDoc = FirebaseFirestore.instance.collection('doctors').doc(doctorId).collection('availability').doc(date);
      final doc = await availabilityDoc.get();
      if (!doc.exists || doc.data()?.containsKey("slots") != true) return [];
       return List<Map<String, dynamic>>.from(doc.data()?['slots']);
    } catch (e) {
      print("Error fetching doctor availability: $e");
      return [];
    }
  }
  Future<bool> checkAppointmentOverlap(
      String doctorId, List<String> days, String startTime, String endTime) async {
    try {
      // Get appointments for the doctor
      QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      // Check each appointment for overlap
      for (var doc in appointmentsSnapshot.docs) {
        Map<String, dynamic> appointmentData = doc.data() as Map<String, dynamic>;

        // Check if any of the days overlap
        List<String> appointmentDays = [(appointmentData['date'] as String)];
        bool daysOverlap = days.any((day) => appointmentDays.contains(day));

        if (daysOverlap) {
          // Check if the time overlaps
          String appointmentTime = appointmentData['time']; //e.g 09:00 - 10:00
          List<String> appointmentTimeParts = appointmentTime.split(" - ");
          String appointmentStartTime = appointmentTimeParts[0];
          String appointmentEndTime = appointmentTimeParts[1];

          if (!(endTime.compareTo(appointmentStartTime) <= 0 ||
              startTime.compareTo(appointmentEndTime) >= 0)) {
            return true; // Overlap found
          }
        }
      }
      return false; // No overlap found
    } catch (e) {
      print("Error checking for appointment overlap: $e");
      return true; // Assume overlap to avoid booking conflicts in case of error
    }
  }
}