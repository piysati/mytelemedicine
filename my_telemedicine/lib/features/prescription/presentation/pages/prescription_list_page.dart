import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/user_dto.dart';
import 'package:my_telemedicine/features/prescription/domain/prescription_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

class PrescriptionListPage extends StatefulWidget {
  final String patientId;

  const PrescriptionListPage({super.key, required this.patientId});

  @override
  _PrescriptionListPageState createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> {
  late Future<List<PrescriptionDTO>> _prescriptionsFuture;
  late String _userId = "";
  late String _userRole = "";

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndPrescriptions();
  }

  Future<void> _fetchUserDataAndPrescriptions() async {
    final user = await FirebaseFirestoreService().getCurrentUser();
    final doc = await FirebaseFirestoreService().getUserById(user!.uid);
    setState(() {
      _userId = doc.uid;
      _userRole = doc.role;
      _prescriptionsFuture = FirebaseFirestoreService().getPrescriptionsByPatient(widget.patientId, _userId, _userRole);
    });
  }

  Future<void> _downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;
        final status = await Permission.storage.request();
        if(status.isGranted){
          final dir = await getExternalStorageDirectory();
          if(dir != null){
             final filename = path.basename(url);
             final file = File('${dir.path}/$filename');
             await file.writeAsBytes(pdfBytes, flush: true);
             print("Prescription saved in ${dir.path}/$filename");
             OpenFile.open(file.path);
          }else{
            print("Error getting external storage directory");
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error getting external storage directory')),
             );
          }
        }else{
          print("Permission to access the storage not granted");
        }
      }
    } catch (e) {
      print("Error downloading prescription: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
      ),
      body: FutureBuilder<List<PrescriptionDTO>>(
        future: _prescriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final prescription = snapshot.data![index];
                return ListTile(
                  title: Text(
                      'Prescription ${prescription.prescriptionId}'),
                  subtitle: Text(
                      'Date: ${prescription.date.toDate().toString()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      _downloadFile(prescription.pdfUrl);
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No prescriptions found.'));
          }
        },
      ),
    );
  }
}