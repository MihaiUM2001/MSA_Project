import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/product_details_screen.dart';

class ProductCardSearch extends StatelessWidget {
  final Product product;

  const ProductCardSearch({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: Card(
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
                    backgroundImage: product.sellerProfilePic != null
                        ? NetworkImage(product.sellerProfilePic!)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: product.sellerProfilePic == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  // Seller's Name
                  Expanded(
                    child: Text(
                      product.sellerName ?? "Unknown Seller",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Product Image with Title Overlay
            Stack(
              children: [
                product.productImage != null
                    ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: Image.network(
                    product.productImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: const Center(child: Text("No Image Available")),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.0),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Text(
                      product.productTitle ?? "Untitled Product",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
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
    );
  }
}
