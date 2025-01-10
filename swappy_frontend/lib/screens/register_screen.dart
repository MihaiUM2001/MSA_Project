import 'package:flutter/material.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Full Name Field
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(labelText: "Full Name"),
                  keyboardType: TextInputType.name,
                  validator: (value) => value!.isEmpty ? "Enter your full name" : null,
                ),
                SizedBox(height: 10),

                // Phone Number Field
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your phone number";
                    } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                      return "Enter a valid phone number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Email Field
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? "Enter a valid email" : null,
                ),
                SizedBox(height: 10),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                ),
                SizedBox(height: 20),

                // Register Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await userService.createUser(
                          fullNameController.text,
                          phoneController.text,
                          emailController.text,
                          passwordController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User registered successfully")),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      } catch (error) {
                        // Display the error message cleanly
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    }
                  },
                  child: Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
