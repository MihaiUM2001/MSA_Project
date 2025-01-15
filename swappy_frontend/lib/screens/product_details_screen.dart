import 'dart:ui';

import 'package:flutter/material.dart';
import '../components/swap_form_page.dart';
import '../models/product_model.dart';
import '../models/swap_model.dart';
import '../services/product_service.dart';
import '../services/swap_service.dart';
import '../services/user_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductService _productService = ProductService();
  final SwapService _swapService = SwapService();
  final UserService _userService = UserService();

  Product? product;
  List<Swap> swaps = [];
  bool isLoading = true;
  bool hasError = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchProductDetails();
    _fetchSwaps();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final userProfile = await _userService.getUserProfile();
      print("User Profile: $userProfile"); // Debug log to confirm data
      setState(() {
        currentUserId = userProfile['id'].toString(); // Convert ID to string
      });
      print("Current User ID: $currentUserId");
    } catch (e) {
      print('Error fetching user profile: $e');
    }
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

  Future<void> _fetchSwaps() async {
    try {
      final fetchedSwaps = await _swapService.fetchSwapsForProduct(widget.productId);
      setState(() {
        swaps = fetchedSwaps.reversed.toList();
      });
    } catch (e) {
      print('Error fetching swaps: $e');
    }
  }

  void _openSwapsList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ListView.builder(
              itemCount: swaps.length,
              itemBuilder: (context, index) {
                final swap = swaps[index];
                final Color statusColor;

                // Determine the color based on the status
                switch (swap.status?.toLowerCase()) {
                  case 'pending':
                    statusColor = Colors.orange;
                    break;
                  case 'accepted':
                    statusColor = Colors.green;
                    break;
                  case 'denied':
                  case 'cancelled':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status color indicator
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Swap image
                      swap.imageUrl != null
                          ? Image.network(
                        swap.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.image, size: 50),
                    ],
                  ),
                  title: Text(swap.title ?? 'Untitled Swap'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(swap.description ?? 'No description provided'),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${swap.status ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print current user ID and product seller ID
    print("Current User ID: $currentUserId");
    print("Product Seller ID: ${product?.seller?.id}");

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

    // Check if the current user owns the product
    final bool isOwner = currentUserId != null &&
        product!.seller?.id != null &&
        currentUserId == product!.seller!.id.toString();

    // Debug: Print whether the user is the owner
    print("Is Owner: $isOwner");

    return Scaffold(
      appBar: AppBar(
        title: Text(product!.productTitle ?? 'Product Details'),
      ),
      body: SingleChildScrollView(
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
            // Product Details
            if (product!.productDescription != null) ...[
              const Text(
                'Product Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product!.productDescription!,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
            ],
            // Seller Details
            if (product!.seller != null) ...[
              const Text(
                'Seller Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  product!.seller!.profilePictureUrl != null
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(product!.seller!.profilePictureUrl!),
                    radius: 25,
                  )
                      : const CircleAvatar(
                    child: Icon(Icons.person, size: 30),
                    radius: 25,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.seller!.fullName ?? 'Unknown Seller',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product!.seller!.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Active Swaps Preview
            if (!isOwner && swaps.isNotEmpty)
              GestureDetector(
                onTap: () => _openSwapsList(),
                child: Row(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 150,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(
                          swaps.length.clamp(0, 3),
                              (index) {
                            final swap = swaps[index];
                            return Positioned(
                              top: index * 10.0,
                              left: index * 20.0,
                              child: _buildSwapRectangle(swap.imageUrl),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have ${swaps.length} active swap(s)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Start Swap Button
            if (!isOwner)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SwapFormPage(
                        productId: widget.productId,
                        sellerId: product!.seller!.id!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFF201089),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Start Swap',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }




  Widget _buildSwapRectangle(String? imageUrl, {double height = 100, double width = 100}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
        image: imageUrl != null
            ? DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }
}
