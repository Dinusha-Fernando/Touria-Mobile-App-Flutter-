import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergencyhelp extends StatelessWidget {
  Emergencyhelp({super.key});

  final List<Map<String, dynamic>> contacts = [
    {'label': 'Hospitals', 'icon': Icons.local_hospital, 'number': '1990'},
    {'label': 'Police', 'icon': Icons.local_police, 'number': '119'},
    {'label': 'Helpline', 'icon': Icons.phone, 'number': '1919'},
  ];

  void _calNumber(BuildContext context, String? number) async {
    if (number == null || number.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Number not available')));
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch the dialer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Help',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children:
                contacts.map((item) {
                  final String lable = item['label'] ?? 'unknown';
                  final IconData icon = item['icon'] ?? Icons.warning;
                  final String? number = item['number'];
                  return GestureDetector(
                    onTap: () => _calNumber(context, number),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.redAccent,
                          child: Icon(icon, color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lable,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
