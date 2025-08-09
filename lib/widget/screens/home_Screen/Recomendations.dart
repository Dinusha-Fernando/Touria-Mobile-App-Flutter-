import 'package:flutter/material.dart';

class Recomendations extends StatelessWidget {
  const Recomendations({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(padding: EdgeInsets.only(left: 15)),
          // Center(
          //   child: Text(
          //     'Recomendations',
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.w700,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          SizedBox(height: 10),
          Text(
            "Because you love beaches... 🏖️",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Top adventure spots for you... 🚵",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
