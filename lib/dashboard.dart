import 'package:flutter/material.dart';
import 'plant_detail.dart';
import 'notification_page.dart' show NotificationPage, createFadeSlideRoute;
import 'add_new_pot.dart'; // ⬅️ Tambahan penting

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color notificationGreen = Colors.green; // 💚 Warna sama seperti di NotificationPage

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            decoration: const BoxDecoration(
              color: Colors.green, // 💚 disamakan dengan PlantDetail
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title & subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "My Smart Pot",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "3 Pots Connected",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                // Notification & Profile Buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          createFadeSlideRoute(const NotificationPage()),
                        );
                      },
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      icon:
                          const Icon(Icons.person_outline, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== BODY (List of Pots) =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PotCard(
                  plantName: "Basil Plant",
                  location: "Kitchen Window",
                  moisture: 66.84,
                  temperature: 22.11,
                  humidity: 67.0,
                  light: 673.15,
                  status: "Optimal",
                  statusColor: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlantDetailScreen(
                          plantName: "Basil Plant",
                          location: "Kitchen Window",
                          moisture: 66.84,
                          temperature: 22.11,
                          humidity: 67.0,
                          light: 673.15,
                          status: "Optimal",
                        ),
                      ),
                    );
                  },
                ),

                PotCard(
                  plantName: "Mint Plant",
                  location: "Balcony",
                  moisture: 42.17,
                  temperature: 25.4,
                  humidity: 55.2,
                  light: 812.9,
                  status: "Needs Water",
                  statusColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlantDetailScreen(
                          plantName: "Mint Plant",
                          location: "Balcony",
                          moisture: 42.17,
                          temperature: 25.4,
                          humidity: 55.2,
                          light: 812.9,
                          status: "Needs Water",
                        ),
                      ),
                    );
                  },
                ),

                PotCard(
                  plantName: "Rose Plant",
                  location: "Garden",
                  moisture: 75.2,
                  temperature: 30.6,
                  humidity: 60.0,
                  light: 920.1,
                  status: "Too Hot",
                  statusColor: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlantDetailScreen(
                          plantName: "Rose Plant",
                          location: "Garden",
                          moisture: 75.2,
                          temperature: 30.6,
                          humidity: 60.0,
                          light: 920.1,
                          status: "Too Hot",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ===== ADD SMART POT BUTTON =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddNewPotScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: notificationGreen,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Smart Pot",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== POT CARD =====
class PotCard extends StatefulWidget {
  final String plantName;
  final String location;
  final double moisture;
  final double temperature;
  final double humidity;
  final double light;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  const PotCard({
    super.key,
    required this.plantName,
    required this.location,
    required this.moisture,
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  State<PotCard> createState() => _PotCardState();
}

class _PotCardState extends State<PotCard> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plantName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        widget.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: TextStyle(
                          color: widget.statusColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Soil Moisture Bar
              const Text("Soil Moisture"),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: widget.moisture / 100,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("${widget.moisture.toStringAsFixed(2)}%"),
                ],
              ),

              const SizedBox(height: 20),

              // === Environment Data ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(Icons.thermostat, "Temp",
                      "${widget.temperature.toStringAsFixed(2)}°C", Colors.redAccent),
                  _infoItem(Icons.water_drop, "Humidity",
                      "${widget.humidity.toStringAsFixed(2)}%", Colors.blueAccent),
                  _infoItem(Icons.wb_sunny, "Light",
                      widget.light.toStringAsFixed(2), Colors.amber),
                ],
              ),

              const Divider(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(
      IconData icon, String label, String value, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
