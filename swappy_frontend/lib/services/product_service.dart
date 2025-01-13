import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  Future<List<Product>> fetchProducts({required int page, required int pageSize}) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?page=$page&size=$pageSize'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Map each item in the list to a Product object
        return data.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid token');
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }




  Future<Product> fetchProductDetails(int productId) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to fetch product details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow; // Propagate the error to the caller
    }
  }
}
