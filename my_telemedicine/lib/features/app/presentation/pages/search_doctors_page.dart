import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/app/domain/doctor_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import 'package:my_telemedicine/features/app/presentation/pages/doctor_details_page.dart';
import 'package:my_telemedicine/global/common/toast.dart';

class SearchDoctorsPage extends StatefulWidget {
  const SearchDoctorsPage({Key? key}) : super(key: key);

  @override
  State<SearchDoctorsPage> createState() => _SearchDoctorsPageState();
}

class _SearchDoctorsPageState extends State<SearchDoctorsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DoctorDTO> _doctors = [];
  final _firestoreService = FirebaseFirestoreService();
  bool _isLoading = false;

  Future<void> _searchDoctors(String specialization) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final doctors =
          await _firestoreService.getDoctorsBySpecialization(specialization);
      setState(() {
        _doctors = doctors;
      });
    } catch (e) {
      showToast(message: "Error searching doctors: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Doctors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter Specialization',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _searchDoctors(_searchController.text);
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorDetailsPage(doctor: _doctors[index])));
                        },
                        child: ListTile(
                          title: Text(_doctors[index].fullName),
                        ),
                      ),

                    ),
                  ),
          ],
        ),
      ),
    );
  }
}