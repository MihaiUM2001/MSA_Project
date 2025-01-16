import 'package:flutter/material.dart';
import '../components/product_card_skeleton.dart';
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
    });

    try {
      final List<Product> newProducts =
      await _productService.fetchProducts(page: currentPage, pageSize: pageSize);

      setState(() {
        allProducts.addAll(newProducts);
        currentPage++;

        if (newProducts.length < pageSize) {
          hasMore = false;
        }
      });
    } catch (e) {
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
          // SliverAppBar
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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 29.0),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        height: 35,
                      ),
                    ),
                  ),
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
          // Product List
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index < allProducts.length) {
                  final product = allProducts[index];
                  return ProductCard(product: product);
                } else if (isLoading) {
                  // Show multiple skeleton cards
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
              childCount: allProducts.length + (isLoading ? 1 : 0),
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
