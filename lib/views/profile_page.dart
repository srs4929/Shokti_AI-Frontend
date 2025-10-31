import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shokti/CustomAppbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'update_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile?> _profileFuture;
  final _supabase = Supabase.instance.client;
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
    _profileFuture = _loadProfile();
  }

  Future<UserProfile?> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('auth_user_id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _showError("Error loading profile: $e");
      return null;
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

  Widget _buildGlassCard({required Widget child}) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:"Profile"),
        
      
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

          FutureBuilder<UserProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final profile = snapshot.data;
              if (profile == null) {
                return const Center(child: Text('No profile found'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildGlassCard(
                      child: ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: Colors.green.shade700,
                        ),
                        title: Text(
                          'Name',
                          style: GoogleFonts.poppins(
                            color: Colors.green.shade800,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          profile.name ?? 'Not set',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    _buildGlassCard(
                      child: ListTile(
                        leading: Icon(
                          Icons.home_outlined,
                          color: Colors.green.shade700,
                        ),
                        title: Text(
                          'Home Type',
                          style: GoogleFonts.poppins(
                            color: Colors.green.shade800,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          profile.homeType ?? 'Not set',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                           
                            title: Text(
                              'High-Energy Devices',
                              style: GoogleFonts.poppins(
                                color: Colors.green.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (profile.highEnergyDevices.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                bottom: 16,
                              ),
                              child: Text(
                                'No devices added',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 16,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: profile.highEnergyDevices.map((
                                  device,
                                ) {
                                  return Chip(
                                    label: Text(
                                      device,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.green.shade600,
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    _buildGlassCard(
                      child: ListTile(
                        leading: Icon(
                          Icons.language,
                          color: Colors.green.shade700,
                        ),
                        title: Text(
                          'Language',
                          style: GoogleFonts.poppins(
                            color: Colors.green.shade800,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          profile.language == 'en' ? 'English' : 'Bengali',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Update Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateProfilePage(profile: profile),
                            ),
                          ).then((_) {
                            // Reload profile after update
                            setState(() {
                              _profileFuture = _loadProfile();
                            });
                          });
                        },
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
              );
            },
          ),
        ],
      ),
    );
  }
}