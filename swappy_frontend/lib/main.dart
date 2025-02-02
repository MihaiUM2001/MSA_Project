import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swappy_frontend/screens/register_screen.dart';
import 'package:swappy_frontend/screens/login_screen.dart';
import 'package:swappy_frontend/screens/main_navigation.dart';
import 'package:swappy_frontend/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF7FBFF), primarySwatch: Colors.blue),
      home: SplashScreen(), // Start with SplashScreen
      routes: {
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => MainNavigation(),
      },
    );
  }
}
