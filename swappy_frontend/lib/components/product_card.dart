import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Don't render the card if isVisible is false
    if (!(product.isVisible ?? true)) {
      return const SizedBox.shrink(); // Return an empty widget
    }

    return GestureDetector(
      onTap: () {
        // Navigate to product details
        if (product.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(productId: product.id!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid product ID')),
          );
        }
      },
      child: Stack(
        children: [
          Card(
            color: const Color(0xFFF7FBFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 0, // Remove shadow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seller's Info
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      // Seller's Profile Picture
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: product.seller?.profilePictureUrl != null
                            ? NetworkImage(product.seller!.profilePictureUrl!)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: product.seller?.profilePictureUrl == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      // Seller's Name
                      Expanded(
                        child: Text(
                          product.seller?.fullName ?? "Unknown Seller",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Image
                product.productImage != null
                    ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: Image.network(
                    product.productImage!,
                    height: screenWidth, // Match height to screen width
                    width: screenWidth,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  height: screenWidth, // Match height to screen width
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: const Center(child: Text("No Image Available")),
                ),
                // Product Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
                  child: Text(
                    product.productTitle ?? "Untitled Product",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF201089), // Updated color
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  child: Text(
                    product.productDescription ?? "No description available.",
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // "Sold" Banner
          if (product.isSold ?? false)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SWAPPED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
