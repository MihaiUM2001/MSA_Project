import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Image.asset(
        'assets/images/app_logo.png',
        height: 40,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}
