import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import MediaType
import 'package:mime/mime.dart'; // For MIME type lookup
import 'package:path/path.dart' as path;

class ImageUploadService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  Future<String> uploadImage(File image) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      // Get MIME type of the file
      final mimeType = lookupMimeType(image.path);
      final fileName = path.basename(image.path);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/upload'),
      );

      // Await the creation of the MultipartFile
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // Field name expected by the server
        image.path,
        contentType: mimeType != null
            ? MediaType.parse(mimeType) // Use MediaType from http_parser
            : null,
        filename: fileName,
      );

      request.files.add(multipartFile);
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return responseBody; // Assuming the response contains the uploaded image URL
      } else {
        throw Exception('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
