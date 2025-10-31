import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shokti/CustomAppbar.dart';
import 'package:shokti/views/Login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Stateful widget for user setup/profile page
class SetupPage extends StatefulWidget {
  final String userId; // Current user's ID from auth
  const SetupPage({super.key, required this.userId});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  // Controller for full name input
  final _nameController = TextEditingController();

  // Default selections
  String _homeType = 'House';
  List<String> _devices = [];
  String _language = 'en';
  bool _isLoading = false; // Loading state when saving profile

  // Options for dropdowns / chips
  final List<String> homeTypes = ['Apartment', 'House'];
  final List<String> deviceOptions = [
    'AC',
    'Heater',
    'Fridge',
    'Washing Machine',
  ];

  // Toggle device selection when user taps a ChoiceChip
  void _toggleDevice(String device) {
    setState(() {
      _devices.contains(device)
          ? _devices.remove(device)
          : _devices.add(device);
    });
  }

  // Save profile to Supabase
  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError("Please enter your name."); // Show error if name is empty
      return;
    }

    setState(() => _isLoading = true); // Show loading indicator
    try {
      // Insert profile data into Supabase 'user_profiles' table
      await Supabase.instance.client.from('user_profiles').insert({
        'auth_user_id': widget.userId,
        'name': name,
        'language': _language,
        'home_type': _homeType,
        'high_energy_devices': _devices,
      });

      // Navigate to Login page after successful save
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    } catch (e) {
      _showError("Unexpected error: $e"); // Show any unexpected errors
    } finally {
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  // Helper to show error messages via SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Reusable "glass" container with slight transparency and shadow
  Widget _buildGlassField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: child,
    );
  }

  // Reusable text field for input
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return _buildGlassField(
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.green.shade900),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.green.shade800,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Reusable dropdown field
  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return _buildGlassField(
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.green.shade800,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.green.shade700,
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ("Setup Profile")), // Custom AppBar
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFB2DFDB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Scrollable content with padding
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page intro text
                Text(
                  "Let's personalize your experience",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 30),

                // Full name input
                _buildTextField(
                  controller: _nameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                // Home type dropdown
                _buildDropdown<String>(
                  label: "Home Type",
                  value: _homeType,
                  items: homeTypes,
                  onChanged: (val) => setState(() => _homeType = val!),
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 20),

                // Device selection
                Text(
                  "High-Energy Devices",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: deviceOptions.map((device) {
                    final selected = _devices.contains(device);
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            device == 'AC'
                                ? Icons.ac_unit
                                : device == 'Heater'
                                ? Icons.fireplace
                                : device == 'Fridge'
                                ? Icons.kitchen
                                : Icons.local_laundry_service,
                            size: 18,
                            color: selected
                                ? Colors.white
                                : Colors.green.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            device,
                            style: GoogleFonts.poppins(
                              color: selected
                                  ? Colors.white
                                  : Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      selected: selected,
                      selectedColor: Colors.green.shade600,
                      backgroundColor: Colors.green.shade50,
                      onSelected: (_) => _toggleDevice(device),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: selected ? 3 : 0,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Language dropdown
                _buildDropdown<String>(
                  label: "Preferred Language",
                  value: _language,
                  items: ['en', 'bn'],
                  onChanged: (val) => setState(() => _language = val!),
                  icon: Icons.language,
                ),
                const SizedBox(height: 35),

                // Save profile button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    label: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : Text(
                            "Save Profile",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.green[700],
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
