import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/user_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';

class ManageCaregiversPage extends StatefulWidget {
  final String patientId;

  const ManageCaregiversPage({Key? key, required this.patientId})
      : super(key: key);

  @override
  _ManageCaregiversPageState createState() => _ManageCaregiversPageState();
}

class _ManageCaregiversPageState extends State<ManageCaregiversPage> {
  List<String> _caregiverIds = [];
  final TextEditingController _caregiverIdController = TextEditingController();
  late Future<List<UserDTO>> _caregiversFuture;

  @override
  void initState() {
    super.initState();
    _fetchCaregivers();
  }

  Future<void> _fetchCaregivers() async {
      final patient = await FirebaseFirestoreService().getUserById(widget.patientId);
      setState(() {
      _caregiverIds = patient.caregiverIds;
    });
    _caregiversFuture = _getCaregivers();
  }

    Future<List<UserDTO>> _getCaregivers() async {
      List<UserDTO> caregivers = [];
      for(var id in _caregiverIds){
        final user = await FirebaseFirestoreService().getUserById(id);
        caregivers.add(user);
      }
      return caregivers;
    }

  void _addCaregiver() async {
    if (_caregiverIdController.text.isNotEmpty) {
      setState(() {
        _caregiverIds.add(_caregiverIdController.text);
        _caregiverIdController.clear();
      });
      await FirebaseFirestoreService().updateCaregivers(widget.patientId, _caregiverIds);
        _fetchCaregivers();
    }
  }

  void _removeCaregiver(String caregiverId) async {
    setState(() {
      _caregiverIds.remove(caregiverId);
    });
    await FirebaseFirestoreService().updateCaregivers(widget.patientId, _caregiverIds);
     _fetchCaregivers();
  }

  @override
  void dispose() {
    _caregiverIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Caregivers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _caregiverIdController,
              decoration: InputDecoration(
                labelText: 'Caregiver User ID',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCaregiver,
                ),
              ),
              onSubmitted: (_) => _addCaregiver(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<UserDTO>>(
                future: _caregiversFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final caregiver = snapshot.data![index];
                        return ListTile(
                          title: Text(caregiver.fullName),
                          subtitle: Text(caregiver.uid),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _removeCaregiver(caregiver.uid),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No caregivers added.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}