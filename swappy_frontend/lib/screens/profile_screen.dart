import 'package:flutter/material.dart';
import '../components/duolingo_button.dart';
import '../services/user_service.dart';
import 'my_products_screen.dart';
import 'my_offers_screen.dart';
import 'edit_profile_screen.dart'; // Import the Edit Profile Screen

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  String? _profilePictureUrl;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await _userService.getUserProfile();
      setState(() {
        _profilePictureUrl = userProfile['profilePictureURL'];
        _fullName = userProfile['fullName'] ?? 'Unknown User';
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _userService.logoutUser();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF201089); // Primary color// Accent color
    final Color backgroundColor = const Color(0xFFF7FBFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar with Profile Info
          SliverAppBar(
            backgroundColor: primaryColor,
            expandedHeight: 200,
            floating: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _profilePictureUrl != null
                              ? NetworkImage(_profilePictureUrl!)
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: _profilePictureUrl == null
                              ? const Icon(Icons.person, size: 40, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _fullName ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Buttons and Profile Options
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  DuolingoButton(
                    text: 'My Products',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyProductsScreen()),
                      );
                    },
                    // Duolingo green start
                    isSolidColor: true, // Solid color like the screenshot
                    startColor:  const Color(0xFF201089),// Gradient style // Solid color like the screenshot // Duolingo green end
                  ),
                  const SizedBox(height: 16),
                  DuolingoButton(
                    text: 'My Swaps',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyOffersScreen()),
                      );
                    },
                    // Duolingo green start
                    isSolidColor: true, // Solid color like the screenshot
                    startColor:  const Color(0xFF201089),// Gradient style // Solid color like the screenshot // Duolingo green end
                  ),
                  const SizedBox(height: 16),
                  DuolingoButton(
                    text: 'Edit Profile',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            fullName: _fullName,
                            profilePictureUrl: _profilePictureUrl,
                          ),
                        ),
                      );
                    },
                    // Duolingo green start
                    isSolidColor: true, // Solid color like the screenshot
                    startColor:  Colors.green,// Gradient style // Solid color like the screenshot // Duolingo green end
                  ),
                  const SizedBox(height: 32),
                  DuolingoButton(
                    text: 'Log Out',
                    onPressed: () => _logout(context),
                    // Duolingo green start
                    isSolidColor: true, // Solid color like the screenshot
                    startColor:  Colors.red[400],// Gradient style // Solid color like the screenshot // Duolingo green end
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
