import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';
import '../services/product_service.dart';
import 'main_navigation.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ProductService _productService = ProductService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _swapPreferenceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File image) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await _imageUploadService.uploadImage(image);
      setState(() {
        _uploadedImageUrl = imageUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitProduct() async {
    if (_uploadedImageUrl == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _swapPreferenceController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      await _productService.createProduct(
        imageUrl: _uploadedImageUrl!,
        title: _titleController.text,
        description: _descriptionController.text,
        swapPreference: _swapPreferenceController.text,
        estimatedRetailPrice: double.parse(_priceController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
            (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        title: const Text('Add A Product To Swap'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF090046),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF090046)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey[300],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Center(child: Icon(Icons.add, size: 50, color: Colors.black54)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isUploading)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Text(
              'Product Title *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF090046)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter product title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Product Description *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF090046)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter product description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Swap Preference *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF090046)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _swapPreferenceController,
              decoration: InputDecoration(
                hintText: 'e.g. 2020 TV or equivalent',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Estimated Retail Price *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF090046)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter price in USD',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF090046),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Add Product',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
