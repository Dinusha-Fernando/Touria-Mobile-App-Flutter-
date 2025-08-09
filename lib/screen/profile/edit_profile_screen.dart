import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touria/services/provider/theme_provider.dart';
import 'package:path_provider/path_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Dinusha Fernando',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'dinusha@email.com',
  );
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && mounted) {
      setState(() {
        _pickedImage = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Save image to app directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_image_edit.png';
      final savedImage = await File(
        pickedImage.path,
      ).copy('${directory.path}/$fileName');

      // Save path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedImage.path);

      setState(() {
        _pickedImage = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 1,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _pickedImage != null ? FileImage(_pickedImage!) : null,
                    backgroundColor: Colors.grey[300],
                    child:
                        _pickedImage == null
                            ? Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xff0091d5),
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white60 : Colors.black,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white60 : Colors.black,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0091d5),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                // Save changes logic here
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Profile Updated')));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
