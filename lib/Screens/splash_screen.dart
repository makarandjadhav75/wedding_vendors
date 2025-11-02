import 'dart:async';
import 'package:flutter/material.dart';
import '../APiServices/api_services.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  final ApiService apiService;
  const SplashScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(apiService: widget.apiService),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.favorite, color: Color(0xFFD6336C), size: 56),
            SizedBox(height: 12),
            Text('WedMatch', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
