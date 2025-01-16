import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import 'product_details_screen.dart';
import 'edit_product_screen.dart'; // Create this screen for editing product details

class MyProductsScreen extends StatefulWidget {
  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _userProducts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userProducts = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      return await _productService.fetchUserProducts();
    } catch (e) {
      print("Error fetching user's products: $e");
      return [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
      ),
      body: FutureBuilder<List<Product>>(
        future: _userProducts,
        builder: (context, snapshot) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load your products. Please try again.',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No products found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                color: const Color(0xFFF7FBFF),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.productImage != null
                        ? Image.network(
                      product.productImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 30),
                    ),
                  ),
                  title: Text(
                    product.productTitle ?? "Untitled Product",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    product.productDescription ?? "No description available.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductScreen(productId: product.id!),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(productId: product.id!),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
