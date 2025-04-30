import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/doctor_dto.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_telemedicine/features/app/presentation/pages/doctor_details_page.dart';
import '../../../user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import 'package:my_telemedicine/features/user_auth/presentation/widget/form_container_widget.dart';


class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String? _selectedSpecialization;
  List<Map<String, dynamic>> _doctors = []; 
  Map<String, dynamic>? _selectedDoctor;
  Map<String, dynamic>? _selectedSlot;



  // Hardcoded specializations for now
  final List<String> _specializations = [
    "Cardiology",
    "Pediatrics",
    "Dermatology",
    "Oncology"
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2101));
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
    _reasonController.dispose();
    super.dispose();
  }

  @override
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                decoration: const InputDecoration(
                  labelText: "Specialization",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a specialization' : null,
              ),
                onChanged: (String? newValue) => setState(() => _selectedSpecialization = newValue),
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
              const SizedBox(height: 16),
              ElevatedButton(onPressed:() => _selectDate(context) , child: Text("Select Date :${_selectedDate.year.toString()}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}")),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _bookAppointment, child: const Text("Book Appointment"),),
              const SizedBox(height: 16),
              _doctors.isEmpty
                  ?  const Center(child: Text("No doctors found for the selected specialization"),)
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _doctors.length,
                        itemBuilder: (context, index) {
                          final doctorAvailability = _doctors[index];
                          final doctor = doctorAvailability["doctor"] as DoctorDTO;
                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text("Dr. ${doctor.fullName}"),
                                ),
                                ...doctorAvailability["slots"].map<Widget>((slot) {
                                  final isSelected = _selectedSlot == slot && _selectedDoctor == doctor;
                                  return Card(
                                    color: isSelected ? Colors.blue[100] : null,
                                    child: ListTile(
                                      onTap: () => setState(() {
                                        _selectedSlot = slot;
                                        _selectedDoctor = doctor;
                                      }),
                                      title: Text(slot["isBooked"]
                                          ? "BOOKED"
                                          : "${slot["startTime"]} - ${slot["endTime"]}"),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                   if (_selectedSpecialization != null && _doctors.isEmpty) ...[
                    const Center(
                        child: Text(
                            "No doctors available for this specialization in this date")),
                  ] else if (_selectedSpecialization == null) ...[
                    const Center(
                      child: Text(
                        "Select a specialization to see available doctors",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ] else if (_doctors.isNotEmpty)...[
                     const SizedBox(height: 20),]
              ),
          ],
            ],
          ),
        ),
    );
  }

  void _bookAppointment() async {
     if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a time slot")));
          return;
    }
     if (_selectedSlot!["isBooked"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This time slot is already booked")));
      return;
    }
        if (_selectedDoctor == null) {
          
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select a doctor first")));
      return;
    }
     try {
      if (_formKey.currentState!.validate()) {
        final user = FirebaseAuth.instance.currentUser;
         if (user == null) {

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User not logged in")),
          );
          return;
        }
        final firestoreService = FirebaseFirestoreService();
        final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
        final appointmentDto = AppointmentDTO(
          patientId: user.uid,
          doctorId: (_selectedDoctor!["doctor"] as DoctorDTO).uid,
          date: dateString,
          time: "${_selectedSlot!['startTime']} - ${_selectedSlot!['endTime']}",
          reason: _reasonController.text,
        );
        await firestoreService.updateDoctorAvailabilitySlot((_selectedDoctor!["doctor"] as DoctorDTO).uid,dateString,[_selectedSlot!]);
        await firestoreService.addAppointment(appointmentDto);
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('appointments').where('doctorId', isEqualTo: appointmentDto.doctorId).where('patientId', isEqualTo: appointmentDto.patientId).where('date', isEqualTo: appointmentDto.date).where('time', isEqualTo: appointmentDto.time)
            .get();
        final appointmentId = querySnapshot.docs.first.id;        

        _showConfirmationDialog(appointmentId);
      }
    } catch (e) {
      print("Error booking appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error booking appointment: $e")),
           );
      } finally{
        Navigator.of(context).pop();
      }
    }
  }

  void _showConfirmationDialog(String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Booked'),
          content: const Text('Your appointment has been booked successfully. A notification has been sent to the doctor and the patient.'),
          actions: [
              TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      );
    }

   Future<void> _allocateDoctor(String? specialization) async {
       setState(() {
      _doctors = [];
    });
    try {

      setState(() { });
      final firestoreService = FirebaseFirestoreService();
      if (specialization == null || specialization.isEmpty) {
        return;
      }
      final List<DoctorDTO> doctors =
          await firestoreService.getDoctorsBySpecialization(specialization);
      if (doctors.isEmpty) {
        return;
      }
      final String dateString =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      List<Map<String, dynamic>> allDoctorsWithAvailability = [];
       for (var doctor in doctors) {
        final List<Map<String, dynamic>> doctorAvailability =
            await firestoreService.getDoctorAvailabilityByDate(
                doctor.uid, dateString);
        allDoctorsWithAvailability.add({"doctor": doctor,"slots": doctorAvailability});
      }
      setState(() => _doctors = allDoctorsWithAvailability);
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error allocating doctor: $e");
      }
    } finally {
      setState(() { });
    }
  }
