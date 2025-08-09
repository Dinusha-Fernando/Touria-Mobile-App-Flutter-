import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touria/screen/profileScreen.dart';
import 'package:touria/services/provider/theme_provider.dart';
import 'package:touria/widget/screens/home_Screen/NotificationsDeals.dart';

class TopNavBar extends StatefulWidget {
  const TopNavBar({super.key});

  @override
  State<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
  File? _profileImageFile;

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
        _profileImageFile = File(imagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Touria',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xff0091d5),
              ),
            ),
            Text(
              'Explore Sri Lanka',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const Notificationsdeals(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Profilescreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : null,
                child:
                    _profileImageFile == null
                        ? Icon(
                          Icons.account_circle,
                          size: 36,
                          color: isDarkMode ? Colors.white70 : Colors.grey,
                        )
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
