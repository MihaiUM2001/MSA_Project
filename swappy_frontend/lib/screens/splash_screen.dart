import 'package:flutter/material.dart';
import 'package:swappy_frontend/services/user_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true; // To manage the loading state

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final isLoggedIn = await _userService.isLoggedIn();
      if (isLoggedIn) {
        // Navigate to Home if logged in
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Navigate to Login if not logged in
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Handle errors gracefully
      print('Error checking authentication: $e');
      Navigator.pushReplacementNamed(context, '/login');
    } finally {
      setState(() {
        _isLoading = false; // Ensure loading ends
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(), // Show loading spinner
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8E9EFC), // Gradient start color
              Colors.white, // Gradient end color
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SizedBox(height: 20),

            // App Name
            Text(
              "Swappy",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A3A3A), // Text color
              ),
            ),
            SizedBox(height: 20),

            // Tagline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "EXCHANGE WHAT YOU HAVE FOR WHAT YOU NEED, INSTANTLY!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A3A3A),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  // Log In Button
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF3A3A3A)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF3A3A3A),
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Color(0xFF3A3A3A)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Register Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3A3A3A), // Button color
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
