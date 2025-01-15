import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/user_service.dart';
import 'my_products_screen.dart'; // Create this screen for your own products
import 'my_offers_screen.dart'; // Create this screen for your own offers

class ProfileScreen extends StatelessWidget {
  final UserService _userService = UserService();

  Future<void> _logout(BuildContext context) async {
    await _userService.logoutUser();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userService.getUserProfile(), // Implement getUserProfile in UserService
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                'Failed to load profile. Please try again.',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          );
        }

        final profileData = snapshot.data!;
        final String fullName = profileData['fullName'] ?? 'Unknown User';
        final String? profilePicture = profileData['profilePicture'];

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePicture != null
                      ? NetworkImage(profilePicture)
                      : null,
                  child: profilePicture == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),

                // Full Name
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // My Products Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyProductsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('My Products'),
                ),
                const SizedBox(height: 16),

                // My Offers Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyOffersScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('My Offers'),
                ),
                const SizedBox(height: 32),

                // Log Out Button
                ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Log Out'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
