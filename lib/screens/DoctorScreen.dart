import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_dashboard_ui/screens/login_form.dart';
import 'package:fitness_dashboard_ui/screens/doctor_messages_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _doctorName = 'Doctor';

  static final List<Widget> _widgetOptions = <Widget>[
    const _AppointmentsTab(),
    const _PatientsTab(),
  ];

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
    _controller.forward();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final doctorDoc = await _firestore.collection('doctors').doc(currentUser.uid).get();
        if (doctorDoc.exists) {
          setState(() {
            _doctorName = doctorDoc.data()?['name'] ?? 'Doctor';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading doctor name: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MaternityTheme.white,
      drawer: _buildDrawer(),
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
                  if (!isDesktop)
                    IconButton(
                      icon: Icon(Icons.menu, color: MaternityTheme.primaryPink),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  Text(
                    'MotherWell',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                      letterSpacing: 0.5,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: MaternityTheme.lightPink,
                    child: IconButton(
                      icon: const Icon(Icons.person_outline),
                      color: MaternityTheme.primaryPink,
                      onPressed: () {},
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
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDesktop) ...[
                    Text(
                      'Hello, Dr. $_doctorName',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MaternityTheme.primaryPink,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: _widgetOptions.elementAt(_selectedIndex),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Responsive.isDesktop(context)
          ? null
          : Container(
              decoration: BoxDecoration(
                color: MaternityTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: MaternityTheme.primaryPink.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.event_available, 'Appointments', 0),
                      _buildNavItem(Icons.pregnant_woman, 'Patients', 1),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: MaternityTheme.primaryPink.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dr. $_doctorName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MaternityTheme.primaryPink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Doctor Dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: MaternityTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerSectionHeader('Messages'),
          _buildDrawerItem(Icons.message, 'Patient Messages', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoctorMessagesScreen()),
            );
          }),
          
          _buildDrawerSectionHeader('Consultation'),
          _buildDrawerItem(Icons.video_call, 'Video Consultation', () {}),
          _buildDrawerItem(Icons.calendar_today, 'Schedule Consultation', () {}),
          
          _buildDrawerSectionHeader('Prescriptions'),
          _buildDrawerItem(Icons.medical_services, 'New Prescription', () {}),
          _buildDrawerItem(Icons.history, 'Prescription History', () {}),
          
          _buildDrawerSectionHeader('Settings'),
          _buildDrawerItem(Icons.settings, 'Account Settings', () {}),
          _buildDrawerItem(Icons.help, 'Help & Support', () {}),
          _buildDrawerItem(Icons.logout, 'Logout', () async {
            try {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginFormPage(role: 'Doctor'),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: MaternityTheme.primaryPink,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: MaternityTheme.primaryPink,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: MaternityTheme.textDark,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MaternityTheme.lightPink : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? MaternityTheme.primaryPink : MaternityTheme.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? MaternityTheme.primaryPink : MaternityTheme.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab({super.key});

  @override
  State<_AppointmentsTab> createState() => __AppointmentsTabState();
}

class __AppointmentsTabState extends State<_AppointmentsTab> {
  List<Map<String, String>> appointments = [
    {"time": "10:00 AM", "patient": "Riya Sharma", "status": "Confirmed"},
    {"time": "12:30 PM", "patient": "Neha Singh", "status": "Confirmed"},
    {"time": "3:00 PM", "patient": "Ankita Joshi", "status": "Pending"},
    {"time": "4:15 PM", "patient": "Pooja Desai", "status": "Confirmed"},
    {"time": "5:30 PM", "patient": "Meera Patel", "status": "Cancelled"},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      color: MaternityTheme.white,
      child: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          Color statusColor = MaternityTheme.primaryPink;
          if (appointment['status'] == 'Pending') {
            statusColor = Colors.orange;
          } else if (appointment['status'] == 'Cancelled') {
            statusColor = Colors.red;
          }

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MaternityTheme.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                color: MaternityTheme.primaryPink,
              ),
            ),
            title: Text(
              appointment['time']!,
              style: TextStyle(
                color: MaternityTheme.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment['patient']!),
                const SizedBox(height: 4),
                Text(
                  appointment['status']!,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: MaternityTheme.primaryPink.withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }
}

class _PatientsTab extends StatelessWidget {
  const _PatientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> patients = const [
      {"name": "Riya Sharma", "dueDate": "March 10, 2025", "trimester": "3rd"},
      {"name": "Neha Singh", "dueDate": "April 20, 2025", "trimester": "2nd"},
      {"name": "Ankita Joshi", "dueDate": "May 5, 2025", "trimester": "1st"},
      {"name": "Pooja Desai", "dueDate": "June 15, 2025", "trimester": "2nd"},
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      color: MaternityTheme.white,
      child: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MaternityTheme.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pregnant_woman,
                color: MaternityTheme.primaryPink,
              ),
            ),
            title: Text(
              patient['name']!,
              style: TextStyle(
                color: MaternityTheme.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Due: ${patient['dueDate']}"),
                const SizedBox(height: 4),
                Text(
                  "Trimester: ${patient['trimester']}",
                  style: TextStyle(
                    color: MaternityTheme.primaryPink,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: MaternityTheme.primaryPink.withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }
}