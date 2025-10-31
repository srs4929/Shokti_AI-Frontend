import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shokti/CustomAppBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UpdateProfilePage extends StatefulWidget {
  final UserProfile profile;
  const UpdateProfilePage({super.key, required this.profile});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _nameController = TextEditingController();
  String _homeType = 'House';
  List<String> _devices = [];
  String _language = 'en';
  bool _isLoading = false;

  final List<String> homeTypes = ['Apartment', 'House'];
  final List<String> deviceOptions = [
    'AC',
    'Heater',
    'Fridge',
    'Washing Machine',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize form with current profile data
    _nameController.text = widget.profile.name ?? '';
    _homeType = widget.profile.homeType ?? 'House';
    _devices = List.from(widget.profile.highEnergyDevices);
    _language = widget.profile.language ?? 'en';
  }

  void _toggleDevice(String device) {
    setState(() {
      _devices.contains(device)
          ? _devices.remove(device)
          : _devices.add(device);
    });
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError("Please enter your name.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('user_profiles')
          .update({
            'name': name,
            'language': _language,
            'home_type': _homeType,
            'high_energy_devices': _devices
                .toString(), // Convert list to string to match database format
          })
          .eq('auth_user_id', widget.profile.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Error updating profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              (e) => DropdownMenuItem<T>(
                value: e,
                child: Text(e.toString(), style: GoogleFonts.poppins()),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CustomAppBar(title: "Update Profile"),
        
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFB2DFDB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Update your profile",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 30),

                _buildTextField(
                  controller: _nameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                _buildDropdown<String>(
                  label: "Home Type",
                  value: _homeType,
                  items: homeTypes,
                  onChanged: (val) => setState(() => _homeType = val!),
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 20),

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

                _buildDropdown<String>(
                  label: "Preferred Language",
                  value: _language,
                  items: ['en', 'bn'],
                  onChanged: (val) => setState(() => _language = val!),
                  icon: Icons.language,
                ),
                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined, color: Colors.white),
                    label: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : Text(
                            "Save Changes",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    onPressed: _isLoading ? null : _updateProfile,
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