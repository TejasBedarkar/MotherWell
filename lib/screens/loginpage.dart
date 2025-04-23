import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/screens/main_screen.dart';
import 'package:fitness_dashboard_ui/screens/DoctorScreen.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final String userRole;
  
  const AdditionalInfoScreen({super.key, required this.userRole});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Common fields
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';

  // Doctor specific fields
  String _specialization = '';
  String _qualification = '';
  String _clinicAddress = '';
  late String _doctorCode;

  // Patient specific fields
  double _weight = 0.0;
  String _bloodPressure = '';
  String _diseases = '';
  String _allergies = '';
  String _gynecCode = '';

  @override
  void initState() {
    super.initState();
    if (widget.userRole == 'Doctor') {
      _generateDoctorCode();
    }
  }

  void _generateDoctorCode() {
    // Generate a unique 6-digit code
    _doctorCode = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 13);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (widget.userRole == 'Doctor') {
        await _firestore.collection('doctors').doc(user.uid).set({
          'firstName': _firstName,
          'lastName': _lastName,
          'phoneNumber': _phoneNumber,
          'specialization': _specialization,
          'qualification': _qualification,
          'clinicAddress': _clinicAddress,
          'doctorCode': _doctorCode,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // For patients, first verify the gynec code
        final doctorSnapshot = await _firestore.collection('doctors')
          .where('doctorCode', isEqualTo: _gynecCode)
          .limit(1)
          .get();

        if (doctorSnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Gynecologist Code')),
          );
          return;
        }

        final doctorId = doctorSnapshot.docs.first.id;

        await _firestore.collection('patients').doc(user.uid).set({
          'firstName': _firstName,
          'lastName': _lastName,
          'phoneNumber': _phoneNumber,
          'weight': _weight,
          'bloodPressure': _bloodPressure,
          'diseases': _diseases,
          'allergies': _allergies,
          'gynecId': doctorId,
          'gynecCode': _gynecCode,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Update registration status in users collection
      await _firestore.collection('users').doc(user.uid).update({
        'registrationCompleted': true,
        'firstName': _firstName,
        'lastName': _lastName,
      });

      // Navigate to main screen after successful submission
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.userRole == "Patient"
              ? const MainScreen()
              : const DoctorDashboardScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: MaternityTheme.primaryPink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your ${widget.userRole} Profile'),
        backgroundColor: MaternityTheme.primaryPink,
        // Disable back button
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MaternityTheme.lightPink.withOpacity(0.1),
              MaternityTheme.white,
              MaternityTheme.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information text
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: MaternityTheme.lightPink.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MaternityTheme.primaryPink.withOpacity(0.5)),
                  ),
                  child: Text(
                    'Please complete your profile information to continue. Your account setup is not complete until you submit this form.',
                    style: TextStyle(
                      fontSize: 16,
                      color: MaternityTheme.primaryPink,
                    ),
                  ),
                ),
                
                // Common fields for both doctor and patient
                _buildTextField(
                  'First Name',
                  (value) => _firstName = value!,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Last Name',
                  (value) => _lastName = value!,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Phone Number',
                  (value) => _phoneNumber = value!,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),

                // Doctor specific fields
                if (widget.userRole == 'Doctor') ...[
                  Text(
                    'Professional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Specialization',
                    (value) => _specialization = value!,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Qualification',
                    (value) => _qualification = value!,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Clinic Address',
                    (value) => _clinicAddress = value!,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  Card(
                    color: MaternityTheme.lightPink,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Unique Doctor Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _doctorCode,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Share this code with your patients so they can connect with you',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Patient specific fields
                if (widget.userRole == 'Patient') ...[
                  Text(
                    'Health Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Weight (kg)',
                    (value) => _weight = double.tryParse(value!) ?? 0.0,
                    validator: (value) {
                      if (value!.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Blood Pressure',
                    (value) => _bloodPressure = value!,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Existing Diseases (if any)',
                    (value) => _diseases = value!,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Allergies (if any)',
                    (value) => _allergies = value!,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    'Your Gynecologist Code',
                    (value) => _gynecCode = value!,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    hintText: 'Enter the 6-digit code provided by your doctor',
                  ),
                ],

                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MaternityTheme.primaryPink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Complete Registration',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String?) onSaved, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: MaternityTheme.lightPink.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}