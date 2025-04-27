import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/appointment_dto.dart';
import 'package:my_telemedicine/features/user_auth/domain/user_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String _role = "";
  String _name = "";
  bool _isLoading = true;
  List<AppointmentDTO> _appointments = [];
  List<UserDTO> _patients = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _user = FirebaseAuth.instance.currentUser;
    await _fetchUserData();
    setState(() {
      _isLoading = false;
    });
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
            _role = (data?['role'] ?? "") as String;
            _name = (data?['fullName'] ?? "") as String;
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Consider showing an error message to the user
      setState(() {});
    }
  }

  Widget _buildDoctorHomePage() {
    _loadDoctorData();
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
            Text("My Patients", style: Theme.of(context).textTheme.titleLarge),
             _isLoading ? const Center(child: CircularProgressIndicator()) : _buildPatientList(),
            const SizedBox(height: 20),
            Text("Upcoming Appointments",
                style: Theme.of(context).textTheme.titleLarge),
            _isLoading ? const Center(child: CircularProgressIndicator()) : _buildAppointmentList(),
          ],
        ),
      ),
    );
  }
  Future<void> _loadDoctorData() async {
    setState(() => _isLoading = true);
    try {
      if (_user != null) {
        final firestoreService = FirebaseFirestoreService();
        final appointments = await firestoreService.getDoctorAppointments(_user!.uid);
        final patients = await firestoreService.getDoctorPatients(_user!.uid);

        setState(() {
          _appointments = appointments;
          _patients = patients;
        });
      }
    } catch (e) {
      print('Error loading doctor data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _patients.length,
      itemBuilder: (context, index) {
        final patient = _patients[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              title: Text(patient.fullName),

            
            subtitle: Text(
                "Condition: ${patients[index]["condition"]!}, Last Diagnosis: ${patients[index]["lastDiagnosis"]!}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: Icon(Icons.person), onPressed: () {}), // View Profile
                IconButton(icon: Icon(Icons.notes), onPressed: () {}), // Add Notes
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        


        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text("${appointments[index]["time"]!} - ${appointments[index]["patientName"]!}"),
            subtitle: Text("Reason: ${appointments[index]["reason"]!}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.check), onPressed: () {}), // Accept
                IconButton(icon: Icon(Icons.close), onPressed: () {}), // Reject
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientCaregiverHomePage() {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, ${_name ?? 'User'}",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Text("Latest Health Report",
                style: Theme.of(context).textTheme.titleMedium),
            // Replace with actual report data
            _buildHealthReport(),
            const SizedBox(height: 20),
            Text("Medical History",
                style: Theme.of(context).textTheme.titleMedium),
            // Replace with actual medical history data
            _buildMedicalHistory(),
            const SizedBox(height: 20),
            Text("Health Condition Tracker",
                style: Theme.of(context).textTheme.titleMedium),
            // Replace with actual vitals data
            _buildVitalsTracker(),
            ElevatedButton(
              onPressed: () {}, // Navigate to booking screen
              child: const Text("Book Appointment"),
            ),
            const SizedBox(height: 20),
            Text("Medical History",
                style: Theme.of(context).textTheme.titleLarge),
            // Replace with actual medical history data
            _buildMedicalHistory(),
            const SizedBox(height: 20),
            Text("Health Condition Tracker",
                style: Theme.of(context).textTheme.titleLarge),
            // Replace with actual vitals data
            _buildVitalsTracker(),
          ],
        ),
      ),
    );
  }

  // Placeholder widgets - replace with actual content
  Widget _buildHealthReport() =>
      ListTile(title: Text("No report available"), subtitle: Text(""));
  Widget _buildMedicalHistory() =>
      ListTile(title: Text("No history available"), subtitle: Text(""));
  Widget _buildVitalsTracker() =>
      ListTile(title: Text("No vitals tracked"), subtitle: Text(""));

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
          : _buildPatientCaregiverHomePage();
    }
  }
}
