import 'package:flutter/material.dart';
import 'APiServices/api_services.dart';
import 'Screens/splash_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Configure your API base URL here:
  static final ApiService apiService =
  ApiService(baseUrl: 'http://192.168.1.101:3030');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wedding_planer',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(apiService: apiService),

    );
  }
}
