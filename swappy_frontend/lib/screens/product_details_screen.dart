import 'package:flutter/material.dart';
import '../components/swap_form_page.dart';
import '../models/product_model.dart';
import '../models/swap_model.dart';
import '../services/product_service.dart';
import '../services/swap_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductService _productService = ProductService();
  final SwapService _swapService = SwapService();

  Product? product;
  List<Swap> swaps = [];
  bool isLoading = true;
  bool hasError = false;

  int? currentUserId = 20; // Replace with actual logic to fetch current user ID

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _fetchSwaps();
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
        swaps = fetchedSwaps;
      });
    } catch (e) {
      print('Error fetching swaps: $e');
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

    bool isSeller = product!.seller?.id == currentUserId;

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
            // Conditionally Render Swap List Section
            if (swaps.isNotEmpty) ...[
              const Text(
                'Your Swap Offers for this Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: swaps.length,
                  itemBuilder: (context, index) {
                    final swap = swaps[index];
                    return Card(
                      child: ListTile(
                        leading: swap.imageUrl != null
                            ? Image.network(
                          swap.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.image, size: 50),
                        title: Text(swap.title ?? 'Untitled Swap'),
                        subtitle: Text(swap.description ?? 'No description provided'),
                        trailing: Text(
                          '\$${swap.estimatedRetailPrice?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Create Swap Offer Button
            if (!isSeller)
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
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Create Swap Offer'),
              ),
          ],
        ),
      ),
    );
  }
}
