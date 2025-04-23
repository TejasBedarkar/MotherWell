import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:fitness_dashboard_ui/widgets/dashboard_widget.dart';
import 'package:fitness_dashboard_ui/widgets/summary_widget.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/screens/schedule_screen.dart';
import 'package:fitness_dashboard_ui/screens/health_screen.dart';
import 'package:fitness_dashboard_ui/screens/settings_screen.dart';
import 'package:fitness_dashboard_ui/screens/pregnancy_tracking_screen.dart';
import 'package:fitness_dashboard_ui/screens/chatbot.dart';
import 'package:fitness_dashboard_ui/screens/login_form.dart';
import 'package:fitness_dashboard_ui/screens/messages_screen.dart';
import 'package:fitness_dashboard_ui/screens/user_profile_screen.dart'; // Import the new screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // User data
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'User';
  
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
    
    // Load user's name
    _loadUserName();
  }
  
  Future<void> _loadUserName() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData.containsKey('firstName')) {
            setState(() {
              _userName = userData['firstName'] as String;
            });
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfileScreen()),
    );
  }

  Widget _buildPremiumDrawer(BuildContext context) {
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
                  'Hi $_userName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MaternityTheme.primaryPink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome to MotherWell',
                  style: TextStyle(
                    fontSize: 14,
                    color: MaternityTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: MaternityTheme.primaryPink,
            ),
            title: Text(
              'Your Profile',
              style: TextStyle(
                color: MaternityTheme.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _openProfileScreen();
            },
          ),
          _buildDrawerSectionHeader('Communication'),
          _buildDrawerItem(Icons.chat_bubble_outline, 'Chatbot', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Chatbot()),
            );
          }),
          _buildDrawerItem(Icons.message_outlined, 'Messages', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagesScreen()),
            );
          }),
          _buildDrawerSectionHeader('Support'),
          _buildDrawerItem(Icons.help_outline, 'Help & Support', () {}),
          _buildDrawerItem(Icons.logout, 'Logout', () async {
            try {
              await _auth.signOut();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginFormPage(role: 'User')),
                );
              }
            } catch (e) {
              // Handle sign out error
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MaternityTheme.white,
      drawer: _buildPremiumDrawer(context),
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
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
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
                      onPressed: _openProfileScreen,  // Link to profile screen
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      endDrawer: Responsive.isMobile(context)
          ? Container(
              width: MediaQuery.of(context).size.width * 0.85,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MaternityTheme.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MaternityTheme.primaryPink.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
              child: const SummaryWidget(),
            )
          : null,
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
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                child: _getPage(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: MaternityTheme.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: MaternityTheme.primaryPink.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const DashboardWidget(),
              ),
            ),
            if (Responsive.isDesktop(context)) const SizedBox(width: 24),
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: MaternityTheme.primaryPink.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const SummaryWidget(),
                ),
              ),
          ],
        );
      case 1:
        return const PregnancyTrackingScreen();
      case 2:
        return const ScheduleScreen();
      case 3:
        return const HealthScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNavigationBar() {
    final isDesktop = Responsive.isDesktop(context);
    if (isDesktop) return Container();

    return Container(
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
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.pregnant_woman, 'Pregnancy', 1),
              _buildNavItem(Icons.calendar_today_outlined, 'Schedule', 2),
              _buildNavItem(Icons.favorite_outline, 'Health', 3),
              _buildNavItem(Icons.settings_outlined, 'Settings', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
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