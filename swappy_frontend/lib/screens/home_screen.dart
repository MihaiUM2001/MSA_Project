import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // SliverAppBar with centered logo and left-aligned "For You" title
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Centered Logo with Padding
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24.0), // Adjust top padding
                      child: Image.asset(
                        'assets/images/app_logo.png', // Replace with your logo asset path
                        height: 40, // Adjust the size as needed
                      ),
                    ),
                  ), // Space between logo and "For You"
                  const Text(
                    'For You',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SliverList for the product list
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
              childCount: allProducts.length + 1, // Add an extra item for the loading indicator
            ),
          ),
        ],
      ),
    );
  }





  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
