import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
import 'package:my_telemedicine/features/chat/domain/message_dto.dart';
import 'package:my_telemedicine/features/prescription/domain/prescription_dto.dart';

import '../../domain/user_dto.dart';

class FirebaseFirestoreService {
  Future<void> addUserToFirestore(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
  }

  Future<bool> isDoctorInMeeting(String doctorId, String appointmentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .get();

      if (doc.exists &&
          doc.data()?.containsKey('meetingId') == true &&
          doc.data()?['meetingId'] == appointmentId) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error getting doctor meeting: $e");
      return false;
    }
  }

  Future<void> addPrescription(PrescriptionDTO prescription) async {
    try {
      await FirebaseFirestore.instance.collection('prescriptions').add(prescription.toJson());
    } catch (e) {
      print("Error adding prescription: $e");
  }

  Future<void> updateCaregivers(String patientId, List<String> caregiverIds) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .update({'caregiverIds': caregiverIds});
    } catch (e) {
      print("Error updating caregiverIds: $e");
    }
  }

    Future<List<PrescriptionDTO>> getPrescriptionsByPatient(String patientId, String userId, String userRole) async {
    try {
      QuerySnapshot querySnapshot;
      if (userRole == 'Patient') {
        // If the user is a patient, get the prescriptions where the patientId is equal to the user id or the user id is in the caregiverIds of the prescription
        querySnapshot = await FirebaseFirestore.instance
            .collection('prescriptions')
            .where('patientId', whereIn: [userId])
            .get();
        
        final querySnapshot2 = await FirebaseFirestore.instance.collection('prescriptions').where('caregiverIds', arrayContains: userId).get();
        querySnapshot = QuerySnapshot(querySnapshot.docs + querySnapshot2.docs, querySnapshot.metadata);
      } else {
        // If the user is a doctor, get the prescriptions where the patientId is equal to the patientId received in the parameter
        querySnapshot = await FirebaseFirestore.instance
            .collection('prescriptions')
            .where('patientId', isEqualTo: patientId).get();
      }
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PrescriptionDTO.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error fetching prescriptions: $e");
      return [];
    }
  }


  Future<String> uploadPrescriptionPdf(
      String prescriptionId, String patientId, List<int> pdfBytes) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('prescriptions/$patientId/$prescriptionId.pdf');
      final uploadTask = storageRef.putData(pdfBytes);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading prescription PDF: $e");
      return "";
    }
  }

  Future<void> updatePrescriptionPdfUrl(
      String prescriptionId, String pdfUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('prescriptions')
          .doc(prescriptionId).update({'pdfUrl': pdfUrl});
    } catch (e) {
      print("Error updating prescription PDF URL: $e");

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

    Future<List<AppointmentDTO>> getDoctorAppointments(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add the document ID to the data
        data['id'] = doc.id;
        return AppointmentDTO.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error fetching doctor appointments: $e");
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
          
    Future<List<UserDTO>> getDoctorPatients(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();
      List<String> patientIds = querySnapshot.docs.map((doc) => doc.data() as Map<String,dynamic>)
          .map((data) => data['patientId'] as String)
          .toSet().toList();

      QuerySnapshot patientsSnapshot = await FirebaseFirestore.instance.collection('users')
        .where('uid', whereIn: patientIds).get();
       return patientsSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return UserDTO.fromJson(data);
        }).toList();
    } catch (e) {
      print("Error fetching doctor patients: $e");
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


