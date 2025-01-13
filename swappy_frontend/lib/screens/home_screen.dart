import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../components/product_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();

  int currentPage = 0;
  final int pageSize = 10;
  bool isLoading = false;
  bool hasMore = true;
  List<Product> allProducts = [];

  @override
  void initState() {
    super.initState();
    loadMoreProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        loadMoreProducts();
      }
    });
  }

  Future<void> loadMoreProducts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
      print("Loading products for page: $currentPage...");
    });

    try {
      final List<Product> newProducts = await _productService.fetchProducts(page: currentPage, pageSize: pageSize);

      setState(() {
        allProducts.addAll(newProducts);
        currentPage++;

        // Stop loading more if no products are returned
        if (newProducts.length < pageSize) {
          hasMore = false;
        }

        print("Loaded ${newProducts.length} products, total loaded: ${allProducts.length}");
      });
    } catch (e) {
      print('Error loading products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load products')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swappy'),
      ),
      body: allProducts.isEmpty && !isLoading
          ? const Center(child: Text('No products available'))
          : ListView.builder(
        controller: _scrollController,
        itemCount: allProducts.length + 1, // Add an extra item for the loading indicator
        itemBuilder: (context, index) {
          if (index == allProducts.length) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (!hasMore) {
              return const Center(child: Text('No more products to load'));
            } else {
              return const SizedBox.shrink();
            }
          }

          final product = allProducts[index];
          return ProductCard(product: product);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
