import 'package:flutter/material.dart';
import '../components/product_card_skeleton.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../components/product_card.dart';
import 'chat_list_screen.dart';

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
    });

    try {
      final List<Product> newProducts = await _productService.fetchProducts(page: currentPage, pageSize: pageSize);

      setState(() {
        if (newProducts.isNotEmpty) {
          allProducts.addAll(newProducts.where((product) => product.isVisible!).toList());
          currentPage++;
        } else {
          hasMore = false;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load products')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Logo
            Image.asset(
              'assets/images/app_logo.png',
              height: 35,
            ),
            // Messages Button
            IconButton(
              icon: const Icon(Icons.message, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (allProducts.isEmpty && isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (index < allProducts.length) {
                  final product = allProducts[index];
                  return ProductCard(product: product);
                } else if (isLoading) {
                  return Column(
                    children: List.generate(
                      6, // Number of skeleton cards to show
                          (index) => const ProductSkeletonCard(),
                    ),
                  );
                } else if (!hasMore) {
                  return const Center(child: Text('No more products to load'));
                } else {
                  return const SizedBox.shrink();
                }
              },
              childCount: allProducts.isEmpty && isLoading ? 1 : allProducts.length + (isLoading ? 1 : 0),
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
