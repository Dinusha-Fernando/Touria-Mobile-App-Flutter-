import 'package:flutter/material.dart';
import 'package:touria/constant/colors.dart';

// ignore: must_be_immutable, camel_case_types
class onboardingBodyWidget extends StatelessWidget {
  String title;
  String subTitle;
  String image;

  onboardingBodyWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(image, height: 400, width: double.infinity),
        const SizedBox(height: 15),
        Text(title, style: TextStyle(fontSize: 25, color: onboardingColor)),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            textAlign: TextAlign.center,
            subTitle,
            style: TextStyle(fontSize: 15, color: textColor),
          ),
        ),
      ],
    );
  }
}
