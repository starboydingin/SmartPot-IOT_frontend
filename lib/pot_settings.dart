import 'package:flutter/material.dart';
import 'custom_back_button.dart'; // ⬅️ pastikan path sesuai

class PotSettingsPage extends StatefulWidget {
  final String plantName;
  const PotSettingsPage({super.key, this.plantName = "Basil Plant"});

  @override
  State<PotSettingsPage> createState() => _PotSettingsPageState();
}

class _PotSettingsPageState extends State<PotSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Soil moisture values
  double _dryThreshold = 25;
  double _wetThreshold = 40;
  double _wateringDelay = 70;
  double _pumpDuration = 25;

  // Lux intensity values
  double _minLux = 5000;
  double _maxLux = 15000;
  double _lightDuration = 10;

  // Temp & humidity values
  double _hotTemp = 29;
  double _extremeTemp = 35;
  double _lowHumidity = 35;

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

        // ===================== 🔥 CUSTOM BACK BUTTON ======================
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CustomBackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),

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
              widget.plantName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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
            Tab(text: "Temperature & Humidity"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSoilMoistureSettings(),
          _buildLuxIntensitySettings(),
          _buildTempHumiditySettings(),
        ],
      ),
    );
  }

  // ============================================================
  // SOIL MOISTURE
  // ============================================================

  Widget _buildSoilMoistureSettings() {
    return _buildScrollableColumn([
      _buildSliderCard(
        title: "Batas Tanah Kering",
        color: Colors.green,
        description:
            "Titik kelembapan tanah di mana sistem mulai penyiraman otomatis.",
        value: _dryThreshold,
        min: 20,
        max: 60,
        unit: "%",
        labelMin: "Dry (20%)",
        labelMax: "Moist (60%)",
        onChanged: (v) => setState(() => _dryThreshold = v),
      ),
      _buildSliderCard(
        title: "Batas Tanah Basah",
        color: Colors.green,
        description:
            "Titik kelembapan tanah di mana sistem berhenti menyiram.",
        value: _wetThreshold,
        min: 40,
        max: 80,
        unit: "%",
        labelMin: "Moist (40%)",
        labelMax: "Wet (80%)",
        onChanged: (v) => setState(() => _wetThreshold = v),
      ),
      _buildSliderCard(
        title: "Jeda Antar Penyiraman",
        color: Colors.green,
        description:
            "Waktu tunggu sebelum penyiraman otomatis berikutnya.",
        value: _wateringDelay,
        min: 60,
        max: 600,
        unit: "s",
        labelMin: "Fast (60s)",
        labelMax: "Slow (600s)",
        onChanged: (v) => setState(() => _wateringDelay = v),
      ),
      _buildSliderCard(
        title: "Durasi Maksimal Pompa Aktif",
        color: Colors.green,
        description:
            "Batas maksimal pompa menyala untuk mencegah overwatering.",
        value: _pumpDuration,
        min: 10,
        max: 120,
        unit: "s",
        labelMin: "Short (10s)",
        labelMax: "Long (120s)",
        onChanged: (v) => setState(() => _pumpDuration = v),
      ),
      _buildSaveButton(),
    ]);
  }

  // ============================================================
  // LUX INTENSITY
  // ============================================================

  Widget _buildLuxIntensitySettings() {
    return _buildScrollableColumn([
      _buildSliderCard(
        title: "Ambang Cahaya Minimum",
        color: Colors.orange,
        description:
            "Intensitas cahaya minimum di mana sistem menyalakan lampu tambahan.",
        value: _minLux,
        min: 1000,
        max: 10000,
        unit: " lx",
        labelMin: "Low (1k lx)",
        labelMax: "High (10k lx)",
        onChanged: (v) => setState(() => _minLux = v),
      ),
      _buildSliderCard(
        title: "Ambang Cahaya Maksimum",
        color: Colors.orange,
        description:
            "Intensitas cahaya maksimum di mana sistem mematikan lampu tambahan.",
        value: _maxLux,
        min: 10000,
        max: 25000,
        unit: " lx",
        labelMin: "Low (10k lx)",
        labelMax: "High (25k lx)",
        onChanged: (v) => setState(() => _maxLux = v),
      ),
      _buildSliderCard(
        title: "Durasi Pencahayaan Harian",
        color: Colors.orange,
        description:
            "Durasi waktu lampu menyala untuk memenuhi kebutuhan fotosintesis.",
        value: _lightDuration,
        min: 4,
        max: 18,
        unit: " h",
        labelMin: "Short (4h)",
        labelMax: "Long (18h)",
        onChanged: (v) => setState(() => _lightDuration = v),
      ),
      _buildSaveButton(),
    ]);
  }

  // ============================================================
  // TEMP & HUMIDITY
  // ============================================================

  Widget _buildTempHumiditySettings() {
    return _buildScrollableColumn([
      _buildSliderCard(
        title: "Ambang Suhu Panas",
        color: Colors.blue,
        description:
            "Suhu udara mulai dianggap tinggi (penyiraman lebih cepat).",
        value: _hotTemp,
        min: 28,
        max: 38,
        unit: " °C",
        labelMin: "Cool (28°C)",
        labelMax: "Hot (38°C)",
        onChanged: (v) => setState(() => _hotTemp = v),
      ),
      _buildSliderCard(
        title: "Ambang Suhu Ekstrem",
        color: Colors.blue,
        description: "Suhu kritis yang memicu notifikasi panas berlebih.",
        value: _extremeTemp,
        min: 32,
        max: 45,
        unit: " °C",
        labelMin: "Warm (32°C)",
        labelMax: "Extreme (45°C)",
        onChanged: (v) => setState(() => _extremeTemp = v),
      ),
      _buildSliderCard(
        title: "Ambang Kelembapan Udara Rendah",
        color: Colors.blue,
        description:
            "Kelembapan udara di mana sistem menyesuaikan penyiraman lebih cepat.",
        value: _lowHumidity,
        min: 20,
        max: 60,
        unit: " %",
        labelMin: "Dry Air (20%)",
        labelMax: "Humid Air (60%)",
        onChanged: (v) => setState(() => _lowHumidity = v),
      ),
      _buildSaveButton(),
    ]);
  }

  // ============================================================
  // REUSABLE COMPONENTS
  // ============================================================

  Widget _buildScrollableColumn(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: children),
    );
  }

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
    required Color color,
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
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${value.toStringAsFixed(0)}$unit",
                  style: TextStyle(
                    color: color,
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
              activeColor: Colors.black,
              inactiveColor: Colors.grey.shade300,
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

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
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
    );
  }
}
