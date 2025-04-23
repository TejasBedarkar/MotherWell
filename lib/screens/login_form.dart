import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/screens/main_screen.dart';

class LoginFormPage extends StatefulWidget {
  final String role;
  const LoginFormPage({super.key, required this.role});

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }
  
  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter email and password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MaternityTheme.primaryPink.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: MaternityTheme.primaryPink),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    "Login as ${widget.role}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                      letterSpacing: 0.5,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: MaternityTheme.lightPink,
                    radius: 18,
                    child: Icon(
                      Icons.lock_outline,
                      color: MaternityTheme.primaryPink,
                      size: 18,
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),
                    Container(
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: MaternityTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please sign in to continue",
                            style: TextStyle(
                              fontSize: 14,
                              color: MaternityTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          _buildTextField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          
                          _buildTextField(
                            controller: passwordController,
                            label: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Forgot password logic
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: MaternityTheme.primaryPink,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              ),
                              child: const Text("Forgot Password?"),
                            ),
                          ),

                          // Added Login label
                          const SizedBox(height: 8),
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 252, 252, 252),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          _buildGradientButton(
                            onPressed: _isLoading ? null : handleLogin,
                            label: "Login",
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MaternityTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: MaternityTheme.lightPink.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: MaternityTheme.textLight,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to signup
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: MaternityTheme.primaryPink,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              "Create Account",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: MaternityTheme.lightPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MaternityTheme.lightPink.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          color: MaternityTheme.textDark,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: MaternityTheme.textLight,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 231, 154, 200)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color.fromARGB(255, 250, 250, 250).withOpacity(0.7),
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
  
  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required String label,
    bool isLoading = false,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: onPressed == null
              ? [Colors.grey.shade300, Colors.grey.shade400]
              : [
                  MaternityTheme.primaryPink,
                  MaternityTheme.primaryPink.withOpacity(0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: MaternityTheme.primaryPink.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}