import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductService _productService = ProductService();
  Product? product;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final fetchedProduct = await _productService.fetchProductDetails(widget.productId);
      setState(() {
        product = fetchedProduct;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error fetching product details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Failed to load product details')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product!.productTitle ?? 'Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            product!.productImage != null
                ? Image.network(
              product!.productImage!,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 300,
              color: Colors.grey[300],
              child: const Center(child: Text('No Image Available')),
            ),
            const SizedBox(height: 16),
            // Product Title
            Text(
              product!.productTitle ?? 'Untitled Product',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Product Views
            Row(
              children: [
                const Icon(Icons.visibility, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${product!.numberOfViews} views',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Product Description
            Text(
              product!.productDescription ?? 'No description available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Seller Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: product!.seller?.profilePictureUrl != null
                      ? NetworkImage(product!.seller!.profilePictureUrl!)
                      : null,
                  child: product!.seller?.profilePictureUrl == null
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  product!.seller?.fullName ?? 'Unknown Seller',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            // Swap Button
            ElevatedButton(
              onPressed: () {
                // Initialize the swap functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Swap initialized')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blue,
              ),
              child: const Text('Start Swap'),
            ),
          ],
        ),
      ),
    );
  }
}
