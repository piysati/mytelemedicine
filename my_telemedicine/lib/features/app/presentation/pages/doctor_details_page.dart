import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
import 'package:my_telemedicine/features/app/custom_widgets/custom_list_tile.dart';
import 'package:my_telemedicine/features/app/domain/doctor_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_auth_service.dart';
import 'package:my_telemedicine/features/user_auth/domain/prescription_dto.dart';
import 'package:my_telemedicine/features/user_auth/domain/user_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import 'package:my_telemedicine/features/chat/presentation/pages/chat_page.dart';
import 'package:my_telemedicine/features/app/presentation/pages/book_appointment_page.dart';
import 'package:my_telemedicine/features/video_call/meeting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorDetailsPage extends StatefulWidget {
  final DoctorDTO doctor;
  const DoctorDetailsPage({Key? key, required this.doctor}) : super(key: key);

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  List<Map<String, dynamic>> _availability = [];
  bool _isLoading = true;
  bool _isPrescriptionLoading = false;
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();
  List<AppointmentDTO> _appointments = [];
  List<AppointmentDTO> _upcomingAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();

    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final firestoreService = FirebaseFirestoreService();
      final availability = await firestoreService.getDoctorAvailabilityByDate(
          widget.doctor.uid,
          DateTime.now().toString().substring(0, 10));
      setState(() {
        _availability = availability;
      });
    } catch (e) {
      print('Error loading availability: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final firestoreService = FirebaseFirestoreService();
      final appointments = await firestoreService
          .getAppointmentsForPatientAndCaretaker(
              FirebaseAuth.instance.currentUser!.uid);
      final upcomingAppointments = await firestoreService
          .getUpcomingAppointmentsForPatient(
              FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        _appointments = appointments
            .where((element) => element.doctorId == widget.doctor.uid)
            .toList();
        _upcomingAppointments = upcomingAppointments
            .where((element) => element.doctorId == widget.doctor.uid)
            .toList();
      });
       if(_upcomingAppointments.isNotEmpty){
          ElevatedButton(
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MeetingScreen(appointmentId: _upcomingAppointments[0].id)),
                  );
              });
        }
    } catch (e) {
      print('Error loading doctor: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. ${widget.doctor.fullName}', style: Theme.of(context).textTheme.headlineSmall),
            Text('Specialty: ${widget.doctor.specialization}'),
            const SizedBox(height: 20),
            Text('Available Slots',
                style: Theme.of(context).textTheme.titleLarge),
            _isLoading

                ? const Center(child: CircularProgressIndicator())
                : Expanded(child: _buildAvailabilityList()),
            const SizedBox(height: 10),
            Text('My Appointments', style: Theme.of(context).textTheme.titleLarge,),
          _isLoading ? const Center(child: CircularProgressIndicator()) :
          Expanded(child: _buildAppointmentList()),
          const SizedBox(height: 20),
             if (_upcomingAppointments.isNotEmpty)
              ElevatedButton(
              onPressed: () async {
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MeetingScreen(appointmentId: _upcomingAppointments[0].id)),
                  );}, child: const Text("Start video call")),ElevatedButton(
                  context,
                 MaterialPageRoute(
                    builder: (context) => BookAppointmentPage(doctor: widget.doctor, previousAppointment: null),
                  ),
                );
              },
              child: const Text('Book Appointment'),
            ),
            const SizedBox(height: 20),
           ElevatedButton(
              onPressed: () async {
                final firestoreService = FirebaseFirestoreService();
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final chat =
                  await firestoreService.getChatByUserAndDoctor(user.uid, widget.doctor.uid);
                  String chatId = "";
                  if(chat.isEmpty){
                    chatId = await firestoreService.createChat([user.uid,widget.doctor.uid], "");
                  }else{
                    chatId = chat[0].id;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                            userId: user.uid, chatId: chatId)),
                  );

                }
              },
            ),
            const SizedBox(height: 20),
          Text('Create prescription', style: Theme.of(context).textTheme.titleLarge,),
            const SizedBox(height: 10),
             DropdownButtonFormField<AppointmentDTO>(
                    value: _appointments.isNotEmpty ? _appointments[0] : null,
                    items: _appointments.map((appointment) {
                      return DropdownMenuItem<AppointmentDTO>(
                        value: appointment,
                        child: Text("${appointment.date} - ${appointment.time}"),
                      );
                    }).toList(),
                    onChanged: (value) {

                    },
                  ),
             TextFormField(
                    controller: _medicationsController,
                    decoration: const InputDecoration(
                      labelText: 'Medications',
                    ),
                  ),
             TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
             ElevatedButton(onPressed: _addPrescription, child: const Text("Add prescription")),
            if(_isPrescriptionLoading) const Center(child: CircularProgressIndicator()),



          ]),
        ),
      ),



    );
  }

  Future<void> _addPrescription() async{

    setState(() {
      _isPrescriptionLoading = true;
    });

    try {
          final firestoreService = FirebaseFirestoreService();
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && _appointments.isNotEmpty) {
            final prescriptionDto = PrescriptionDTO(id: '', doctorId: widget.doctor.uid, patientId: user.uid, date: DateTime.now().toString(), medications: _medicationsController.text, notes: _notesController.text, appointmentId: _appointments[0].id);

            await firestoreService.addPrescription(prescriptionDto, prescriptionDto.appointmentId);

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Prescription added!')));
          }
    } catch (e) {

          final firestoreService = FirebaseFirestoreService();
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && _appointments.isNotEmpty) {
            final prescriptionDto = PrescriptionDTO(id: '', doctorId: widget.doctor.uid, patientId: user.uid, date: DateTime.now().toString(), medications: _medicationsController.text, notes: _notesController.text, appointmentId: _appointments[0].id);
            
            final pdf = await firestoreService.generatePrescriptionPdf(prescriptionDto);
            final url = await firestoreService.uploadPdfToStorage(pdf, "prescription_${DateTime.now()}.pdf");

            final newPrescriptionDto = PrescriptionDTO(id: '', doctorId: widget.doctor.uid, patientId: user.uid, date: DateTime.now().toString(), medications: _medicationsController.text, notes: _notesController.text, appointmentId: _appointments[0].id, pdfUrl: url);

            await firestoreService.addPrescription(newPrescriptionDto, newPrescriptionDto.appointmentId);


            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prescription added!')));
          }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving prescription: $e')));
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving prescription: $e')));
    }finally{
          setState(() {
            _isPrescriptionLoading = false;
          });

    }
  }
  Widget _buildAppointmentList() {
      if (_appointments.isEmpty) {
        return const Center(child: Text('No appointments found.'));
      }

      return ListView.builder(
          shrinkWrap: true,
          itemCount: _appointments.length,
          itemBuilder: (context, index) {
            final appointment = _appointments[index];
            return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomListTile(
                  title: "${appointment.time} - ${appointment.date}",
                  subtitle: "Reason: ${appointment.reason}",
                  trailing: [
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () async {
                        try {
                          final firestoreService = FirebaseFirestoreService();
                          await firestoreService.deleteAppointment(appointment.id);
                          setState(() {
                            _appointments.removeAt(index);
                          });
                        } catch (e) {
                          print('Error deleting appointment: $e');
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAppointmentPage(
                              doctor: widget.doctor,
                              previousAppointment: appointment,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ));
          });
    }


  Widget _buildAvailabilityList() {
    if (_availability.isEmpty) {
      return const Center(child: Text('No availability slots found.'));
    }

    return ListView.builder(
      itemCount: _availability.length,
      itemBuilder: (context, index) {
        final slot = _availability[index];
        return CustomListTile(
          title: "${slot['startTime']} - ${slot['endTime']}",
          subtitle: "",
          trailing: [],
        );


      },
      
    );
  }
}



class BookAppointmentPage extends StatefulWidget {
  final DoctorDTO doctor;
  final AppointmentDTO? previousAppointment;
  const BookAppointmentPage(
      {Key? key, required this.doctor, required this.previousAppointment})
      : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedDate == null) {
        // Handle the case where no date is selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date.')),
        );
        return;
      }
      if (_selectedTime == null) {
        // Handle the case where no time is selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time.')),
        );
        return;
      }

      final firestoreService = FirebaseFirestoreService();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final timeString =
            "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";
        final appointmentDto = AppointmentDTO(
            id: "",
            patientId: user.uid,
            doctorId: widget.doctor.uid,
            date: _selectedDate.toString().substring(0, 10),
            time: timeString,
            reason: _reasonController.text,
            patientName: "");
        await firestoreService.addAppointment(appointmentDto);
        final startTime = _selectedTime!.hour.toString().padLeft(2, '0') +
            ":" +
            _selectedTime!.minute.toString().padLeft(2, '0');
        final endTime = (_selectedTime!.hour + 1).toString().padLeft(2, '0') +
            ":" +
            _selectedTime!.minute.toString().padLeft(2, '0');
        await firestoreService.updateDoctorAvailabilitySlot(
            widget.doctor.uid,
            _selectedDate.toString().substring(0, 10),
            [{'startTime': startTime, 'endTime': endTime, 'isBooked': true}]);
            if(widget.previousAppointment != null){
                await firestoreService.deleteAppointment(widget.previousAppointment!.id);
            }

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment booked successfully! A notification has been sent to the doctor and the patient.')));

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking appointment: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment with ${widget.doctor.fullName}"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(_selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${_selectedDate.toString().substring(0, 10)}'),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text(_selectedTime == null
                        ? 'Select Time'
                        : 'Time: ${_selectedTime!.format(context)}'),
                  ),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Appointment',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _bookAppointment();
                    },
                    child: const Text('Book Appointment'),
                  ),
                ],
              ),
            ),
    );
  }
}