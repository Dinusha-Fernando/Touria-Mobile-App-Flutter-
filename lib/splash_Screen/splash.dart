import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:touria/screen/onBoardScreeen.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: SizedBox(
          height: 300,
          child: LottieBuilder.asset(
            'assets/lottie/Animation - 1742743354392.json',
          ),
        ),
      ),
      nextScreen: Onboardscreeen(),
      splashIconSize: 300,
      backgroundColor: Color(0xff0091d5),
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
