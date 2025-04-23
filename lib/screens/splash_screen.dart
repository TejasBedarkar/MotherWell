// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/screens/authpage.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Setup fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Setup scale animation
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    // Start animation
    _controller.forward();
    
    // Navigate to AuthScreen after delay
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MaternityTheme.primaryPink.withOpacity(0.8),
              MaternityTheme.primaryPink.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: MaternityTheme.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/icons/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // App name
                        Text(
                          'MotherWell',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: MaternityTheme.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // App tagline
                        Text(
                          'Your Pregnancy Companion',
                          style: TextStyle(
                            fontSize: 16,
                            color: MaternityTheme.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Loading indicator
                        Container(
                          width: 180,
                          height: 6,
                          decoration: BoxDecoration(
                            color: MaternityTheme.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(seconds: 4),
                            curve: Curves.easeInOut,
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: MaternityTheme.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Version text
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: MaternityTheme.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}