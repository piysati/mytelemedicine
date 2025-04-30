import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import '../widgets/time_picker.dart';

class ManageAvailabilityPage extends StatefulWidget {

  @override
  State<ManageAvailabilityPage> createState() => _ManageAvailabilityPageState();
}

class _ManageAvailabilityPageState extends State<ManageAvailabilityPage> {
    DateTime _selectedDate = DateTime.now();
     final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  bool _isLoading = false;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<Map<String, dynamic>> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        _startTimeController.text = picked.format(context);
      });
    }
  }


  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = picked.format(context);
      });
    }
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

  Future<void> _saveTimeSlot() async {
        if (_startTime == null || _endTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end times')),
        );
          return;
        }
    
    final startTime = _startTime!.format(context);
    final endTime = _endTime!.format(context);

    if (startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter start and end times')),
      );
      return;
    }

    final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
     final isAvailabilityOverlap = await FirebaseFirestoreService().checkAvailabilityOverlap(user.uid, dateString, startTime, endTime);
      if (isAvailabilityOverlap) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('The selected time slot overlaps with an existing time slot.')),
          );
        return;
      }

    final days = [dateString];
    final isOverlap = await FirebaseFirestoreService().checkAppointmentOverlap(user.uid, days, startTime, endTime);
     if (isOverlap) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('The selected time slot overlaps with an existing appointment.')),
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
       if(user!=null){
       
      }
      final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      await FirebaseFirestoreService().saveDoctorAvailabilitySlot(user.uid, dateString, startTime, endTime);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving availability: $e')),
      );
    }finally {
      await _loadAvailability();
        _startTimeController.clear();
        _endTimeController.clear();
        setState(() {
          _startTime = null;
          _endTime = null;
        });
    }
  }

   Future<void> _removeTimeSlot(int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }
      final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      List<Map<String, dynamic>> newTimeSlots = List.from(_timeSlots);
      newTimeSlots.removeAt(index);
      await FirebaseFirestoreService().updateDoctorAvailabilitySlot(user.uid, dateString, newTimeSlots);
       await _loadAvailability();
      _endTimeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving availability: $e')),
      );
    }
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
            GestureDetector(
              onTap: () => _selectStartTime(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _startTimeController,
                  decoration: const InputDecoration(labelText: 'Start Time'),
                ),
              ),
            ),
             GestureDetector(
               onTap: () => _selectEndTime(context),
               child: AbsorbPointer(
                 child: TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(labelText: 'End Time'),
                 ),
               ),
            ),
              const SizedBox(height: 20),
             ElevatedButton(
                onPressed: _saveTimeSlot,
                child: const Text('Save Time Slot'),
            ),
            const SizedBox(height: 20),
             _isLoading
                ? const Center(child:  CircularProgressIndicator())
                : _timeSlots.isEmpty ? Center(child: Text("There are no slots for this day"))
                : SizedBox(height: 300,
                  child: ListView.builder(
                     itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final timeSlot = _timeSlots[index];
                      return ListTile(
                          onTap: () => _removeTimeSlot(index),
                          trailing: Icon(Icons.delete),
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