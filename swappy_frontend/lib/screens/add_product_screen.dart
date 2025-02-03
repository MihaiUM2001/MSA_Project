import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/duolingo_button.dart';
import '../services/image_upload_service.dart';
import '../services/product_service.dart';
import '../services/ai_price_estimator.dart';
import 'main_navigation.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ProductService _productService = ProductService();
  final AIPriceEstimator _aiPriceEstimator = AIPriceEstimator();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _swapPreferenceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateButtonStates);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateButtonStates);
    _titleController.dispose();
    super.dispose();
  }

  void _updateButtonStates() {
    setState(() {}); // Refresh UI when the title field changes
  }


  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _isFetchingPrice = false;

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

  Future<void> _getEstimatedPrice() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product name first')),
      );
      return;
    }

    setState(() {
      _isFetchingPrice = true;
    });

    final estimatedPrice = await _aiPriceEstimator.estimatePrice(
      _titleController.text,
      _uploadedImageUrl,
    );

    setState(() {
      _isFetchingPrice = false;
      if (estimatedPrice != null) {
        _priceController.text = "${estimatedPrice.toStringAsFixed(2)} RON";
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to estimate price. Try again later.')),
        );
      }
    });
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
        estimatedRetailPrice: double.parse(_priceController.text.replaceAll(" RON", "")), // Remove RON before parsing
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product')),
      );
    }
  }

  // Add this new state variable at the top
  bool _isGeneratingSwaps = false;

// New function to generate swap preferences
  Future<void> _generateSwapPreferences() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product name first')),
      );
      return;
    }

    setState(() {
      _isGeneratingSwaps = true;
    });

    final swapItems = await _aiPriceEstimator.generateSwapPreferences(_titleController.text);

    setState(() {
      _isGeneratingSwaps = false;
      if (swapItems.isNotEmpty) {
        _swapPreferenceController.text = swapItems.join(', ');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate swap preferences. Try again later.')),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 29.0),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        height: 35,
                      ),
                    ),
                  ),
                  const Text(
                    'Add Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
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

                  const Text('Product Title *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  TextField(controller: _titleController, decoration: InputDecoration(hintText: 'Enter product title')),
                  const SizedBox(height: 16),

                  const Text('Product Description *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  TextField(controller: _descriptionController, maxLines: 4, decoration: InputDecoration(hintText: 'Enter product description')),
                  const SizedBox(height: 16),

                  const Text('Swap Preference *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  TextField(controller: _swapPreferenceController, decoration: InputDecoration(hintText: 'e.g. 2020 TV or equivalent')),
                  const SizedBox(height: 16),


// Add this button inside your existing UI

                  DuolingoButton(
                    text: 'Generate Swap Preferences',
                    onPressed: _titleController.text.isEmpty ? null : _generateSwapPreferences,
                    isLoading: _isGeneratingSwaps,
                     // Duolingo green start
                      isSolidColor: true, // Solid color like the screenshot
                      startColor: const Color(0xFF58CC02)// Gradient style // Solid color like the screenshot // Duolingo green end
                  ),


                  const SizedBox(height: 16),

                  const Text('Estimated Retail Price *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Enter price in RON')),
                  const SizedBox(height: 16),

                  DuolingoButton(
                      text: 'Get Estimated Price',
                      onPressed: _titleController.text.isEmpty ? null : _getEstimatedPrice,
                      isLoading: _isFetchingPrice,
                      // Duolingo green start
                      isSolidColor: true, // Solid color like the screenshot
                      startColor:  Colors.orange// Gradient style // Solid color like the screenshot // Duolingo green end
                  ),


                  const SizedBox(height: 32),


                  DuolingoButton(
                      text: 'Add Product',
                      onPressed: _titleController.text.isEmpty ? null : _submitProduct,
                      // Duolingo green start
                      isSolidColor: true, // Solid color like the screenshot
                      startColor:  const Color(0xFF201089),// Gradient style // Solid color like the screenshot // Duolingo green end
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
