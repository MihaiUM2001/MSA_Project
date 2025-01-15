import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  /// Registers a new user
  Future<void> createUser(
      String fullName, String phoneNumber, String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/users'), // POST /api/users
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "fullName": fullName,
          "phoneNumber": phoneNumber,
          "email": email,
          "password": password,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("User created successfully.");
      } else {
        _handleErrorResponse(response);
      }
    } catch (error) {
      throw Exception("Failed to create user: ${_extractErrorMessage(error)}");
    }
  }

  /// Logs in a user
  Future<void> loginUser(String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth'), // Assuming the login endpoint is /api/auth
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final token = responseData['token'];

        if (token != null) {
          await secureStorage.write(key: 'token', value: token);
          print("Token saved: $token");
        } else {
          throw Exception("Invalid response: No token received");
        }
      } else {
        _handleErrorResponse(response);
      }
    } catch (error) {
      throw Exception("Failed to log in: ${_extractErrorMessage(error)}");
    }
  }

  /// Logs out a user by deleting the token
  Future<void> logoutUser() async {
    try {
      await secureStorage.delete(key: 'token');
      print("User logged out successfully.");
    } catch (error) {
      throw Exception("Failed to log out: ${_extractErrorMessage(error)}");
    }
  }

  /// Validates if a user is logged in by checking the token
  Future<bool> isLoggedIn() async {
    try {
      final token = await secureStorage.read(key: 'token');
      if (token == null) {
        return false;
      }
      return await validateToken();
    } catch (error) {
      print("Error checking login status: $error");
      return false;
    }
  }

  /// Validates the token by making a call to the `/auth/validate` endpoint
  Future<bool> validateToken() async {
    final token = await secureStorage.read(key: 'token');

    if (token == null) {
      return false; // No token found
    }

    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true; // Token is valid
      } else {
        await secureStorage.delete(key: 'token'); // Remove invalid token
        return false;
      }
    } catch (error) {
      print("Error validating token: $error");
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'), // Replace with your profile endpoint
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("getUserProfile Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch profile data');
    }
  }

  /// Handles HTTP error responses
  void _handleErrorResponse(http.Response response) {
    try {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      final errorMessage = errorResponse['message'] ?? 'Unknown error occurred';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Unexpected error: ${response.body}");
    }
  }

  /// Extracts the error message from an exception
  String _extractErrorMessage(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}
