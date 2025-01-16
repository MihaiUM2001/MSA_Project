import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/swap_model.dart';

class SwapService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  // Fetch a specific swap by ID
  Future<Swap> fetchSwapById(int swapId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/swaps/$swapId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Swap.fromJson(data);
      } else {
        throw Exception('Failed to fetch swap. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching swap: $e');
    }
  }

  Future<void> denySwap(int swapId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/swaps/$swapId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"swapStatus": "DENIED"}),
      );

      if (response.statusCode == 200) {
        print('Swap offer cancelled successfully.');
      } else {
        throw Exception('Failed to cancel swap offer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cancelling swap offer: $e');
      throw Exception('Error cancelling swap offer');
    }
  }

  Future<void> acceptSwap(int swapId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/swaps/$swapId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"swapStatus": "ACCEPTED"}),
      );

      if (response.statusCode == 200) {
        print('Swap offer cancelled successfully.');
      } else {
        throw Exception('Failed to cancel swap offer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cancelling swap offer: $e');
      throw Exception('Error cancelling swap offer');
    }
  }

  Future<List<Swap>> fetchSwapsForBuyer() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/swaps/buyer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Swap.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch swaps for buyer. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching swaps for buyer: $e');
    }
  }


  Future<void> cancelSwap(int swapId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/swaps/$swapId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"swapStatus": "CANCELLED"}),
      );

      if (response.statusCode == 200) {
        print('Swap offer cancelled successfully.');
      } else {
        throw Exception('Failed to cancel swap offer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cancelling swap offer: $e');
      throw Exception('Error cancelling swap offer');
    }
  }

  Future<void> submitSwap({
    required int productId,
    required int sellerId,
    required String imageUrl,
    required String title,
    required String description,
    required double estimatedRetailPrice,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/swaps'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'productId': productId,
          'sellerId': sellerId,
          'swapProductImage': imageUrl,
          'swapProductTitle': title,
          'swapProductDescription': description,
          'estimatedRetailPrice': estimatedRetailPrice,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit swap. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting swap: $e');
    }
  }

  Future<List<Swap>> fetchSwapsForProduct(int productId) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/swaps/product/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response Body: ${response.body}'); // Debugging response

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Swap.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch swaps. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching swaps: $e');
    }
  }

  Future<List<Swap>> fetchSwapsForSeller() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/swaps/seller'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Swap.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch swaps for seller. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching swaps for seller: $e');
    }
  }
}
