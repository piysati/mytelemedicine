import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            // Replace with actual patient list data
            _buildPatientList(),
            const SizedBox(height: 20),
            Text("Upcoming Appointments",
                style: Theme.of(context).textTheme.titleLarge),
            // Replace with actual appointment data
            _buildAppointmentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    // Replace with your data fetching logic
    List<Map<String, String>> patients = [
      {"name": "Alice", "condition": "Diabetes", "lastDiagnosis": "2024-01-15"},
      {"name": "Bob", "condition": "Hypertension", "lastDiagnosis": "2023-12-20"},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(patients[index]["name"]!),
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
    // Replace with your data fetching logic
    List<Map<String, String>> appointments = [
      {
        "time": "10:00 AM",
        "patientName": "Charlie",
        "reason": "Follow-up Checkup"
      },
      {"time": "2:30 PM", "patientName": "Diana", "reason": "Initial Consultation"},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
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
