import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Check if product.id is null before navigating
        if (product.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(productId: product.id!),
            ),
          );
        } else {
          // Show a message or handle the case where product.id is null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid product ID')),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            product.productImage != null
                ? Image.network(
              product.productImage!,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 300,
              color: Colors.grey[300],
              child: const Center(child: Text("No Image Available")),
            ),
            // Product Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.productTitle ?? "Untitled Product",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
