import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';
import '../services/swap_service.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

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
  final ProductService _productService = ProductService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Product? productDetails;
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _useExistingProduct = false;

  List<Product> _userProducts = [];
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _fetchUserProducts();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final product = await _productService.fetchProductDetails(widget.productId);
      setState(() {
        productDetails = product;
      });
    } catch (e) {
      print('Error fetching product details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load product details')),
      );
    }
  }

  Future<void> _fetchUserProducts() async {
    try {
      final products = await _productService.fetchUserProducts();
      setState(() {
        _userProducts = products;
      });
    } catch (e) {
      print('Error fetching user products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load your products')),
      );
    }
  }

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
    if ((_useExistingProduct && _selectedProduct == null) ||
        (!_useExistingProduct && (_uploadedImageUrl == null || _titleController.text.isEmpty || _priceController.text.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final title = _useExistingProduct ? _selectedProduct!.productTitle! : _titleController.text;
      final description = _useExistingProduct ? _selectedProduct!.productDescription! : _descriptionController.text;
      final price = _useExistingProduct
          ? _selectedProduct!.estimatedRetailPrice ?? 0.0
          : double.parse(_priceController.text);
      final imageUrl = _useExistingProduct ? _selectedProduct!.productImage : _uploadedImageUrl!;

      await _swapService.submitSwap(
        productId: widget.productId,
        sellerId: widget.sellerId,
        imageUrl: imageUrl!,
        title: title,
        description: description,
        estimatedRetailPrice: price,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap offer sent successfully!')),
      );
      Navigator.pop(context);
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
      body: productDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Swap With',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: productDetails!.productImage != null
                        ? DecorationImage(
                      image: NetworkImage(productDetails!.productImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productDetails!.productTitle ?? 'Untitled Product',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estimated Value: RON${productDetails!.estimatedRetailPrice?.toStringAsFixed(2) ?? 'N/A'}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SwitchListTile(
              title: const Text('Use Existing Product'),
              value: _useExistingProduct,
              onChanged: (value) {
                setState(() {
                  _useExistingProduct = value;
                  _selectedProduct = null;
                  _uploadedImageUrl = null;
                  _titleController.clear();
                  _descriptionController.clear();
                  _priceController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            if (_useExistingProduct)
              DropdownButton<Product>(
                hint: const Text('Select a Product'),
                value: _selectedProduct,
                isExpanded: true,
                onChanged: (product) {
                  setState(() {
                    _selectedProduct = product;
                  });
                },
                items: _userProducts.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(product.productTitle ?? 'Untitled Product'),
                  );
                }).toList(),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  if (_isUploading) const Center(child: CircularProgressIndicator()),
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
                ],
              ),
            const SizedBox(height: 32),
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
