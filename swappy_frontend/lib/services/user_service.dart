import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "http://10.0.2.2:8000/api/users";



  Future<void> createUser(String fullName, String phoneNumber, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName,
          "phoneNumber": phoneNumber,
          "email": email,
          "password": password,
        }),
      );

      print("Request URL: $baseUrl");
      print("Request Body: ${jsonEncode({
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "email": email,
        "password": password,
      })}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("User created successfully");
      } else {
        throw Exception("Failed to create user: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
      throw Exception("Error creating user: $error");
    }
  }


}
