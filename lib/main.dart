import 'package:flutter/material.dart';
import 'package:shokti/Onboardpage.dart';
import 'package:shokti/views/OnBoardPage.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; //

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env"); //load env file
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

/// Splash Screen with green gradient first, then logo fade-in
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLogo = false;

  @override
  void initState() {
    super.initState();

    // Wait 2 seconds, then show logo
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showLogo = true;
      });
    });

    // After 4s seconds total, navigate to onboarding (new view)
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage(title: 'Home page')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 2, 63, 2),
              Color.fromARGB(255, 3, 54, 3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: showLogo ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: Image.asset(
              'assets/images/Logo.png',
              width: 300,
              height: 300,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
