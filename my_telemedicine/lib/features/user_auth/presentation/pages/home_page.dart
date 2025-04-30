import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
import 'package:my_telemedicine/features/app/presentation/pages/pdf_viewer_page.dart';
import 'package:my_telemedicine/features/app/domain/prescription_dto.dart';
import 'package:my_telemedicine/features/app/presentation/pages/link_caregiver_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_telemedicine/features/user_auth/domain/user_dto.dart';
import 'package:my_telemedicine/features/app/presentation/pages/search_doctors_page.dart';
import 'package:my_telemedicine/features/app/presentation/pages/manage_availability_page.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  
Widget build(BuildContext context) {
  if (_isLoading) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  if (_user == null) {
    return Scaffold(body: Center(child: Text("User not found")));
  } else {
    return _role == 'Doctor'
        ? _buildDoctorHomePage()
        : buildPatientCaregiverHomePage();
  }
}
}

  State<HomePage> createState() => _HomePageState();
}

class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> trailing;

  const CustomListTile(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.trailing})
      : super(key: key);

  class _HomePageState extends State<HomePage> {
  String _role = "";
  String _name = "";
  bool _isLoading = true;
  User? _user;
  List<AppointmentDTO> _appointments = [];
  DateTime _focusedDay = DateTime.now();
  List<AppointmentDTO> _upcomingAppointments = [];
  List<AppointmentDTO> _previousAppointments = [];
  DateTime _selectedDay = DateTime.now();
  String? _patientId;

  List<UserDTO> _patients = [];
  List<PrescriptionDTO> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _fetchUserData() async {
    try {
      if (_user != null) {
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
        if (_user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .get();
          if (userDoc.exists) {
            Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
            if (data != null && data.containsKey('role')) {
              _role = (data?['role'] ?? "") as String;
            } else {
              _role = "user";
            }
            if (data.containsKey('patientId')) {
              _patientId = data?['patientId'] ?? "";
            }
            _name = (data?['fullName'] ?? "") as String;
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {});
      // Consider showing an error message to the user
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    if (_role == "Doctor") {
      await _loadDoctorData();
    } else {
      await _loadPatientAndCaretakerData();
    }
  }

  Widget _buildDoctorHomePage() {
    return Scaffold(
        appBar: AppBar(title: const Text("Home Page")),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, Dr. ${_name ?? 'Doctor'}",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 20),
            Text("My Patients",
                style: Theme.of(context).textTheme.titleMedium),
            _patients.isEmpty ? buildNoData() : _buildPatientList(),
            const SizedBox(height: 20),
            Text("Upcoming Appointments",
                style: Theme.of(context).textTheme.titleMedium),
            _appointments.isEmpty
                ? buildNoData()
                : _buildAppointmentList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageAvailabilityPage()),
                );
              },
              child: const Text("Manage Availability"),
            ),
          ],
        )));
  }

  Future<void> _loadDoctorData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_user == null) return;

      if (_user != null) {
        final firestoreService = FirebaseFirestoreService();
        final appointments = await firestoreService.getDoctorAppointments(_user!.uid);
        final patients = await firestoreService.getDoctorPatients(_user!.uid);
        final upcomingAppointments = await firestoreService.getUpcomingAppointmentsForPatient(_user!.uid);


        setState(() {
          _appointments = appointments;
          _patients = patients;
          _upcomingAppointments = upcomingAppointments;
        });
      }
    } catch (e) {


      print('Error loading doctor data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPatientAndCaretakerData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final firestoreService = FirebaseFirestoreService();
      if (_role == "Caretaker" && _patientId != null) {
        _upcomingAppointments = await firestoreService.getUpcomingAppointmentsForPatient(_patientId!);
        _previousAppointments = await firestoreService.getAppointmentsForPatient(_patientId!);
        _prescriptions = await firestoreService.getPrescriptionsForPatientById(_patientId!);
      } else {

        _upcomingAppointments = await firestoreService.getUpcomingAppointmentsForPatient(_user!.uid);
        _previousAppointments = await firestoreService.getAppointmentsForPatientAndCaretaker(_user!.uid);

        _prescriptions = await firestoreService.getPrescriptionsForPatient(_user!.uid);
      }
    } catch (e) {
      print('Error loading patient/caretaker data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPatientList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _patients.length,
      itemBuilder: (context, index) {
      final patient = _patients[index];
      return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: CustomListTile(
            title: patient.name,
            subtitle: "",
            trailing: const [
              Icon(Icons.person),
              // View Profile

              Icon(Icons.notes),
              // Add Notes
            ],
          ),
      );
      },
    );
  }

  Widget _buildAppointmentList(List<AppointmentDTO> appointments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: CustomListTile(
            title:
                "${appointments[index].time} - ${appointments[index].patientName}",
            subtitle: "Reason: ${appointments[index].reason}",
            trailing: const [
              Icon(Icons.check),
              // Accept
            ],
          ),
        );
      },
    );
  }
    Widget _buildAppointmentListForDoctor(List<AppointmentDTO> appointments) {
    return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: appointments.length, itemBuilder: (context, index) {
      return Card(margin: const EdgeInsets.symmetric(vertical: 8.0), child: CustomListTile(
        title: "${appointments[index].time} - ${appointments[index].patientName}",
        subtitle: "Reason: ${appointments[index].reason}",
        trailing: const [
           Icon(Icons.check),
           // Accept

          Icon(Icons.close),
          // Reject
        ],
      ),
      );
    },
    );
  }

  Widget _buildPrescriptionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = _prescriptions[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: GestureDetector(
              onTap: () async {
                final pdfBytes = await FirebaseFirestoreService()
                    .downloadPdf(prescription.pdfUrl!);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PdfViewerPage(pdfBytes: pdfBytes)));
              },
              child: CustomListTile(
                title: "Prescription id: ${prescription.prescriptionId}",
                subtitle:
                    "Medications: ${prescription.medications} , Date: ${prescription.date}",
                trailing: [
                  IconButton(
                      onPressed: () {
                        FirebaseFirestoreService()
                            .downloadPdf(prescription.pdfUrl!);
                      },
                      icon: const Icon(Icons.remove_red_eye)), // View Profile
                ],
              )),
        );

      },
    );
  }

  Widget buildPatientCaregiverHomePage() {
    if (_role == "Patient" || _role == "Caretaker") {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Welcome, ${_name ?? 'User'}", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Text("Upcoming", style: Theme.of(context).textTheme.titleMedium),
            _upcomingAppointments.isEmpty ? buildNoData() : _buildAppointmentList(_upcomingAppointments),
            const SizedBox(height: 20),
            Text("Upcoming Appointments", style: Theme.of(context).textTheme.titleMedium),
            _previousAppointments.isEmpty ? buildNoData() : _buildAppointmentList(_previousAppointments),
            const SizedBox(height: 20),
            Text("My Prescriptions", style: Theme.of(context).textTheme.titleMedium),
            _prescriptions.isEmpty ? buildNoData() : _buildPrescriptionList(),
            if (_role == "Patient")
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LinkCaregiverPage()),
                  );
                },
                child: const Text("Link Caregiver"),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchDoctorsPage()));
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchDoctorsPage()));
              },
              child: const Text("Search Doctors"),
            ),
      ),
    );
  }

  // Placeholder widgets - replace with actual content
  Widget buildHealthReport() => ListTile(
      title: const Text("No report available"), subtitle: const Text(""));
  Widget buildMedicalHistory() => ListTile(
      title: const Text("No history available"), subtitle: const Text(""));
  Widget buildNoData() => ListTile(
      title: const Text("No data available"), subtitle: const Text(""));

  Widget buildVitalsTracker() => ListTile(
      title: const Text("No vitals tracked"), subtitle: const Text(""));

  @override
}
