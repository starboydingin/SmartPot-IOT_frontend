import 'package:flutter/material.dart';

class PotSettingsPage extends StatefulWidget {
  final String plantName; // 👈 Tambahkan agar bisa ganti nama pot dinamis
  const PotSettingsPage({super.key, this.plantName = "Basil Plant"});

  @override
  State<PotSettingsPage> createState() => _PotSettingsPageState();
}

class _PotSettingsPageState extends State<PotSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double _dryThreshold = 25;
  double _wetThreshold = 40;
  double _wateringDelay = 70;
  double _pumpDuration = 25;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F4),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pot Settings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.plantName, // 👈 Nama pot sesuai halaman yang dibuka
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "Soil Moisture"),
            Tab(text: "Lux Intensity"),
            Tab(text: "Temp & Humidity"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSoilMoistureSettings(),
          _buildComingSoon("Lux Intensity"),
          _buildComingSoon("Temperature & Humidity"),
        ],
      ),
    );
  }

  // ============ SOIL MOISTURE SETTINGS ============
  Widget _buildSoilMoistureSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSliderCard(
            title: "Dry Soil Threshold",
            description:
                "Level of soil moisture where the system starts watering automatically.",
            value: _dryThreshold,
            min: 20,
            max: 60,
            unit: "%",
            labelMin: "Dry (20%)",
            labelMax: "Moist (60%)",
            onChanged: (v) => setState(() => _dryThreshold = v),
          ),
          _buildSliderCard(
            title: "Wet Soil Threshold",
            description:
                "Level of soil moisture where watering stops automatically.",
            value: _wetThreshold,
            min: 40,
            max: 80,
            unit: "%",
            labelMin: "Moist (40%)",
            labelMax: "Wet (80%)",
            onChanged: (v) => setState(() => _wetThreshold = v),
          ),
          _buildSliderCard(
            title: "Watering Delay",
            description:
                "Time between two automatic watering cycles (in seconds).",
            value: _wateringDelay,
            min: 60,
            max: 600,
            unit: "s",
            labelMin: "Fast (60s)",
            labelMax: "Slow (600s)",
            onChanged: (v) => setState(() => _wateringDelay = v),
          ),
          _buildSliderCard(
            title: "Pump Duration",
            description:
                "Maximum duration the pump stays active per cycle (in seconds).",
            value: _pumpDuration,
            min: 10,
            max: 120,
            unit: "s",
            labelMin: "Short (10s)",
            labelMax: "Long (120s)",
            onChanged: (v) => setState(() => _pumpDuration = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings saved successfully!")),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text("Save Settings"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ COMING SOON PLACEHOLDER ============
  Widget _buildComingSoon(String label) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "$label settings coming soon...",
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  // ============ SLIDER CARD COMPONENT ============
  Widget _buildSliderCard({
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required String unit,
    required String labelMin,
    required String labelMax,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${value.toStringAsFixed(0)}$unit",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Slider(
              value: value,
              min: min,
              max: max,
              // 🎨 Ganti warna slider ke hitam
              activeColor: Colors.black,
              inactiveColor: Colors.grey.shade400,
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(labelMin,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(labelMax,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
