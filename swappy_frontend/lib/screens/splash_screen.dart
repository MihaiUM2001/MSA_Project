import 'package:flutter/material.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final isLoggedIn = await _userService.isLoggedIn();
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _isLoading = false; // Stop loading to show pre-login screen
        });
      }
    } catch (e) {
      print('Error checking authentication: $e');
      setState(() {
        _isLoading = false; // Stop loading in case of an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.7,
            colors: [
              Color(0xFF6E58FF), // Inner color
              Color(0xFFF7FBFF), // Outer color
            ],
            stops: [0.5, 1.0], // Adjust where the colors transition
          ),
        ),
        child: Column(
          children: [
            // Logo Section Positioned at the Top
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0), // Adjust for top spacing
                child: Image.asset(
                  'assets/images/app_logo.png', // Replace with your logo path
                  height: 40, // Smaller logo size
                ),
              ),
            ),

            // Center the text and buttons using Expanded widgets
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    "EXCHANGE WHAT YOU HAVE FOR WHAT YOU NEED, INSTANTLY!",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w900,
                      color: Colors.white, // Adjust text color for visibility
                    ),
                  ),
                ),
              ),
            ),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  // Log In Button
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE6E6E6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF201089),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Color(0xFF201089)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF201089),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
