import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class Weathercard extends StatelessWidget {
  final String city;
  final String temp;
  final String condition;
  final String icon;

  const Weathercard({
    super.key,
    required this.city,
    required this.temp,
    required this.condition,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildAnimation(String condition) {
      final cond = condition.toLowerCase();

      if (cond.contains('rain')) {
        return rive.RiveAnimation.asset(
          'assets/Animations/rain_animation.riv',
          fit: BoxFit.cover,
        );
      }

      // Default to sunny animation if no match or missing animations
      return rive.RiveAnimation.asset(
        'assets/Animations/rain_and_sun_animation.riv',
        fit: BoxFit.cover,
      );
    }

    return Container(
      height: 220,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: buildAnimation(condition),
            ),
          ),
          Positioned(
            top: 20,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$temp°C',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  condition,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 30,
            bottom: 30,
            child:
                icon.isNotEmpty
                    ? Image.network(
                      icon,
                      width: 80,
                      height: 80,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 80,
                          ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
