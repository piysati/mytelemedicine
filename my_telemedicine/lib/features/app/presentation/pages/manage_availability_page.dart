import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../user_auth/firebase_auth_impl/firebase_firestore_service.dart';

class ManageAvailabilityPage extends StatefulWidget {
  const ManageAvailabilityPage({Key? key}) : super(key: key);

  @override
  State<ManageAvailabilityPage> createState() => _ManageAvailabilityPageState();
}

class _ManageAvailabilityPageState extends State<ManageAvailabilityPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadAvailability();
    }
  }

  Future<void> _addTimeSlot() async {
    final startTime = _startTimeController.text;
    final endTime = _endTimeController.text;

    if (startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter start and end times')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }
      final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      await FirebaseFirestoreService().saveDoctorAvailabilitySlot(user.uid, dateString, startTime, endTime);
       _loadAvailability();
      _startTimeController.clear();
      _endTimeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving availability: $e')),
      );
    }
  }

  Future<void> _loadAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }
        final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    setState(() {
      _isLoading = true;
    });
    try {
       final availability = await FirebaseFirestoreService().getDoctorAvailabilityByDate(user.uid, dateString);
       setState(() {
         _timeSlots = availability;
       });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading availability: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void dispose() {
      _startTimeController.dispose();
      _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
             ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Select Date: $dateString'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
            ),
             TextField(
              controller: _endTimeController,
              decoration: const InputDecoration(labelText: 'End Time (HH:MM)'),
            ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTimeSlot,
                child: const Text('Add Time Slot'),
            ),
            const SizedBox(height: 20),
             _isLoading
                ? const Center(child:  CircularProgressIndicator())
                : SizedBox(height: 300,
                  child: ListView.builder(
                     itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final timeSlot = _timeSlots[index];
                       return ListTile(
                          title: Text('Start Time: ${timeSlot['startTime']}'),
                          subtitle: Text('End Time: ${timeSlot['endTime']}'),
                          );
                     },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}