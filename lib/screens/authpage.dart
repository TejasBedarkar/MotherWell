import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/screens/main_screen.dart';
import 'package:fitness_dashboard_ui/screens/DoctorScreen.dart';
import 'package:fitness_dashboard_ui/screens/additional_info_screen.dart'; // Add this import

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool isLogin = true;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleScreen() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaternityTheme.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: MaternityTheme.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: MaternityTheme.primaryPink.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: isLogin
                  ? LoginPage(toggleScreen: toggleScreen)
                  : SignUpPage(toggleScreen: toggleScreen),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback toggleScreen;
  const LoginPage({super.key, required this.toggleScreen});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc['role'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => role == "Patient" 
                  ? const MainScreen() 
                  : const DoctorDashboardScreen(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog("Login Failed", e.message ?? "An error occurred");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK", 
              style: TextStyle(color: MaternityTheme.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: MaternityTheme.primaryPink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Login to continue",
          style: TextStyle(color: MaternityTheme.textLight),
        ),
        const SizedBox(height: 30),
        _buildTextField("Email", Icons.email, controller: _emailController),
        const SizedBox(height: 15),
        _buildTextField(
          "Password", 
          Icons.lock,
          controller: _passwordController, 
          obscureText: true,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: MaternityTheme.primaryPink,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Login",
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: widget.toggleScreen,
          child: RichText(
            text: TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(color: MaternityTheme.textLight),
              children: [
                TextSpan(
                  text: "Sign Up",
                  style: TextStyle(
                    color: MaternityTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SignUpPage extends StatefulWidget {
  final VoidCallback toggleScreen;
  const SignUpPage({super.key, required this.toggleScreen});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedRole = "Patient";
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Save basic user info to Firestore
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "email": email,
          "role": _selectedRole,
          "created_at": FieldValue.serverTimestamp(),
        });

        // Navigate to additional info screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdditionalInfoScreen(userRole: _selectedRole),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Create Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: MaternityTheme.primaryPink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Fill in your details to continue",
          style: TextStyle(color: MaternityTheme.textLight),
        ),
        const SizedBox(height: 30),
        _buildTextField("Email", Icons.email, controller: _emailController),
        const SizedBox(height: 15),
        _buildTextField(
          "Password", 
          Icons.lock,
          controller: _passwordController, 
          obscureText: true,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          "Confirm Password", 
          Icons.lock,
          controller: _confirmPasswordController, 
          obscureText: true,
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: MaternityTheme.lightPink.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedRole,
            isExpanded: true,
            underline: const SizedBox(),
            items: ["Patient", "Doctor"]
                .map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedRole = value!),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: MaternityTheme.primaryPink,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: widget.toggleScreen,
          child: RichText(
            text: TextSpan(
              text: "Already have an account? ",
              style: TextStyle(color: MaternityTheme.textLight),
              children: [
                TextSpan(
                  text: "Login",
                  style: TextStyle(
                    color: MaternityTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildTextField(String label, IconData icon,
    {bool obscureText = false, TextEditingController? controller}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: MaternityTheme.primaryPink),
      filled: true,
      fillColor: MaternityTheme.lightPink.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    ),
  );
}