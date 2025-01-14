import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const _jwtKey = 'token';
  final _secureStorage = const FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _swapPreferenceController = TextEditingController();
  final TextEditingController _estimatedRetailPriceController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  String? _jwtToken;

  @override
  void initState() {
    super.initState();
    _loadJwtToken();
  }

  Future<void> _loadJwtToken() async {
    final token = await _secureStorage.read(key: _jwtKey);
    setState(() {
      _jwtToken = token;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _swapPreferenceController.dispose();
    _estimatedRetailPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    // final uri = Uri.parse('http://10.0.2.2:8000/api/image/upload');
    final uri = Uri.parse('http://192.168.0.248:8000/api/image/upload');
    final request = http.MultipartRequest('POST', uri);

    if (_jwtToken != null) {
      request.headers['Authorization'] = 'Bearer $_jwtToken';
    }

    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String? uploadedUrl = data['imageUrl'];
      if (uploadedUrl == null) {
        throw Exception('No imageUrl in response');
      }
      return uploadedUrl;
    } else {
      throw Exception('Image upload failed [status: ${response.statusCode}]');
    }
  }

  Future<void> _createProduct({
    required String productTitle,
    required String productDescription,
    required String productImage,
    required String swapPreference,
    required double estimatedRetailPrice,
  }) async {
    // final productsUrl = Uri.parse('http://10.0.2.2:8000/api/products');
    final productsUrl = Uri.parse('http://192.168.0.248:8000/api/products');
    final productData = {
      "productTitle": productTitle,
      "productDescription": productDescription,
      "productImage": productImage,
      "swapPreference": swapPreference,
      "estimatedRetailPrice": estimatedRetailPrice,
    };

    final response = await http.post(
      productsUrl,
      headers: {
        'Content-Type': 'application/json',
        if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
      },
      body: json.encode(productData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create product [status: ${response.statusCode}]');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final swapPref = _swapPreferenceController.text.trim();
      final priceString = _estimatedRetailPriceController.text.trim();
      final double estimatedPrice = double.tryParse(priceString) ?? 0.0;

      final uploadedImageUrl = await _uploadImage(_selectedImage!);
      await _createProduct(
        productTitle: title,
        productDescription: description,
        productImage: uploadedImageUrl,
        swapPreference: swapPref,
        estimatedRetailPrice: estimatedPrice,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully!')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      debugPrint('Error in _submitForm: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add A Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _selectedImage == null
                      ? const Center(child: Icon(Icons.add, size: 50))
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Product Title *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Product Description *'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _swapPreferenceController,
                decoration: const InputDecoration(
                  labelText: 'Swap Preference *',
                  hintText: 'e.g. 2020 TV or equivalent',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your swap preference.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _estimatedRetailPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimated Retail Price *',
                  hintText: 'e.g. 10.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a retail price.';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Create Product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}