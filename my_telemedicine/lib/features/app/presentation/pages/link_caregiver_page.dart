import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import 'package:my_telemedicine/features/user_auth/domain/user_dto.dart';

class LinkCaregiverPage extends StatefulWidget {
  const LinkCaregiverPage({Key? key}) : super(key: key);

  @override
  State<LinkCaregiverPage> createState() => _LinkCaregiverPageState();
}

class _LinkCaregiverPageState extends State<LinkCaregiverPage> {
  final TextEditingController _caregiverIdController = TextEditingController();
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Link Caregiver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _caregiverIdController,
              decoration: const InputDecoration(
                labelText: 'Caregiver ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final patientId = FirebaseAuth.instance.currentUser?.uid;
                final caregiverId = _caregiverIdController.text;
                if (patientId != null && caregiverId.isNotEmpty) {
                  _firestoreService
                      .linkCaregiverToPatient(patientId, caregiverId)
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Caregiver linked successfully!')));
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Error linking caregiver.')));
                  });
                }
              },
              child: const Text('Link Caregiver'),
            ),
          ],
        ),
      ),
    );
  }
}