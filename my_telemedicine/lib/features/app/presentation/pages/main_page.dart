import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/doctor_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/auth_service.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import 'package:my_telemedicine/features/prescription/presentation/pages/prescription_list_page.dart';
import 'package:my_telemedicine/features/app/presentation/pages/manage_caregivers_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isLoading = true;
  String _userRole = "";
  String _patientId = "";
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = await FirebaseFirestoreService().getCurrentUser();
    final doc = await FirebaseFirestoreService().getUserById(user!.uid);

    setState(() {
      _isLoading = false;
      _userRole = doc.role;
      if (_userRole == "Patient") _patientId = doc.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   if (_userRole == "Patient")
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageCaregiversPage(patientId: _patientId)),
                        );
                      },
                      child: const Text("Manage Caregivers"),
                    ),
                  if (_userRole == "Patient")
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrescriptionListPage(
                                  patientId: _patientId)),
                        );
                      },
                      child: const Text("My Prescriptions"),
                    ),
                ],
              ),
            ),
    );
  }
}