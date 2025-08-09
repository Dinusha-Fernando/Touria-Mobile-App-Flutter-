import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touria/services/provider/theme_provider.dart';
import 'package:touria/widget/screens/services_screen/service_detail_screen.dart';

class Travelservices extends StatelessWidget {
  Travelservices({super.key});

  final List<Map<String, dynamic>> services = [
    {'label': 'Hotels', 'icon': Icons.hotel},
    {'label': 'Taxi', 'icon': Icons.local_taxi},
    {'label': 'Weather', 'icon': Icons.wb_cloudy},
    {'label': 'Tours', 'icon': Icons.tour},
    {'label': 'Restaurants', 'icon': Icons.restaurant},
    {'label': 'Shopping', 'icon': Icons.shopping_bag},
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return GridView.builder(
      itemCount: services.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(16),
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ServiceDetailScreen(
                      label: services[index]['label'] ?? 'Service',
                      icon: services[index]['icon'] ?? 'Icons.help',
                    ),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xff0091d5).withOpacity(0.2),
                child: Icon(
                  services[index]['icon'],
                  color: isDarkMode ? Colors.white : Color(0xff0091d5),
                  size: 28,
                ),
              ),
              SizedBox(height: 6),
              Text(
                services[index]['label'],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
