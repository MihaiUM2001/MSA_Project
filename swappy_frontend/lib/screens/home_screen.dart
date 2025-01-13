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
      print("Loading more products...");
    });

    try {
      final response = await _productService.fetchProducts(page: currentPage, pageSize: pageSize);

      print("API Response: $response");

      final List<Product> newProducts = response['products'];
      final int totalPages = response['totalPages'];

      setState(() {
        allProducts.addAll(newProducts);
        currentPage++;
        hasMore = currentPage < totalPages;
        print("Loaded ${newProducts.length} products, total: ${allProducts.length}");
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
        print("Finished loading");
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
