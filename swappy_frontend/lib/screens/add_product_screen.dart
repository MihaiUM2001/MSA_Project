import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _swapPreferenceController = TextEditingController();

  // Picked image file
  File? _selectedImage;

  // Open gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final swapPreference = _swapPreferenceController.text.trim();

      // Simulate "creating" the product
      debugPrint('Product Title: $title');
      debugPrint('Product Description: $description');
      debugPrint('Swap Preference: $swapPreference');
      debugPrint('Selected Image: ${_selectedImage?.path}');

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully!')),
      );

      // Navigate to home screen (replace '/home' if you have a different route)
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add A Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker
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

              // Product Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Title *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Product Description *',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Swap Preference
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
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel/Back
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  // Create/Submit
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