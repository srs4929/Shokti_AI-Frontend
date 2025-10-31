import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // AppBar title text
  final VoidCallback? onBack; // Optional callback for back button

  const CustomAppBar({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90), // Container height for AppBar
      child: Container(
        decoration: const BoxDecoration(
          // Gradient background
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 20, 77, 22),
              Color.fromARGB(255, 78, 133, 16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // Rounded bottom corners
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  if (onBack != null) {
                    onBack!(); // Execute custom back callback if provided
                  } else {
                    Navigator.pop(context); // Default back navigation
                  }
                },
              ),
              // AppBar title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110); // Overall preferred size
}
