import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/doctor_dto.dart';
import 'package:my_telemedicine/features/app/domain/user_dto.dart';
import 'package:my_telemedicine/features/prescription/domain/prescription_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/auth_service.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import 'dart:math';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class CreatePrescriptionPage extends StatefulWidget {
  final String patientId;
  final String appointmentId;

  const CreatePrescriptionPage({super.key, required this.patientId, required this.appointmentId});

  @override
  _CreatePrescriptionPageState createState() => _CreatePrescriptionPageState();
}

class _CreatePrescriptionPageState extends State<CreatePrescriptionPage> {
  final _formKey = GlobalKey<FormState>();
  List<String> _medications = [];
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  void _addMedication() {
    setState(() {
      if (_medicationController.text.isNotEmpty) {
        _medications.add(_medicationController.text);
        _medicationController.clear();
      }
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _createPrescription() async {
      if (_formKey.currentState!.validate()) {
          final prescriptionId = generateRandomId();
          final prescription = PrescriptionDTO(
            prescriptionId: prescriptionId,
            doctorId: FirebaseFirestoreService().getCurrentUser()!.uid,
            patientId: widget.patientId,
            date: Timestamp.now(),
            medications: _medications,
            notes: _notesController.text,
            pdfUrl: "",
            appointmentId: widget.appointmentId
          );
          await FirebaseFirestoreService().addPrescription(prescription);
          final pdfBytes = await generatePdf(prescription);
          final pdfUrl = await FirebaseFirestoreService().uploadPrescriptionPdf(prescriptionId, widget.patientId, pdfBytes);
          await FirebaseFirestoreService().updatePrescriptionPdfUrl(prescriptionId, pdfUrl);
          Navigator.pop(context);
      }
  }

  Future<List<int>> generatePdf(PrescriptionDTO prescription) async {    
    final doctor = await FirebaseFirestoreService().getUserById(prescription.doctorId);
    final patient = await FirebaseFirestoreService().getUserById(prescription.patientId);
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Text('Prescription', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Doctor: ${doctor.fullName}'),
            pw.Text('Patient: ${patient.fullName}'),
            pw.SizedBox(height: 10),
            pw.Text('Date: ${prescription.date.toDate().toString()}'),
            pw.SizedBox(height: 10),
            pw.Text('Medications:'),
            pw.Column(children: [
               for(final medication in prescription.medications)
               pw.Text(medication)
            ]),
             pw.SizedBox(height: 10),
             pw.Text('Notes: ${prescription.notes}'),
          ]);
        }));
    return await pdf.save();
  }







    String generateRandomId() {
      return Random().nextInt(1000000).toString();
    }
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Prescription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _medicationController,
                decoration: InputDecoration(
                  labelText: 'Medication',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addMedication,
                  ),
                ),
                onFieldSubmitted: (_) => _addMedication(),
              ),
              const SizedBox(height: 10),
              if (_medications.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Added Medications:'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_medications[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _removeMedication(index),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createPrescription,
                child: const Text('Create Prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}