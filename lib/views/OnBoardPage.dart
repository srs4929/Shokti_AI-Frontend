import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shokti/views/Login.dart';
import 'package:shokti/views/SignUp.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  int _current = 0;

  final List<_OnboardSlide> slides = [
    _OnboardSlide(
      image: 'assets/images/EnergyClip.png',
      title: 'Real‑time energy monitoring',
      body:
          'Connect devices instantly, visualize live power use and spot the biggest energy drains in your home.',
      accent: Colors.green.shade700,
    ),
    _OnboardSlide(
      image: 'assets/images/AI.png',
      title: 'AI-driven recommendations',
      body:
          'Ask the in-app assistant for tailored, actionable tips and schedules that cut consumption without sacrificing comfort.',
      accent: Colors.teal.shade700,
    ),
    _OnboardSlide(
      image: 'assets/images/Impact.png',
      title: 'Track savings & impact',
      body:
          'Monitor your savings over time and see the carbon and cost reductions from every smart choice.',
      accent: Colors.blue.shade700,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F7EE), Color(0xFFF1FAFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Subtle background shapes
          Positioned(
            top: -size.width * 0.25,
            left: -size.width * 0.15,
            child: Opacity(
              opacity: 0.06,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade200,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 12,
              ),
              child: Column(
                children: [
                  // Top row: logo/title
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset(
                            'assets/images/Logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Shokti',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Sign in (compact, with icon)
                          TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Login()),
                            ),
                            icon: Icon(
                              Icons.login,
                              color: Colors.green.shade800,
                              size: 18,
                            ),
                            label: Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),

                          // Skip (smaller, secondary)
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Login()),
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Carousel
                  Expanded(
                    child: Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: slides.length,
                          itemBuilder: (context, index, realIndex) {
                            final slide = slides[index];
                            return _buildSlide(context, slide);
                          },
                          options: CarouselOptions(
                            // give the carousel a finite height to avoid unbounded layout
                            height: size.height * 0.56,
                            viewportFraction: 1.0,
                            enlargeCenterPage: false,
                            enableInfiniteScroll: false,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 4),
                            onPageChanged: (index, reason) =>
                                setState(() => _current = index),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Dots (improved styling)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: slides.asMap().entries.map((entry) {
                            final isActive = entry.key == _current;
                            return GestureDetector(
                              onTap: () => setState(() => _current = entry.key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                width: isActive ? 34 : 12,
                                height: isActive ? 10 : 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? slides[entry.key].accent
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: slides[entry.key].accent
                                                .withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: const SizedBox.shrink(),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // CTA area
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade700,
                                        Colors.teal.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Signup(),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.person_add,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Create account',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Login(),
                                ),
                              ),
                              icon: Icon(
                                Icons.login,
                                color: Colors.grey.shade800,
                                size: 18,
                              ),
                              label: Text(
                                'Log in',
                                style: TextStyle(color: Colors.grey.shade800),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                backgroundColor: Colors.white,
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Small footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'By continuing you agree to our ',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Terms',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(BuildContext context, _OnboardSlide slide) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive: stacked on narrow screens, split on wide screens
                  final vertical =
                      size.width < 700 || constraints.maxWidth < 600;
                  if (vertical) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                          child: Image.asset(
                            slide.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: size.height * 0.28,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, v, child) =>
                                    Opacity(opacity: v, child: child),
                                child: Text(
                                  slide.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    height: 1.15,
                                    fontWeight: FontWeight.w800,
                                    color: slide.accent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              AutoSizeText(
                                slide.body,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: Colors.grey.shade800,
                                ),
                                maxLines: 6,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _FeaturePill(
                                    label: 'Realtime',
                                    color: slide.accent,
                                    icon: Icons.bolt,
                                  ),
                                  _FeaturePill(
                                    label: 'AI',
                                    color: slide.accent,
                                    icon: Icons.smart_toy,
                                  ),
                                  _FeaturePill(
                                    label: 'Savings',
                                    color: slide.accent,
                                    icon: Icons.savings,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Side-by-side layout for wider screens
                  return Row(
                    children: [
                      // Image side
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                          ),
                          child: Image.asset(
                            slide.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),

                      // Text side
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, v, child) =>
                                    Transform.translate(
                                      offset: Offset(0, (1 - v) * 8),
                                      child: Opacity(opacity: v, child: child),
                                    ),
                                child: Text(
                                  slide.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    height: 1.15,
                                    fontWeight: FontWeight.w800,
                                    color: slide.accent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: AutoSizeText(
                                  slide.body,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _FeaturePill(
                                    label: 'Realtime',
                                    color: slide.accent,
                                    icon: Icons.bolt,
                                  ),
                                  _FeaturePill(
                                    label: 'AI',
                                    color: slide.accent,
                                    icon: Icons.smart_toy,
                                  ),
                                  _FeaturePill(
                                    label: 'Savings',
                                    color: slide.accent,
                                    icon: Icons.savings,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardSlide {
  final String image;
  final String title;
  final String body;
  final Color accent;

  _OnboardSlide({
    required this.image,
    required this.title,
    required this.body,
    required this.accent,
  });
}

class _FeaturePill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _FeaturePill({
    Key? key,
    required this.label,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
