import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://10.0.2.2:8000/api";
  // final String baseUrl = "http://192.168.0.248:8000/api";

  Future<String?> getToken() async {
    // Retrieve the saved token
    return await secureStorage.read(key: 'token');
  }

  Future<Map<String, dynamic>> fetchProducts({required int page, required int pageSize}) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/products?page=$page&size=$pageSize'),
      headers: {
        'Authorization': 'Bearer $token', // Include the Bearer token
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Extract the content (products) and pagination metadata
      final List<dynamic> content = data['content'];
      final int totalPages = data['totalPages'];
      final int totalElements = data['totalElements'];

      return {
        'products': content.map((json) => Product.fromJson(json)).toList(),
        'totalPages': totalPages,
        'totalElements': totalElements,
      };
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid token');
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> fetchProductDetails(int productId) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found');
    }

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
      throw Exception('Failed to fetch product details');
    }
  }
}
