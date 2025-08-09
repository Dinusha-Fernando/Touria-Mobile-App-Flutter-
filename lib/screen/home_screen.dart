import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touria/services/provider/theme_provider.dart';
import 'package:touria/widget/screens/home_Screen/EmergencyHelp.dart';
import 'package:touria/widget/screens/home_Screen/aiTravelAssistant.dart';
import 'package:touria/widget/screens/home_Screen/featuredDestination.dart';
import 'package:touria/widget/screens/home_Screen/heroSection.dart';
import 'package:touria/widget/screens/home_Screen/mapViewSection.dart';
import 'package:touria/widget/screens/home_Screen/topNavBar.dart';
import 'package:touria/widget/screens/home_Screen/travelServices.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      //bottomNavigationBar: BottomNavBar(),print('');
      floatingActionButton: Aitravelassistant(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                TopNavBar(),
                Herosection(),
                SizedBox(height: 15),
                Mapviewsection(),
                Travelservices(),
                Featureddestination(),

                // Recomendations(),
                Emergencyhelp(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
