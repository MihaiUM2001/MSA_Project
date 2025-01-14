import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';
import '../services/swap_service.dart';

class SwapFormPage extends StatefulWidget {
  final int productId;
  final int sellerId;

  const SwapFormPage({Key? key, required this.productId, required this.sellerId}) : super(key: key);

  @override
  _SwapFormPageState createState() => _SwapFormPageState();
}

class _SwapFormPageState extends State<SwapFormPage> {
  final SwapService _swapService = SwapService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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

  Future<void> _submitSwap() async {
    if (_uploadedImageUrl == null ||
        _titleController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      await _swapService.submitSwap(
        productId: widget.productId,
        sellerId: widget.sellerId,
        imageUrl: _uploadedImageUrl!,
        title: _titleController.text,
        description: _descriptionController.text,
        estimatedRetailPrice: double.parse(_priceController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap offer sent successfully!')),
      );
      Navigator.pop(context); // Close the form
    } catch (e) {
      print('Error submitting swap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send swap offer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Swap Offer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Offer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[300],
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.add, size: 50)),
              ),
            ),
            const SizedBox(height: 16),
            if (_isUploading)
              const Center(child: CircularProgressIndicator()),
            const Text('Product Title'),
            TextField(controller: _titleController),
            const SizedBox(height: 16),
            const Text('Product Description'),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Estimated Retail Price'),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitSwap,
              child: const Text('Send Offer'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
