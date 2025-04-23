import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:fitness_dashboard_ui/screens/additional_info_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  bool _isDoctor = false;
  Map<String, dynamic>? _userData;
  String _userRole = 'Patient';
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _loadUserData();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      // First, check the user's role from the users collection
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData.containsKey('role')) {
          _userRole = userData['role'] as String;
          _isDoctor = _userRole == 'Doctor';
        }
      }
      
      // Then fetch the appropriate profile data
      final String collectionName = _isDoctor ? 'doctors' : 'patients';
      final profileDoc = await _firestore.collection(collectionName).doc(currentUser.uid).get();
      
      if (profileDoc.exists) {
        setState(() {
          _userData = profileDoc.data();
          _isLoading = false;
        });
        _controller.forward();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdditionalInfoScreen(userRole: _userRole),
      ),
    ).then((_) {
      // Refresh the profile data when returning from edit screen
      setState(() {
        _isLoading = true;
      });
      _loadUserData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    return Scaffold(
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: MaternityTheme.primaryPink,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Your Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: _isLoading 
                        ? const SizedBox() 
                        : IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: MaternityTheme.primaryPink,
                            onPressed: _editProfile,
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
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: MaternityTheme.primaryPink,
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User avatar and name card
                          _buildProfileHeader(),
                          
                          const SizedBox(height: 30),
                          
                          // Personal information
                          _buildInfoSection(
                            'Personal Information',
                            Icons.person_outline,
                            [
                              _buildInfoItem('First Name', _userData?['firstName'] ?? '-'),
                              _buildInfoItem('Last Name', _userData?['lastName'] ?? '-'),
                              _buildInfoItem('Phone', _userData?['phoneNumber'] ?? '-'),
                              if (_userData?['email'] != null)
                                _buildInfoItem('Email', _userData?['email']),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Doctor specific information
                          if (_isDoctor) ...[
                            _buildInfoSection(
                              'Professional Information',
                              Icons.medical_services_outlined,
                              [
                                _buildInfoItem('Specialization', _userData?['specialization'] ?? '-'),
                                _buildInfoItem('Qualification', _userData?['qualification'] ?? '-'),
                                _buildInfoItem('Clinic Address', _userData?['clinicAddress'] ?? '-'),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Doctor code card
                            _buildDoctorCodeCard(),
                          ],
                          
                          // Patient specific information
                          if (!_isDoctor) ...[
                            _buildInfoSection(
                              'Health Information',
                              Icons.favorite_border,
                              [
                                _buildInfoItem('Weight', _userData?['weight'] != null ? '${_userData!['weight']} kg' : '-'),
                                _buildInfoItem('Blood Pressure', _userData?['bloodPressure'] ?? '-'),
                                _buildInfoItem('Existing Diseases', _userData?['diseases'] ?? 'None'),
                                _buildInfoItem('Allergies', _userData?['allergies'] ?? 'None'),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Doctor connection information
                            _buildInfoSection(
                              'Doctor Connection',
                              Icons.people_outline,
                              [
                                _buildInfoItem('Gynecologist Code', _userData?['gynecCode'] ?? '-'),
                              ],
                            ),
                          ],
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
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
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _isDoctor ? Icons.medical_services_outlined : Icons.person_outline,
                size: 50,
                color: MaternityTheme.primaryPink,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _userRole,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: MaternityTheme.primaryPink,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: MaternityTheme.primaryPink,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MaternityTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: MaternityTheme.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: MaternityTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            color: Colors.grey.withOpacity(0.2),
            thickness: 1,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDoctorCodeCard() {
    return Container(
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
        border: Border.all(
          color: MaternityTheme.lightPink,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.qr_code,
                color: Colors.black87,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Your Doctor Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: MaternityTheme.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MaternityTheme.primaryPink,
                  width: 2,
                ),
              ),
              child: Text(
                _userData?['doctorCode'] ?? '------',
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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: MaternityTheme.textLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Share this code with your patients for them to connect with you',
                  style: TextStyle(
                    color: MaternityTheme.textLight,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}