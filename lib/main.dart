import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:fitness_dashboard_ui/screens/splash_screen.dart';
import 'package:fitness_dashboard_ui/screens/main_screen.dart';
import 'package:fitness_dashboard_ui/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_dashboard_ui/screens/authpage.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with your configuration
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDAtl4_RKdLPHc64uo-ySJZt227V-oLcns",
      authDomain: "motherwell-9b7cc.firebaseapp.com",
      databaseURL: "https://motherwell-9b7cc-default-rtdb.firebaseio.com",
      projectId: "motherwell-9b7cc",
      storageBucket: "motherwell-9b7cc.appspot.com",
      messagingSenderId: "169196605471",
      appId: "1:169196605471:web:196a6fd66c68847af1052a",
    ),
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'MotherWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: MaternityTheme.primaryPink,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Nunito', // Make sure this font is added to your pubspec.yaml
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: MaternityTheme.primaryPink,
          secondary: MaternityTheme.primaryPink.withOpacity(0.7),
          surface: MaternityTheme.white,
          background: MaternityTheme.white,
        ),
        textTheme: TextTheme(
          // Using the current naming conventions for TextTheme
          displayLarge: TextStyle(
            color: MaternityTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: MaternityTheme.textDark,
          ),
          bodyMedium: TextStyle(
            color: MaternityTheme.textLight,
          ),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: MaternityTheme.primaryPink,
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: MaternityTheme.primaryPink,
          secondary: MaternityTheme.primaryPink.withOpacity(0.7),
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: MaternityTheme.white,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: MaternityTheme.white,
          ),
          bodyMedium: TextStyle(
            color: MaternityTheme.white.withOpacity(0.7),
          ),
        ),
      ),
      // This is where we use the themeMode getter from ThemeProvider
      themeMode: themeProvider.themeMode,
      home: SplashScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: MaternityTheme.primaryPink,
            ),
          );
        }
        
        // User is logged in
        if (snapshot.hasData) {
          return const MainScreen();
        }
        
        // User is not logged in
        return const AuthScreen();
      },
    );
  }
}