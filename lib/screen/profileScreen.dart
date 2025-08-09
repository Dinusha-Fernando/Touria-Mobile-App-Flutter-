import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touria/lang/app_localization.dart';
import 'package:touria/screen/profile/edit_profile_screen.dart';
import 'package:touria/services/provider/language_provider.dart';
import 'package:touria/services/provider/theme_provider.dart';
import 'package:touria/widget/screens/home_Screen/aiTravelAssistant.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  User? currentUser;

  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && mounted) {
      setState(() {
        _profileImageFile = File(imagePath);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_image_${currentUser?.uid ?? 'default'}.png';
      final savedImage = await File(
        pickedFile.path,
      ).copy('${directory.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedImage.path);

      setState(() {
        _profileImageFile = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final languageProvider = Provider.of<LanguageProvider>(context);
    final selectedLanguage = languageProvider.locale.languageCode;

    final t = AppLocalization.of(context).translate;

    return Scaffold(
      floatingActionButton: Tooltip(
        message: 'Chat With AI Assistant',
        child: Aitravelassistant(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(t('Profile')),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 1,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _profileImageFile != null
                                ? FileImage(_profileImageFile!)
                                : null,
                        backgroundColor: Colors.grey[300],
                        child:
                            _profileImageFile == null
                                ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickProfileImage,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Color(0xff0091d5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    currentUser?.displayName ?? 'No Name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    currentUser?.email ?? "No Email",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Premium User',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileTile(
                    context,
                    icon: Icons.bookmark_border,
                    title: t('My Bookings'),
                    onTap: () {
                      // Navigate to My Bookings
                    },
                  ),
                  _buildProfileTile(
                    context,
                    icon: Icons.settings,
                    title: t('Settings'),
                    onTap: () {
                      // Navigate to Settings
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.language, color: Color(0xff0091d5)),
                    title: Text(
                      t('Language'),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor:
                              isDarkMode ? Colors.grey[900] : Colors.white,
                          iconEnabledColor:
                              isDarkMode ? Colors.white : Colors.black,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          value: selectedLanguage,
                          onChanged: (value) {
                            if (value != null) {
                              languageProvider.setLocale(Locale(value));
                            }
                          },
                          items:
                              ['English', 'සිංහල', 'தமிழ்'].map((lang) {
                                return DropdownMenuItem(
                                  value: _getLanguageCode(lang),
                                  child: Text(lang),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      t('Dark Mode'),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    secondary: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Color(0xff0091d5),
                    ),
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleDarkMode(value);
                    },
                  ),
                  _buildProfileTile(
                    context,
                    icon: Icons.support_agent,
                    title: t('Support'),
                    onTap: () {},
                  ),
                  _buildProfileTile(
                    context,
                    icon: Icons.logout,
                    title: t('Logout'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(t('Confirm Logout')),
                              content: Text(
                                t('Are You sure you want to logout?'),
                              ),
                              actions: [
                                TextButton(
                                  child: Text(t('Cancel')),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                ElevatedButton(
                                  child: Text(t('Logout')),
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pop(context);
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  },
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return ListTile(
      leading: Icon(icon, color: Color(0xff0091d5)),
      title: Text(
        title,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      onTap: onTap,
    );
  }

  String _getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'සිංහල':
        return 'si';
      case 'தமிழ்':
        return 'ta';
      default:
        return 'en';
    }
  }
}
