import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_application_1/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the Login page after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient color
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey[100]!, Colors.grey[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Center content with logo having rounded edges
          Center(
            child: Container(
              width:
                  180, // Adjust the size of the container to control image size
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Rounded edges
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded image edges
                child: Image.asset(
                  'assets/images/nari.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
