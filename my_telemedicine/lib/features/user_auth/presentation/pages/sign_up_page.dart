import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_telemedicine/features/user_auth/presentation/pages/login_page.dart';
import 'package:my_telemedicine/features/user_auth/presentation/widget/form_container_widget.dart';
import 'package:my_telemedicine/global/common/toast.dart';

import 'package:my_telemedicine/features/user_auth/domain/user_dto.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});


  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();

  // Common Fields
  final _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _selectedRole;
  bool isObscurePassword = true;

  // Patient-Specific Fields
  final _ageController = TextEditingController();
  String? _gender;
  List<String> _healthConditions = [];
  final _emergencyContactController = TextEditingController();
  String? _preferredLanguage;

  // Doctor-Specific Fields
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hospitalAffiliationController = TextEditingController();
  final _licenseIdController = TextEditingController();
  // Timings and Consultation Fee can be more complex, using simple text fields for now
  final _availableTimingsController = TextEditingController();
  final _consultationFeeController = TextEditingController();

  // Caretaker-Specific Fields
  final _patientNameController = TextEditingController();
  final _relationToPatientController = TextEditingController();
  final _patientContactController = TextEditingController();
  // Access Permissions - For simplicity, a text field. Consider a more robust approach.
  final _accessPermissionsController = TextEditingController();

  final List<String> _roles = ['Patient', 'Doctor', 'Caretaker'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _languages = ['English', 'Spanish', 'French', 'Other'];
  final List<String> _healthConditionOptions = [
    'Diabetes',
    'Hypertension',
    'Asthma',
  ]; // Example
  bool isSigningUp = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("SignUp"),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your full name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                  validator: (value) => value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Role'),
                  value: _selectedRole,
                  items: _roles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) {
                   setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a role' : null,
                ),
                const SizedBox(height: 20),

                // Role-Specific Fields
                if (_selectedRole == 'Patient') ...[
                  const Text(
                    "Patient Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your age' : null,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    value: _gender,
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                          value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select your gender' : null,
                  ),
                  const SizedBox(height: 10),
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _healthConditionOptions.where((option) => option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selected) {
                      setState(() {
                        if (!_healthConditions.contains(selected)) {
                          _healthConditions.add(selected);
                        }
                      });
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode,
                        onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                            labelText: 'Health Conditions (Type to add)'),
                        onFieldSubmitted: (String value) {
                          onFieldSubmitted();
                          if (value.isNotEmpty &&
                              !_healthConditions.contains(value)) {
                            setState(() {
                              _healthConditions.add(value);
                            });
                            textEditingController.clear();
                          }
                        },
                      );
                    },
                  ),
                  if (_healthConditions.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      children: _healthConditions.map((condition) {
                        return Chip(
                          label: Text(condition),
                          onDeleted: () {
                            setState(() {
                              _healthConditions.remove(condition);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  TextFormField(
                    controller: _emergencyContactController,
                    decoration:
                        const InputDecoration(labelText: 'Emergency Contact'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter an emergency contact'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Preferred Language'),
                    value: _preferredLanguage,
                    items: _languages.map((language) {
                      return DropdownMenuItem(
                          value: language, child: Text(language));
                    }).toList(),
                    onChanged: (value) {
                     setState(() {
                        _preferredLanguage = value;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Please select your preferred language'
                        : null,
                  ),
                ],
                if (_selectedRole == 'Doctor') ...[
                  const Text(
                    "Doctor Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _specializationController,
                    decoration: const InputDecoration(labelText: 'Specialization'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your specialization'
                        : null,
                  ),
                  TextFormField(
                    controller: _experienceController,
                    decoration:
                        const InputDecoration(labelText: 'Experience (years)'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                     value!.isEmpty ? 'Please enter your experience' : null,
                  ),
                  TextFormField(
                    controller: _hospitalAffiliationController,
                    decoration: const InputDecoration(
                        labelText: 'Hospital/Clinic Affiliation'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your affiliation'
                        : null,
                  ),
                  TextFormField(
                    controller: _licenseIdController,
                    decoration: const InputDecoration(
                        labelText: 'License ID / Medical Reg. Number'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your license ID'
                        : null,
                  ),
                  TextFormField(
                    controller: _availableTimingsController,
                    decoration:
                        const InputDecoration(labelText: 'Available Timings'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your available timings'
                        : null,
                  ),
                  TextFormField(
                    controller: _consultationFeeController,
                    decoration:
                        const InputDecoration(labelText: 'Consultation Fee'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your consultation fee'
                        : null,
                  ),
                ],
                if (_selectedRole == 'Caretaker') ...[
                  const Text(
                    "Caretaker Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _patientNameController,
                    decoration:
                        const InputDecoration(labelText: 'Name of Elderly Patient'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter the patient\'s name'
                        : null,
                  ),
                  TextFormField(
                    controller: _relationToPatientController,
                    decoration:
                        const InputDecoration(labelText: 'Relation to Patient'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your relation to the patient'
                        : null,
                  ),
                  TextFormField(
                    controller: _patientContactController,
                    decoration: const InputDecoration(
                        labelText: 'Contact Details of the Patient'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter the patient\'s contact details'
                        : null,
                  ),
                  TextFormField(
                    controller: _accessPermissionsController,
                    decoration:
                        const InputDecoration(labelText: 'Access Permissions'),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter access permissions'
                        : null,
                  ),
                ],
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _signUp();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: isSigningUp
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (route) => false);
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              ],
            ),
          )),)
          ;
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      String fullName = _fullNameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String phoneNumber = _phoneNumberController.text;

      UserDTO userDto;

      if (_selectedRole == 'Patient') {
        userDto = PatientDTO(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          age: int.parse(_ageController.text),
          gender: _gender!,
          healthConditions: _healthConditions,
          emergencyContact: _emergencyContactController.text,
          preferredLanguage: _preferredLanguage!,
        );
      } else if (_selectedRole == 'Doctor') {
        userDto = DoctorDTO(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          specialization: _specializationController.text,
          experience: int.parse(_experienceController.text),
          affiliation: _hospitalAffiliationController.text,
          licenseId: _licenseIdController.text,
          availableTimings: _availableTimingsController.text,
          consultationFee: double.parse(_consultationFeeController.text),
        );
      } else {
        userDto = CaretakerDTO(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          patientName: _patientNameController.text,
          relationToPatient: _relationToPatientController.text,
          patientContact: _patientContactController.text,
          accessPermissions: _accessPermissionsController.text,
        );
      }

      setState(() {
        isSigningUp = true;
      });
      try {
        User? user = await _auth.signUpWithEmailAndPassword(email, password);

          if (user != null) {
            await _auth.addUserToFirestore(user.uid, userDto.toJson());
            showToast(message: "User registered successfully. Please Login.");
            Navigator.pushNamed(context, "/home");
          } else {
            showToast(message: "Registration failed. Please try again.");
          }
        } catch (e) {
          showToast(message: "Error: ${e.toString()}");
          // Handle specific Firebase exceptions as needed (e.g., email already in use)
        } finally {
          setState(() {
            isSigningUp = false;
          });
      }
    }
  }
}
