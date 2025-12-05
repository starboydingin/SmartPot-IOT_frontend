import 'package:flutter/material.dart';

import 'custom_back_button.dart';
import 'services/auth_service.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _authService.getCachedUser();
      if (user == null) {
        setState(() {
          _error = 'Profile data unavailable. Please login again.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
        _locationController.text = user.location ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await _authService.updateProfile(
        fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')), 
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                // ✅ CUSTOM BACK BUTTON
                CustomBackButton(
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(width: 16),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile Setting",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Edit your information",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProfile,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  offset: const Offset(0, 4),
                                  blurRadius: 12,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildField(
                                  label: "Full Name",
                                  icon: Icons.person,
                                  controller: _fullNameController,
                                ),
                                const SizedBox(height: 20),
                                _buildField(
                                  label: "Email Address",
                                  icon: Icons.email,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                _buildField(
                                  label: "Phone Number",
                                  icon: Icons.phone,
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 20),
                                _buildField(
                                  label: "Location",
                                  icon: Icons.location_on,
                                  controller: _locationController,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),

          const SizedBox(height: 20),

          // SAVE BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSaving ? 'Saving...' : "Save Changes",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: _isSaving || _isLoading ? null : _saveProfile,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIELD WIDGET
  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
