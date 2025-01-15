import 'package:flutter/material.dart';

class MyProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: Center(
        child: Text(
          'Your products will appear here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
