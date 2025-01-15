import 'dart:ui';

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'add_product_screen.dart';
import 'offers_screen.dart'; // Replace with your OffersScreen
import 'profile_screen.dart'; // Replace with your ProfileScreen
import '../services/user_service.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  String? _profilePictureUrl;
  final UserService _userService = UserService();

  final List<Widget> _pages = [
    HomeScreen(), // Home page
    SearchScreen(), // Search page
    AddProductScreen(), // Add product page
    OffersScreen(), // Offers page
    ProfileScreen(), // Profile page
  ];

  final List<String> _iconPathsSelected = [
    'assets/icons/home_selected.png',
    'assets/icons/search_selected.png',
    'assets/icons/add_selected.png',
    'assets/icons/offers_selected.png',
    'assets/icons/profile_selected.png',
  ];

  final List<String> _iconPathsUnselected = [
    'assets/icons/home_unselected.png',
    'assets/icons/search_unselected.png',
    'assets/icons/add_unselected.png',
    'assets/icons/offers_unselected.png',
    'assets/icons/profile_unselected.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await _userService.getUserProfile();
      print('User Profile Response: $userProfile'); // Debug log entire response
      setState(() {
        _profilePictureUrl = userProfile['profilePictureURL'];
      });
    } catch (e) {
      print("Error fetching profile picture: $e");
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Stack(
        children: [
          // Blur effect for the navigation bar area

          // Actual navigation bar
          BottomAppBar(
            color: Colors.transparent, // Transparent to allow the blur to show
            elevation: 0,
            child: SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_pages.length, (index) {
                  final isSelected = _currentIndex == index;
                  if (index != _pages.length - 1) {
                    // Non-profile tabs
                    return GestureDetector(
                      onTap: () => _onTabTapped(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            isSelected
                                ? _iconPathsSelected[index]
                                : _iconPathsUnselected[index],
                            height: 22,
                            width: 22,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    );
                  } else {
                    // Profile tab with dynamic image and stroke
                    return GestureDetector(
                      onTap: () => _onTabTapped(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black87, width: 2)
                                  : null,
                              image: _profilePictureUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_profilePictureUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey[300],
                            ),
                            child: _profilePictureUrl == null
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    );
                  }
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
