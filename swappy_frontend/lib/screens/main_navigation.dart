import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'add_product_screen.dart';
import 'offers_screen.dart'; // Replace with your OffersScreen
import 'profile_screen.dart'; // Replace with your ProfileScreen
import '../services/user_service.dart';
import '../services/swap_service.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  String? _profilePictureUrl;
  bool _hasUnseenOffers = false;
  Timer? _timer;
  final UserService _userService = UserService();
  final SwapService _swapService = SwapService();

  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    AddProductScreen(),
    OffersScreen(),
    ProfileScreen(),
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
    _fetchUnseenOffers();
    _startUnseenOffersTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await _userService.getUserProfile();
      setState(() {
        _profilePictureUrl = userProfile['profilePictureURL'];
      });
    } catch (e) {
      print("Error fetching profile picture: $e");
    }
  }

  Future<void> _fetchUnseenOffers() async {
    try {
      final swaps = await _swapService.fetchSwapsForSeller();
      final hasUnseen = swaps.any((swap) => !swap.viewedBySeller);
      setState(() {
        _hasUnseenOffers = hasUnseen;
      });
    } catch (e) {
      print("Error fetching unseen offers: $e");
    }
  }

  void _startUnseenOffersTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchUnseenOffers();
    });
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          height: 90, // Increase height for better spacing
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_pages.length, (index) {
              final isSelected = _currentIndex == index;

              // Notification Bell Tab (Offers Tab)
              if (index == 3) {
                return GestureDetector(
                  onTap: () => _onTabTapped(index),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
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
                          const SizedBox(height: 8), // Add extra spacing below the icon
                        ],
                      ),
                      if (_hasUnseenOffers)
                        Positioned(
                          bottom: 0, // Ensure the dot stays inside the navigation bar
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              } else if (index != _pages.length - 1) {
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
                // Profile tab
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
                              ? Border.all(color: const Color(0xFF201089), width: 2)
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
    );
  }
}
