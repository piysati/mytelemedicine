import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/app_export.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
import 'package:my_telemedicine/features/app/domain/user_dto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

/// Service to manage Firestore operations.
class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Adds a new user to Firestore.
  Future<void> addUser(UserDTO user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set(user.toJson());
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  /// Retrieves a user by their ID.
  Future<UserDTO> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.data() == null) throw Exception("User not found");

      return UserDTO.fromJson(userDoc.data()!);
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Adds a new appointment to Firestore.
  Future<String> addAppointment(AppointmentDTO appointment) async {
    try {
      final appointmentRef = _firestore.collection('appointments').doc();
      final appointmentId = appointmentRef.id;
      final newAppointment =
          appointment.copyWith(appointmentId: appointmentId);      
      await appointmentRef.set(newAppointment.toJson());
      // Create a chat for this new appointment.
      final patient = await getUserById(newAppointment.patientId);
      final doctor = await getUserById(newAppointment.doctorId);
      List<String> participants = [
        newAppointment.patientId,
        newAppointment.doctorId
      ];
      if (patient.uid != null && patient.uid!.isNotEmpty) {
        participants.add(patient.patientId!);
      }
      if (doctor.patientId != null && doctor.patientId!.isNotEmpty) {
        participants.add(doctor.patientId!);
      }

      await createChat(participants, appointmentId);

      return appointmentId;
    } catch (e) {
      throw Exception('Error adding appointment: $e');
    }
  }

  /// Retrieves a list of appointments for a specific doctor.
  Future<List<AppointmentDTO>> getAppointmentsForDoctor(
      String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();
      return snapshot.docs
          .map((doc) => AppointmentDTO.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error getting appointments for doctor: $e');
    }
  }

  /// Retrieves a list of appointments for a specific patient.
  Future<List<AppointmentDTO>> getAppointmentsForPatient(
      String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();
      return snapshot.docs
          .map((doc) => AppointmentDTO.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error getting appointments for patient: $e');
    }
  }

  /// Retrieves a list of upcoming appointments for a specific patient.
  Future<List<AppointmentDTO>> getUpcomingAppointmentsForPatient(
      String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();
      final allAppointments = snapshot.docs
          .map((doc) => AppointmentDTO.fromJson(doc.data()))
          .toList();
      final upcomingAppointments = allAppointments
          .where((element) => element.date.isAfter(DateTime.now()))
          .toList();
      return upcomingAppointments;
    } catch (e) {
      throw Exception('Error getting appointments for patient: $e');
    }
  }

  /// Retrieves an appointment by its ID.
  Future<AppointmentDTO> getAppointmentById(String appointmentId) async {
    try {
      final appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      return AppointmentDTO.fromJson(appointmentDoc.data()!);
    } catch (e) {
      throw Exception('Error getting appointment: $e');
    }
  }

  /// Deletes an appointment from Firestore.
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
    }
  }

  /// Adds a new doctor availability to Firestore.
  Future<void> addDoctorAvailability(
      DoctorAvailabilityDTO availability) async {
    try {
      await _firestore
          .collection('doctor_availability')
          .doc(_uuid.v4())
          .set(availability.toJson());
    } catch (e) {
      throw Exception('Error adding doctor availability: $e');
    }
  }

  /// Retrieves a list of doctor availabilities for a specific date.
  Future<List<DoctorAvailabilityDTO>> getDoctorAvailabilityByDate(
      String doctorId, DateTime date) async {
    try {
      final snapshot = await _firestore
          .collection('doctor_availability')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: date)
          .get();
      return snapshot.docs
          .map((doc) => DoctorAvailabilityDTO.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error getting doctor availability: $e');
    }
  }

  /// Adds a new prescription to Firestore.
  Future<void> addPrescription(PrescriptionDTO prescription,
      String appointmentId) async {
    try {
      final pdfBytes = generatePrescriptionPdf(prescription);
      final pdfUrl = await uploadPdfToStorage(
          pdfBytes, '${prescription.prescriptionId}.pdf');
      final updatedPrescription =
          prescription.copyWith(pdfUrl: pdfUrl, appointmentId: appointmentId);
      await _firestore
          .collection('prescriptions')
          .doc(updatedPrescription.prescriptionId)
          .set(updatedPrescription.toJson());
    } catch (e) {
      throw Exception('Error adding prescription: $e');
    }
  }

  /// Retrieves a list of prescriptions for a specific patient.
  Future<List<PrescriptionDTO>> getPrescriptionsForPatient(
      String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('prescriptions')
          .where('patientId', isEqualTo: patientId)
          .get();
      return snapshot.docs
          .map((doc) => PrescriptionDTO.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error getting prescriptions: $e');
    }
  }

  /// Retrieves a list of prescriptions for a specific patient given the id.
  Future<List<PrescriptionDTO>> getPrescriptionsForPatientById(
      String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('prescriptions')
          .where('patientId', isEqualTo: patientId)
          .get();
      return snapshot.docs
          .map((doc) => PrescriptionDTO.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error getting prescriptions: $e');
    }
  }

  /// Generates a PDF document for a given prescription.
  List<int> generatePrescriptionPdf(PrescriptionDTO prescription) {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Prescription ID: ${prescription.prescriptionId}'),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${prescription.date.toString()}'),
              pw.SizedBox(height: 20),
              pw.Text('Medications:'),
              pw.ListView.builder(
                itemCount: prescription.medications.length,
                itemBuilder: (context, index) {
                  return pw.Text('- ${prescription.medications[index]}');
                },
              ),
              pw.SizedBox(height: 20),
              pw.Text('Notes: ${prescription.notes}'),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  /// Uploads a PDF file to Firebase Storage.
  Future<String> uploadPdfToStorage(
      List<int> pdfBytes, String filename) async {
    try {
      final storageRef = _storage.ref().child('pdfs/$filename');
      final uploadTask = storageRef.putData(pdfBytes);
      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading PDF: $e');
    }
  }

  /// Downloads a PDF file from Firebase Storage.
  Future<List<int>> downloadPdf(String url) async {
    try {
      final storageRef = _storage.refFromURL(url);
      final file = await storageRef.getData();
      return file!.toList();
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }

  /// Creates a new chat in Firestore.
  Future<String> createChat(List<String> participants,
      [String? appointmentId]) async {
    try {
      final chatRef = _firestore.collection('chats').doc();
      await chatRef.set({
        'participants': participants,
        'appointmentId': appointmentId ?? "",
      });
      return chatRef.id;
    } catch (e) {
      throw Exception('Error creating chat: $e');
    }
  }

  /// Retrieves a list of chats for a specific user.
  Future<List<ChatDTO>> getChatsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();
      return snapshot.docs
          .map((doc) => ChatDTO.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error getting chats: $e');
    }
  }

  /// Retrieves a list of messages for a specific chat.
  Future<List<MessageDTO>> getMessagesForChat(String chatId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => MessageDTO.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error getting messages: $e');
    }
  }

  /// Sends a new message to a specific chat.
  Future<void> sendMessage(String chatId, MessageDTO message) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      final newMessage = message.copyWith(messageId: messageRef.id);
      await messageRef.set(newMessage.toJson());
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  ///Links a caregiver to a patient.
  Future<void> linkCaregiverToPatient(
      String patientId, String caregiverId) async {
    try {
      await _firestore.collection('users').doc(caregiverId).update({
        'patientId': patientId,
      });
    } catch (e) {
      throw Exception('Error linking caregiver: $e');
    }
  }

  ///Creates a test doctor and appointment.
  Future<void> createTestDoctorAndAppointment() async {
    try {
      final doctor = UserDTO(
        userId: "testDoctorId",
        email: "testdoctor@example.com",
        role: "Doctor",
        name: "Test Doctor",
      );
      await addUser(doctor);
      final patient = UserDTO(
        userId: "testPatientId",
        email: "testpatient@example.com",
        role: "Patient",
        name: "Test Patient",
      );
      await addUser(patient);
      final appointment = AppointmentDTO(
        appointmentId: "testAppointmentId",
        doctorId: "testDoctorId",
        patientId: "testPatientId",
        date: DateTime.now().add(const Duration(days: 1)),
        time: TimeOfDay.now(),
        reason: "Test appointment",
      );
      await addAppointment(appointment);
      final availability = DoctorAvailabilityDTO(
          doctorId: "testDoctorId",
          date: DateTime.now().add(const Duration(days: 1)),
          slots: [
            AvailabilitySlotDTO(
                startTime: const TimeOfDay(hour: 10, minute: 0),
                endTime: const TimeOfDay(hour: 11, minute: 0),
                isBooked: false)
          ]);
      await addDoctorAvailability(availability);
    } catch (e) {
      throw Exception('Error adding test data: $e');
    }
  }
}
