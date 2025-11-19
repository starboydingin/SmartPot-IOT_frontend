import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedRefresh = 0; // 0 = 5s, 1 = 30s, 2 = 1 minute

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 55,
                left: 20,
                right: 20,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Manage your smart garden",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= DEVICE MANAGEMENT =================
            buildSectionCard(
              title: "Device Management",
              children: [
                buildMenuTile(
                  icon: Icons.edit_square,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: Colors.green[700]!,
                  title: "Manage Pots",
                  subtitle: "Rename or configure devices",
                ),
                divider(),
                buildMenuTile(
                  icon: Icons.delete_outline,
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: Colors.red,
                  title: "Remove Devices",
                  subtitle: "Disconnect pots from app",
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= DATA REFRESH =================
            buildSectionCard(
              title: "Data Refresh",
              children: [
                buildRefreshOption(
                  index: 0,
                  current: selectedRefresh,
                  title: "Every 5 seconds",
                  subtitle: "Real-time monitoring",
                ),
                buildRefreshOption(
                  index: 1,
                  current: selectedRefresh,
                  title: "Every 30 seconds",
                  subtitle: "Balanced mode",
                ),
                buildRefreshOption(
                  index: 2,
                  current: selectedRefresh,
                  title: "Every 1 minute",
                  subtitle: "Save battery",
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= ACCOUNT =================
            buildSectionCard(
              title: "Account",
              children: [
                buildMenuTile(
                  icon: Icons.person_2_outlined,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: Colors.blue[700]!,
                  title: "Profile Settings",
                  subtitle: "Edit your information",
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= LOGOUT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ========= WIDGETS REUSABLE =========

  Widget divider() => Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        height: 1,
        color: Colors.grey[300],
      );

  Widget buildSectionCard({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                )),

            const SizedBox(height: 18),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildMenuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  )),
            ],
          ),
        ),

        const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Colors.black45),
      ],
    );
  }

  Widget buildRefreshOption({
    required int index,
    required int current,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = index == current;

    return GestureDetector(
      onTap: () => setState(() => selectedRefresh = index),

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: Colors.white,
        ),

        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color:
                            isSelected ? Colors.green[700] : Colors.black87,
                      )),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      )),
                ],
              ),
            ),

            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.green : Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
