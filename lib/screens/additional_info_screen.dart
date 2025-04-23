import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/screens/main_screen.dart';
import 'package:fitness_dashboard_ui/screens/DoctorScreen.dart';
import 'package:fitness_dashboard_ui/util/responsive.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final String userRole;
  
  const AdditionalInfoScreen({super.key, required this.userRole});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Animation controllers
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
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
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userRole == 'Doctor') {
      _generateDoctorCode();
    }
    
    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateDoctorCode() {
    // Generate a unique 6-digit code
    _doctorCode = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 13);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Gynecologist Code'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
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
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.userRole == "Patient"
                ? const MainScreen()
                : const DoctorDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MaternityTheme.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: MaternityTheme.white,
            boxShadow: [
              BoxShadow(
                color: MaternityTheme.primaryPink.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MotherWell',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MaternityTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role indicator card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        color: MaternityTheme.primaryPink,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: MaternityTheme.primaryPink.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.userRole == 'Doctor' 
                                ? Icons.medical_services_outlined 
                                : Icons.pregnant_woman,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.userRole == 'Doctor' 
                                      ? 'Doctor Registration' 
                                      : 'Patient Registration',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Complete your profile to get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Information card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: MaternityTheme.lightPink, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: MaternityTheme.lightPink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: MaternityTheme.primaryPink,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Please complete your profile information to continue. Your account setup is not complete until you submit this form.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Form content
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: MaternityTheme.primaryPink.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section header
                            _buildSectionHeader('Personal Information'),
                            const SizedBox(height: 24),
                            
                            // Common fields for both doctor and patient
                            _buildTextField(
                              'First Name',
                              (value) => _firstName = value!,
                              validator: (value) => value!.isEmpty ? 'First name is required' : null,
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 20),
                            
                            _buildTextField(
                              'Last Name',
                              (value) => _lastName = value!,
                              validator: (value) => value!.isEmpty ? 'Last name is required' : null,
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 20),
                            
                            _buildTextField(
                              'Phone Number',
                              (value) => _phoneNumber = value!,
                              validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
                              keyboardType: TextInputType.phone,
                              icon: Icons.phone_outlined,
                            ),
                            const SizedBox(height: 30),

                            // Doctor specific fields
                            if (widget.userRole == 'Doctor') ...[
                              _buildSectionHeader('Professional Information'),
                              const SizedBox(height: 24),
                              
                              _buildTextField(
                                'Specialization',
                                (value) => _specialization = value!,
                                validator: (value) => value!.isEmpty ? 'Specialization is required' : null,
                                icon: Icons.medical_services_outlined,
                              ),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                'Qualification',
                                (value) => _qualification = value!,
                                validator: (value) => value!.isEmpty ? 'Qualification is required' : null,
                                icon: Icons.school_outlined,
                              ),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                'Clinic Address',
                                (value) => _clinicAddress = value!,
                                validator: (value) => value!.isEmpty ? 'Clinic address is required' : null,
                                maxLines: 3,
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 30),
                              
                              // Doctor code card
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      MaternityTheme.primaryPink,
                                      MaternityTheme.primaryPink.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: MaternityTheme.primaryPink.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.verified_outlined,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Your Unique Doctor Code',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              spreadRadius: 0,
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          _doctorCode,
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: MaternityTheme.primaryPink,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Share this code with your patients so they can connect with you',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Patient specific fields
                            if (widget.userRole == 'Patient') ...[
                              _buildSectionHeader('Health Information'),
                              const SizedBox(height: 24),
                              
                              _buildTextField(
                                'Weight (kg)',
                                (value) => _weight = double.tryParse(value!) ?? 0.0,
                                validator: (value) {
                                  if (value!.isEmpty) return 'Weight is required';
                                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                icon: Icons.monitor_weight_outlined,
                              ),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                'Blood Pressure',
                                (value) => _bloodPressure = value!,
                                hintText: 'e.g. 120/80',
                                icon: Icons.favorite_border,
                              ),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                'Existing Diseases (if any)',
                                (value) => _diseases = value!,
                                maxLines: 2,
                                hintText: 'List any pre-existing conditions',
                                icon: Icons.medical_information_outlined,
                              ),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                'Allergies (if any)',
                                (value) => _allergies = value!,
                                maxLines: 2,
                                hintText: 'List any allergies you have',
                                icon: Icons.healing_outlined,
                              ),
                              const SizedBox(height: 30),
                              
                              _buildSectionHeader('Connect with your Doctor'),
                              const SizedBox(height: 24),
                              
                              _buildTextField(
                                'Your Gynecologist Code',
                                (value) => _gynecCode = value!,
                                validator: (value) => value!.isEmpty ? 'Gynecologist code is required' : null,
                                hintText: 'Enter the 6-digit code provided by your doctor',
                                icon: Icons.pin_outlined,
                              ),
                            ],

                            const SizedBox(height: 40),
                            
                            // Submit button
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MaternityTheme.primaryPink,
                                    foregroundColor: Colors.white,
                                    elevation: 5,
                                    shadowColor: MaternityTheme.primaryPink.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Complete Registration',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: MaternityTheme.white,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: MaternityTheme.primaryPink,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MaternityTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    Function(String?) onSaved, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null 
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(icon, color: MaternityTheme.primaryPink),
                ) 
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: MaternityTheme.primaryPink,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(
            color: MaternityTheme.textLight,
          ),
        ),
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        cursorColor: MaternityTheme.primaryPink,
        style: TextStyle(
          color: MaternityTheme.textDark,
          fontSize: 16,
        ),
      ),
    );
  }
}