import 'package:flutter/material.dart';
import 'package:wedding_market/Screens/Home%20Screen/home_screen.dart';
import 'APiServices/api_services.dart';
import 'Screens/login_page.dart';


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
      home: HomeScreen(apiService: apiService),

    );
  }
}
