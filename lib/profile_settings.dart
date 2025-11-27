import 'package:flutter/material.dart';
import 'custom_back_button.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

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
            child: SingleChildScrollView(
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
                      buildField(
                        label: "Full Name",
                        icon: Icons.person,
                        value: "Plant Lover",
                      ),
                      const SizedBox(height: 20),
                      buildField(
                        label: "Email Address",
                        icon: Icons.email,
                        value: "user@smartplant.com",
                      ),
                      const SizedBox(height: 20),
                      buildField(
                        label: "Phone Number",
                        icon: Icons.phone,
                        value: "+62 812 3456 7890",
                      ),
                      const SizedBox(height: 20),
                      buildField(
                        label: "Location",
                        icon: Icons.location_on,
                        value: "Jakarta, Indonesia",
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
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIELD WIDGET
  Widget buildField({required String label, required IconData icon, required String value}) {
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
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
