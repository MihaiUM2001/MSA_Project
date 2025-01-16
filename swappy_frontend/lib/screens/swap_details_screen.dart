import 'package:flutter/material.dart';
import '../models/swap_model.dart';
import '../services/swap_service.dart';

class SwapDetailsScreen extends StatefulWidget {
  final int swapId;

  const SwapDetailsScreen({Key? key, required this.swapId}) : super(key: key);

  @override
  _SwapDetailsPageState createState() => _SwapDetailsPageState();
}

class _SwapDetailsPageState extends State<SwapDetailsScreen> {
  final SwapService _swapService = SwapService();
  Swap? swap;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSwapDetails();
  }

  Future<void> _fetchSwapDetails() async {
    try {
      final fetchedSwap = await _swapService.fetchSwapById(widget.swapId);
      setState(() {
        swap = fetchedSwap;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error fetching swap details: $e');
    }
  }

  Future<void> _handleAcceptSwap() async {
    try {
      await _swapService.acceptSwap(widget.swapId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap accepted successfully!')),
      );
      Navigator.pop(context, true); // Navigate back after accepting
    } catch (e) {
      print('Error accepting swap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept swap. Please try again.')),
      );
    }
  }

  Future<void> _handleDenySwap() async {
    try {
      await _swapService.denySwap(widget.swapId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap denied successfully!')),
      );
      Navigator.pop(context, true); // Navigate back after denying
    } catch (e) {
      print('Error denying swap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to deny swap. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trade Offer'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || swap == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trade Offer'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: Text('Failed to load swap details.'),
        ),
      );
    }

    final double priceDifference = (swap!.product.estimatedRetailPrice! - swap!.estimatedRetailPrice).abs();
    final bool hasSignificantDifference = priceDifference >= (swap!.product.estimatedRetailPrice! * 0.25);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Offer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You Give',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    swap!.product.productImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap!.product.productTitle!,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estimated Price: RON ${swap!.product.estimatedRetailPrice?.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(Icons.swap_horiz, size: 24, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'You Receive',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    swap!.swapProductImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap!.swapProductTitle,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estimated Price: RON ${swap!.estimatedRetailPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: swap!.buyer?.profilePictureUrl != null
                                ? NetworkImage(swap!.buyer!.profilePictureUrl!)
                                : null,
                            child: swap!.buyer?.profilePictureUrl == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            swap!.buyer?.fullName ?? 'Unknown Buyer',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasSignificantDifference)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow[700]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.yellow, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'There is a significant price difference of RON ${priceDifference.toStringAsFixed(2)} between the two items.',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleAcceptSwap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF201089),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Accept Swap',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleDenySwap,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Deny Swap',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
