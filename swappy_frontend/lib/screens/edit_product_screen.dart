import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/product_service.dart';
import '../services/image_upload_service.dart';
import '../models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;

  const EditProductScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductService _productService = ProductService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final _formKey = GlobalKey<FormState>();

  late Product _product;
  bool _isLoading = true;
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isVisible = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _swapPreferenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final product = await _productService.fetchProductDetails(widget.productId);
      setState(() {
        _product = product;
        _titleController.text = product.productTitle ?? '';
        _descriptionController.text = product.productDescription ?? '';
        _priceController.text = product.estimatedRetailPrice.toString();
        _swapPreferenceController.text = product.swapPreference ?? '';
        _uploadedImageUrl = product.productImage;
        _isVisible = product.isVisible ?? true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final imageUrl = await _imageUploadService.uploadImage(_selectedImage!);
      setState(() {
        _uploadedImageUrl = imageUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage != null && _uploadedImageUrl == null) {
        await _uploadImage();
      }

      try {
        await _productService.updateProduct(
          productId: widget.productId,
          imageUrl: _uploadedImageUrl,
          title: _titleController.text,
          description: _descriptionController.text,
          swapPreference: _swapPreferenceController.text,
          estimatedRetailPrice: double.parse(_priceController.text),
          isVisible: _isVisible,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );

        Navigator.pop(context); // Return to the previous screen
      } catch (e) {
        print('Error updating product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update product')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Product')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _selectImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          image: _selectedImage != null
                              ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                              : (_uploadedImageUrl != null
                              ? DecorationImage(
                            image: NetworkImage(_uploadedImageUrl!),
                            fit: BoxFit.cover,
                          )
                              : null),
                          color: Colors.grey[200],
                        ),
                        child: _selectedImage == null && _uploadedImageUrl == null
                            ? const Center(
                          child: Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                        )
                            : null,
                      ),
                      if (_selectedImage != null)
                        const Positioned(
                          right: 10,
                          bottom: 10,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.upload, size: 16, color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Estimated Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _swapPreferenceController,
                  decoration: const InputDecoration(labelText: 'Swap Preference'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Make Product Visible'),
                    Switch(
                      value: _isVisible,
                      onChanged: (value) {
                        setState(() {
                          _isVisible = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateProduct,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
