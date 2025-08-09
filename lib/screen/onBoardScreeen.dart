import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:touria/constant/colors.dart';
import 'package:touria/data/static/onboardingData.dart';
import 'package:touria/screen/login.dart';
import 'package:touria/widget/onboarding/bodyWidget.dart';

class Onboardscreeen extends StatefulWidget {
  const Onboardscreeen({super.key});

  @override
  State<Onboardscreeen> createState() => _OnboardscreeenState();
}

class _OnboardscreeenState extends State<Onboardscreeen> {
  final PageController _controller = PageController();
  bool lastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              onPageChanged: (v) {
                setState(() {
                  lastPage = (v == 2);
                });
              },
              controller: _controller,
              children: [
                onboardingBodyWidget(
                  title: onboarding[0].title,
                  subTitle: onboarding[0].subTitle,
                  image: onboarding[0].image,
                ),
                onboardingBodyWidget(
                  title: onboarding[1].title,
                  subTitle: onboarding[1].subTitle,
                  image: onboarding[1].image,
                ),
                onboardingBodyWidget(
                  title: onboarding[2].title,
                  subTitle: onboarding[2].subTitle,
                  image: onboarding[2].image,
                ),
              ],
            ),
            Positioned(
              bottom: 50,
              left: 175,
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: SwapEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  dotColor: onboardingColor,
                ),
              ),
            ),

            lastPage
                ? Positioned(
                  bottom: 45,
                  right: 50,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(color: onboardingColor, fontSize: 17),
                    ),
                  ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }
}
