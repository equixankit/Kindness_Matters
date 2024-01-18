import 'package:flutter/material.dart';
import 'package:kindness_matters/screens/sign_in.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildSplashPage(
                      title: "Welcome to \nKindness Matters",
                      imagePath: "assets/icon512.png",
                      text:
                          "Idea by Ansh Patil,\nEmail : patilansh260308@gmail.com,\nIndus International School, Bengaluru"),
                  _buildSplashPage(
                      title: "Empathy",
                      imagePath: "assets/kindness-2.jpg",
                      text:
                          "This emotional connection not only strengthens relationships but also contributes to the building of a compassionate and supportive community. In a world often marked by diverse perspectives and challenges, kindness becomes a bridge that allows people to walk in each other's shoes, fostering unity and shared humanity."),
                  _buildSplashPage(
                      title: "Resilience",
                      imagePath: "assets/kindness-3.jpg",
                      text:
                          "Kindness acts as a formidable force in cultivating personal and collective resilience. In times of adversity, a kind gesture or supportive word can make a significant impact, providing the strength needed to overcome challenges."),
                  _buildSplashPage(
                      title: "Global Impact",
                      imagePath: "assets/kindness-1.jpg",
                      text:
                          "Kindness transcends borders and has the power to create a positive global impact. In a world interconnected by technology and communication, small acts of kindness can reverberate across continents, inspiring a chain reaction of positive change."),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(_currentPage > 0 ? "Back" : "Skip"),
                ),
                TextButton(
                  onPressed: () {
                    if (_currentPage < 3) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(_currentPage == 3 ? "Get Started" : "Continue"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplashPage(
      {required String title,
      required String imagePath,
      required String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(imagePath, width: 350, height: 250),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
