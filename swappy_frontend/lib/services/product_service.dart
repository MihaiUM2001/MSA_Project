import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
// import 'package:your_app/services/image_upload.dart';

class ProductService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // final String baseUrl = "http://10.0.2.2:8000/api";
  final String baseUrl = "http://192.168.0.248:8000/api";

  Future<String?> getToken() async {
    return secureStorage.read(key: 'token');
  }

  Future<Product> createProduct({
    required String productTitle,
    required String productDescription,
    required String productImage,
    required String swapPreference,
    required double estimatedRetailPrice,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final url = Uri.parse('$baseUrl/products');
      final requestBody = {
        "productTitle": productTitle,
        "productDescription": productDescription,
        "productImage": productImage,
        "swapPreference": swapPreference,
        "estimatedRetailPrice": estimatedRetailPrice,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Product.fromJson(responseData);
      } else {
        throw Exception('Failed to create product. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  Future<List<Product>> fetchProducts({
    required int page,
    required int pageSize,
  }) async {
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
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid token');
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching products: $e');
      rethrow;
    }
  }

/*
  Future<String> uploadProductImage(File file) async {
    final imageUrl = await ImageUploadService().uploadImage(file);
    return imageUrl;
  }
*/
}