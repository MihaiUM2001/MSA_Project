import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String? fullName;
  final String? profilePictureUrl;

  const EditProfileScreen({Key? key, this.fullName, this.profilePictureUrl}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final TextEditingController _nameController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.fullName ?? '';
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

  Future<void> _updateProfile() async {
    final updates = <String, dynamic>{
      'fullName': _nameController.text,
      if (_uploadedImageUrl != null) 'profilePictureURL': _uploadedImageUrl,
    };

    try {
      await _userService.updateUserProfile(updates);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : widget.profilePictureUrl != null
                      ? NetworkImage(widget.profilePictureUrl!) as ImageProvider
                      : null,
                  child: _selectedImage == null && widget.profilePictureUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              if (_isUploading) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF201089),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
