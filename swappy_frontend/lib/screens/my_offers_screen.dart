import 'package:flutter/material.dart';
import '../models/swap_model.dart';
import '../services/swap_service.dart';

class MyOffersScreen extends StatefulWidget {
  @override
  _MyOffersScreenState createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final SwapService _swapService = SwapService();
  late Future<List<Swap>> _buyerSwaps;

  @override
  void initState() {
    super.initState();
    _buyerSwaps = _swapService.fetchSwapsForBuyer();
  }

  Future<void> _cancelSwap(int swapId) async {
    try {
      await _swapService.cancelSwap(swapId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap cancelled successfully')),
      );
      setState(() {
        _buyerSwaps = _swapService.fetchSwapsForBuyer();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel swap: $e')),
      );
    }
  }

  void _showCancelWarning(int swapId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Swap'),
          content: const Text('Are you sure you want to cancel this swap?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _cancelSwap(swapId); // Cancel the swap
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'denied':
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Swaps'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Swap>>(
        future: _buyerSwaps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have not made any offers yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final swaps = snapshot.data!;
          return ListView.builder(
            itemCount: swaps.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final swap = swaps[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Swap Status
                      Text(
                        'Status: ${swap.swapStatus}',
                        style: TextStyle(
                          color: _getStatusColor(swap.swapStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Products Section
                      Row(
                        children: [
                          // Product You Want to Swap
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Your Item',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    swap.swapProductImage,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  swap.swapProductTitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          const SizedBox(width: 16),
                          const Icon(Icons.swap_horiz, size: 32, color: Colors.grey),
                          const SizedBox(width: 16),

                          // Product You Want to Buy
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Desired Item',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    swap.product.productImage!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  swap.product.productTitle!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Cancel Button
                      if (swap.swapStatus.toLowerCase() != 'cancelled' && swap.swapStatus.toLowerCase() != 'accepted' && swap.swapStatus.toLowerCase() != 'denied' )
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _showCancelWarning(swap.id),
                          ),
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
