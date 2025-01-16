import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart'; // For custom icons
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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _fetchCurrentUser(),
        _fetchProductDetails(),
        _fetchSwaps(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final userProfile = await _userService.getUserProfile();
      setState(() {
        currentUserId = userProfile['id']?.toString();
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      final fetchedProduct = await _productService.fetchProductDetails(widget.productId);
      setState(() {
        product = fetchedProduct;
      });
    } catch (e) {
      print('Error fetching product details: $e');
      throw e;
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
      throw e;
    }
  }

  void _openSwapsList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            final Color statusColor;

            switch (swap.swapStatus.toLowerCase()) {
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
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  swap.swapProductImage.isNotEmpty
                      ? Image.network(
                    swap.swapProductImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image, size: 50),
                ],
              ),
              title: Text(swap.swapProductTitle),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(swap.swapProductDescription),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${swap.swapStatus}',
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

    final bool isOwner = currentUserId == product!.seller!.id.toString();
    final bool isSold = product!.isSold ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(product!.productTitle!),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            product!.productImage!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product!.productImage!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
                : Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('No Image Available')),
            ),
            const SizedBox(height: 16),

            // Sold Indicator
            if (isSold)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 24),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This product is sold and no longer available for swaps.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Product Title
            Text(
              product!.productTitle!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Views
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
            if (product!.productDescription!.isNotEmpty)
              _buildSection(
                Feather.file_text,
                'Product Details',
                product!.productDescription!,
              ),

            // Swap Preference
            if (product!.swapPreference != null && product!.swapPreference!.isNotEmpty)
              _buildSection(
                Feather.refresh_ccw,
                'Swap Preference',
                product!.swapPreference!,
              ),

            // Estimated Retail Price
            _buildSection(
              Feather.dollar_sign,
              'Estimated Retail Price',
              'RON ${product!.estimatedRetailPrice?.toStringAsFixed(2)}',
            ),

            // Seller Details
            _buildSection(
              Feather.user,
              'Seller Details',
              Row(
                children: [
                  product!.seller!.profilePictureUrl != null
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(product!.seller!.profilePictureUrl!),
                    radius: 25,
                  )
                      : const CircleAvatar(
                    backgroundColor: const Color(0xFFB7ADFF),
                    child: Icon(Icons.person, size: 30),
                    radius: 25,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.seller!.fullName!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product!.seller!.email!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Swaps (only if not sold)
            if (!isSold && !isOwner && swaps.isNotEmpty)
              GestureDetector(
                onTap: _openSwapsList,
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
                              child: _buildSwapRectangle(swap.swapProductImage),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have offered ${swaps.length} swap(s)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Start Swap Button (only if not sold)
            if (!isSold && !isOwner)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SwapFormPage(
                        productId: widget.productId,
                        sellerId: product!.seller!.id,
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
                ),
                child: const Text(
                  'Start Swap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(IconData icon, String title, dynamic content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content is Widget ? content : Text(content, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwapRectangle(String imageUrl, {double height = 100, double width = 100}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
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
