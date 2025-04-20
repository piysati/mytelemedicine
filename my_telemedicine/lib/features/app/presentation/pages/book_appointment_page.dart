import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
// import 'package:my_telemedicine/features/app/models/appointment_model.dart';

import 'package:my_telemedicine/features/user_auth/presentation/widget/form_container_widget.dart';
import '../../../user_auth/firebase_auth_impl/firebase_firestore_service.dart';


class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({Key? key}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FormContainerWidget(
                controller: _dateController,
                hintText: "Date (YYYY-MM-DD)",
                isPasswordField: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a date";
                  }
                  // Basic date format validation
                  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                    return "Please enter a valid date (YYYY-MM-DD)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FormContainerWidget(
                controller: _timeController,
                hintText: "Time (HH:MM)",
                isPasswordField: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a time";
                  }
                  // Basic time format validation
                  if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                    return "Please enter a valid time (HH:MM)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FormContainerWidget(
                controller: _reasonController,
                hintText: "Reason for Appointment",
                isPasswordField: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a reason";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text("Book Appointment"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bookAppointment() async {
    try {
      if (_formKey.currentState!.validate()) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not logged in")),
          );
          return;
        }

        final appointmentDto = AppointmentDTO(
          patientId: user.uid,
          doctorId: await _allocateDoctor(), // Replace with actual doctor selection logic
          date: _dateController.text,
          time: _timeController.text,
          reason: _reasonController.text,
        );
        await FirebaseFirestoreService().addAppointment(appointmentDto);

        _showConfirmationDialog();
      }
    } catch (e) {
      print("Error booking appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error booking appointment: $e")),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Appointment Booked"),
          content: const Text("Your appointment has been booked successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<String> _allocateDoctor() async {
    try {
      final firestoreService = FirebaseFirestoreService();
      // Assuming you have a way to determine the required specialty
      // For now, we'll just fetch all doctors and select one randomly
      final doctors = await firestoreService.getDoctorsBySpecialization("Cardiology");

      if (doctors.isEmpty) {
        // Handle case where no doctors are available for the given specialty
        if (kDebugMode) {
          print("No doctors available for the given specialty");
        }
        return ""; // Or throw an exception, or return a default doctor ID
      }

      //For now, we are selecting doctor randomly, you can add other logic like
      // availability, ratings etc.
      final random = DateTime.now().microsecondsSinceEpoch % doctors.length;
      final selectedDoctor = doctors[random];
      if (kDebugMode) {
        print("Selected doctor: ${selectedDoctor.fullName}");
      }
      return selectedDoctor.uid;
    } catch (e) {
      // Handle errors, e.g., no doctors found, Firestore error
      if (kDebugMode) {
        print("Error allocating doctor: $e");
      }
      // You might want to show an error message to the user
      // and/or return a default doctor ID or throw an exception
      return ""; // Or throw an exception, or return a default doctor ID
    }
  }
}








