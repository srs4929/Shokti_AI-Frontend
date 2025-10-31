import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shokti/views/Login.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shokti/views/SignUp.dart';
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.title});
  final String title;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/EnergyClip.png",

      "subtitle":
          "Connect Shokti with your devices and track live power consumption. AI analyzes usage patterns to help you save energy.",
    },
    {
      "image": "assets/images/AI.png",

      "subtitle":
          "Chat with Shokti AI to get personalized energy-saving tips, appliance suggestions, and eco-friendly alternatives.",
    },
    {
      "image": "assets/images/Impact.png",

      "subtitle": "Every action counts toward a smarter future",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Carousel with rounded images
            Expanded(
              flex: 4,
              child: CarouselSlider.builder(
                itemCount: onboardingData.length,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.5,
                  viewportFraction: 1.0, // full width
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(
                    seconds: 4,
                  ), //  slide changes every 4 seconds
                  autoPlayAnimationDuration: const Duration(
                    milliseconds: 800,
                  ), // smooth transition
                  autoPlayCurve: Curves.easeInOut,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: double.infinity,
                        color: const Color.fromARGB(
                          255,
                          8,
                          46,
                          10,
                        ), // optional background to show rounding
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            onboardingData[index]["image"]!,
                            fit: BoxFit.cover, // keep full content visible
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Title & Subtitle
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AutoSizeText(
                      onboardingData[_currentIndex]["subtitle"]!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Color.fromARGB(255, 2, 61, 17),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentIndex == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == index
                        ? const Color.fromARGB(255, 45, 196, 78)
                        : Colors.grey[400],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Gradient GetStarted Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 2, 105, 45),
                        Color(0xFF64DD17),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}
