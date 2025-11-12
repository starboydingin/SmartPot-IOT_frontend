import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'pot_settings.dart'; // 👉 pastikan file ini bener namanya

class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color background = Color(0xFFF6F9F4);
  static const Color card = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
}

class AppTextStyle {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle subHeading = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    height: 1.3,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle value = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle status = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

class PlantDetailScreen extends StatefulWidget {
  final String plantName;
  final String location;
  final double moisture;
  final double temperature;
  final double humidity;
  final double light;
  final String status;

  const PlantDetailScreen({
    super.key,
    required this.plantName,
    required this.location,
    required this.moisture,
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.status,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  bool _isAutoWatering = false;
  bool _isPumpOn = false;

  final List<FlSpot> moistureData =
      List.generate(10, (i) => FlSpot(i.toDouble(), (40 + i * 2 + (i % 3) * 5).toDouble()));
  final List<FlSpot> tempData =
      List.generate(10, (i) => FlSpot(i.toDouble(), (20 + (i % 4) * 2).toDouble()));
  final List<FlSpot> humidityData =
      List.generate(10, (i) => FlSpot(i.toDouble(), (50 + (i % 5) * 4).toDouble()));
  final List<FlSpot> lightData =
      List.generate(10, (i) => FlSpot(i.toDouble(), (600 + (i % 4) * 50).toDouble()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(widget.plantName, style: AppTextStyle.heading),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.location}\nDevice ID: SPP-10001",
                    style: AppTextStyle.subHeading,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Chip(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      label: Text(
                        widget.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: _statusColor(widget.status),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== SENSOR GRID =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _sensorCard("Moisture", "${widget.moisture.toStringAsFixed(2)}%",
                      Icons.water_drop, Colors.green, "Normal range"),
                  _sensorCard("Temp", "${widget.temperature.toStringAsFixed(2)}°C",
                      Icons.thermostat, Colors.redAccent, "Normal range"),
                  _sensorCard("Humidity", "${widget.humidity.toStringAsFixed(2)}%",
                      Icons.cloud, Colors.blue, "Comfortable"),
                  _sensorCard("Light", widget.light.toStringAsFixed(2),
                      Icons.wb_sunny, Colors.amber, "Lux"),
                ],
              ),
            ),

            // ===== 24-HOUR TRENDS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("24-Hour Trends",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _chartSection("Soil Moisture (%)", moistureData, Colors.green),
                  _chartSection("Temperature (°C)", tempData, Colors.redAccent),
                  _chartSection("Humidity (%)", humidityData, Colors.blue),
                  _chartSection("Light (Lux)", lightData, Colors.amber),
                ],
              ),
            ),

            // ===== WATERING CONTROL =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade50,
                          Colors.green.shade100,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Watering Control",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // AUTO WATERING SWITCH
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Auto Watering",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Based on configure threshold",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isAutoWatering,
                              onChanged: (val) {
                                setState(() {
                                  _isAutoWatering = val;
                                });
                              },
                              thumbColor: WidgetStateProperty.resolveWith<Color>(
                                (states) =>
                                    states.contains(WidgetState.selected)
                                        ? Colors.white
                                        : Colors.grey.shade300,
                              ),
                              trackColor: WidgetStateProperty.resolveWith<Color>(
                                (states) =>
                                    states.contains(WidgetState.selected)
                                        ? Colors.green
                                        : Colors.grey.shade200,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 14),

                        // MANUAL PUMP BUTTON
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPumpOn = !_isPumpOn;
                            });
                          },
                          icon: const Icon(Icons.water_drop),
                          label: Text(
                            _isPumpOn ? "Manual Pump (ON)" : "Manual Pump (5 sec)",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CONFIGURE THRESHOLD BUTTON
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green.shade400, width: 1.2),
                      foregroundColor: Colors.green.shade600,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // 👉 GANTI ke halaman pot_settings_page.dart
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PotSettingsPage()),
                      );
                    },
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text(
                      "Configure Threshold",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Helper Functions =====
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "optimal":
      case "healthy":
        return Colors.green;
      case "needs water":
        return Colors.orange;
      case "too hot":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _sensorCard(
      String label, String value, IconData icon, Color color, String status) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 24,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyle.label),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyle.value.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(status, style: AppTextStyle.status),
        ],
      ),
    );
  }

  Widget _chartSection(String title, List<FlSpot> data, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: color,
                      belowBarData:
                          BarAreaData(show: true, color: color.withValues(alpha: 0.2)),
                      dotData: const FlDotData(show: false),
                      barWidth: 3,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
