import 'package:flutter/material.dart';

class OffersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: Center(
        child: Text(
          'Your offers will appear here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
