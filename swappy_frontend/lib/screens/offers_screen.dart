import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/swap_service.dart';
import '../models/swap_model.dart';
import 'swap_details_screen.dart';

class OffersScreen extends StatefulWidget {
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final SwapService _swapService = SwapService();
  late Future<List<Swap>> _receivedSwaps;
  late Future<List<Swap>> _sentSwapsUpdates;

  @override
  void initState() {
    super.initState();
    _fetchSwaps();
  }

  void _fetchSwaps() {
    _receivedSwaps = _swapService.fetchSwapsForSeller().then((swaps) {
      return swaps.where((swap) => swap.swapStatus.toLowerCase() == 'pending').toList();
    });

    _sentSwapsUpdates = _swapService.fetchSwapsForBuyer().then((swaps) {
      return swaps.where((swap) => swap.swapStatus.toLowerCase() != 'pending').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
                    'Notifications',
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
          _buildSwapSection('Offers You Received', _receivedSwaps, disableTap: false),
          _buildSwapSection('Your Offer Updates', _sentSwapsUpdates, disableTap: true),
        ],
      ),
    );
  }

  Widget _buildSwapSection(String title, Future<List<Swap>> swapsFuture, {required bool disableTap}) {
    return FutureBuilder<List<Swap>>(
      future: swapsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => const NotificationSkeletonCard(),
              childCount: 6,
            ),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No $title',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        } else {
          final swaps = snapshot.data!;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final swap = swaps[index];
                return NotificationCard(
                  buyerName: disableTap ? 'You' : swap.buyer?.fullName ?? 'Unknown Buyer',
                  sellerName: swap.seller?.fullName ?? 'Unknown Seller',
                  productTitle: swap.product.productTitle!,
                  sellerProductImage: swap.product.productImage!,
                  buyerProductImage: swap.swapProductImage,
                  buyerProfileImage: swap.buyer?.profilePictureUrl ?? '',
                  isUnseen: !disableTap && !swap.viewedBySeller,
                  status: disableTap ? swap.swapStatus : null,
                  onTap: disableTap
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SwapDetailsScreen(swapId: swap.id),
                      ),
                    );
                  },
                );
              },
              childCount: swaps.length,
            ),
          );
        }
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String sellerName;
  final String buyerName;
  final String productTitle;
  final String sellerProductImage;
  final String buyerProductImage;
  final String buyerProfileImage;
  final bool isUnseen;
  final String? status;
  final VoidCallback? onTap;

  const NotificationCard({
    Key? key,
    required this.sellerName,
    required this.buyerName,
    required this.productTitle,
    required this.sellerProductImage,
    required this.buyerProductImage,
    required this.buyerProfileImage,
    required this.isUnseen,
    this.status,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the status text
    String statusText;
    if (status != null) {
      if (status!.toLowerCase() == 'cancelled') {
        statusText = 'You cancelled your swap offer';
      } else {
        statusText = 'Status: $status';
      }
    } else {
      statusText = 'New offer from $buyerName';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFFF7FBFF),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          sellerProductImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isUnseen)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          productTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          buyerProductImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFDFDAFD),
                          backgroundImage: buyerProfileImage.isNotEmpty
                              ? NetworkImage(buyerProfileImage)
                              : null,
                          child: buyerProfileImage.isEmpty
                              ? const Icon(Icons.person, size: 16)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xffdee2e5),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSkeletonCard extends StatelessWidget {
  const NotificationSkeletonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: const Color(0xFFF7FBFF),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Placeholder for Seller's product image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Placeholder for Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 150,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Placeholder for Buyer's product image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xffdee2e5),
            ),
          ],
        ),
      ),
    );
  }
}
