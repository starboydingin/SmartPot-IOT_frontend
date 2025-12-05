import 'dart:async';

import 'package:flutter/material.dart';
import 'plant_detail.dart';
import 'notification_page.dart' show NotificationPage, createFadeSlideRoute;
import 'add_new_pot.dart';
import 'profile_page.dart';
import 'models/device_model.dart';
import 'models/sensor_data_model.dart';
import 'services/device_service.dart';
import 'services/sensor_data_service.dart';
import 'services/websocket_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DeviceService _deviceService = DeviceService();
  final SensorDataService _sensorDataService = SensorDataService();
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _sensorSubscription;
  bool _sensorChannelReady = false;
  
  List<Device> _devices = [];
  Map<String, SensorData?> _latestSensorData = {}; // UUID keys
  bool _isLoading = true;
  String? _error;
  
  static const Color notificationGreen = Colors.green;

  @override
  void initState() {
    super.initState();
    _loadData();
    _connectSensorChannel();
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final devices = await _deviceService.getAllDevices();
      final sensorEntries = await Future.wait(
        devices.map((device) async {
          try {
            final sensorData = await _sensorDataService.getLatestSensorData(device.id);
            return MapEntry(device.id, sensorData);
          } catch (_) {
            return MapEntry<String, SensorData?>(device.id, null);
          }
        }),
      );

      final sensorDataMap = {for (final entry in sensorEntries) entry.key: entry.value};

      setState(() {
        _devices = devices;
        _latestSensorData = sensorDataMap;
        _isLoading = false;
      });

      _requestLatestForDevices(devices);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _getDeviceStatus(SensorData? data) {
    if (data == null) return 'No Data';
    
    if (data.soilPercent < 30) return 'Needs Water';
    if (data.temperature > 30) return 'Too Hot';
    if (data.temperature < 15) return 'Too Cold';
    return 'Optimal';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Optimal':
        return Colors.green;
      case 'Needs Water':
        return Colors.orange;
      case 'Too Hot':
      case 'Too Cold':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _connectSensorChannel() async {
    try {
      final stream = await _webSocketService.connectToSensorData();
      _sensorChannelReady = true;
      _sensorSubscription?.cancel();
      _sensorSubscription = stream.listen(
        _handleSensorEvent,
        onError: (_) {
          _sensorChannelReady = false;
        },
        onDone: () {
          _sensorChannelReady = false;
        },
        cancelOnError: false,
      );

      if (_devices.isNotEmpty) {
        _requestLatestForDevices(_devices);
      }
    } catch (_) {
      _sensorChannelReady = false;
    }
  }

  Future<void> _requestLatestForDevices(List<Device> devices) async {
    if (!_sensorChannelReady || devices.isEmpty) return;
    for (final device in devices) {
      try {
        await _webSocketService.requestSensorLatest(device.id);
      } catch (_) {
        _sensorChannelReady = false;
        break;
      }
    }
  }

  void _handleSensorEvent(Map<String, dynamic> event) {
    final type = event['type']?.toString();
    if (type == null) return;
    final payload = event['payload'];

    switch (type) {
      case 'sensor-data:list':
        _applySensorSnapshotList(payload);
        break;
      case 'sensor-data:latest':
        _applySensorSnapshot(payload);
        break;
      case 'sensor-data:error':
        final message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Sensor realtime error.';
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        break;
      default:
        break;
    }
  }

  void _applySensorSnapshotList(dynamic payload) {
    final snapshots = <DeviceSensorSnapshot>[];
    if (payload is List) {
      for (final item in payload) {
        final snapshot = _decodeSnapshot(item);
        if (snapshot != null) snapshots.add(snapshot);
      }
    } else if (payload is Map && payload['data'] is List) {
      for (final item in payload['data'] as List<dynamic>) {
        final snapshot = _decodeSnapshot(item);
        if (snapshot != null) snapshots.add(snapshot);
      }
    }

    if (snapshots.isEmpty) return;

    final updatedDevices = List<Device>.from(_devices);
    final updatedSensors = Map<String, SensorData?>.from(_latestSensorData);

    for (final snapshot in snapshots) {
      _mergeDevice(updatedDevices, snapshot.device);
      updatedSensors[snapshot.device.id] = snapshot.latestSensor;
    }

    if (!mounted) return;
    setState(() {
      _devices = updatedDevices;
      _latestSensorData = updatedSensors;
    });
  }

  void _applySensorSnapshot(dynamic payload) {
    final snapshot = _decodeSnapshot(payload);
    if (snapshot == null) return;

    final updatedDevices = List<Device>.from(_devices);
    final updatedSensors = Map<String, SensorData?>.from(_latestSensorData);
    _mergeDevice(updatedDevices, snapshot.device);
    updatedSensors[snapshot.device.id] = snapshot.latestSensor;

    if (!mounted) return;
    setState(() {
      _devices = updatedDevices;
      _latestSensorData = updatedSensors;
    });
  }

  DeviceSensorSnapshot? _decodeSnapshot(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      if (payload.containsKey('device')) {
        return DeviceSensorSnapshot.fromJson(payload);
      }
    } else if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      if (map.containsKey('device')) {
        return DeviceSensorSnapshot.fromJson(map);
      }
    }
    return null;
  }

  void _mergeDevice(List<Device> devices, Device device) {
    final index = devices.indexWhere((item) => item.id == device.id);
    if (index >= 0) {
      devices[index] = device;
    } else {
      devices.add(device);
    }
  }

  @override
  Widget build(BuildContext context) {

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
                  children: [
                    const Text(
                      "My Smart Pot",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_devices.length} Pots Connected",
                      style: const TextStyle(color: Colors.white70),
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
                      onPressed: () async {
                        final shouldRefresh = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const ProfilePage()),
                        );
                        if (shouldRefresh == true) {
                          _loadData();
                        }
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _devices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.eco_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No devices yet',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add your first Smart Pot below',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _devices.length,
                              itemBuilder: (context, index) {
                                final device = _devices[index];
                                final sensorData = _latestSensorData[device.id];
                                final status = _getDeviceStatus(sensorData);
                                final statusColor = _getStatusColor(status);

                                return PotCard(
                                  plantName: device.displayName,
                                  location: device.deviceName,
                                  moisture: sensorData?.soilPercent ?? 0.0,
                                  temperature: sensorData?.temperature ?? 0.0,
                                  humidity: sensorData?.humidity ?? 0.0,
                                  light: sensorData?.lux ?? 0.0,
                                  status: status,
                                  statusColor: statusColor,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PlantDetailScreen(
                                          deviceId: device.id,
                                          plantName: device.displayName,
                                          location: device.deviceName,
                                          moisture: sensorData?.soilPercent ?? 0.0,
                                          temperature: sensorData?.temperature ?? 0.0,
                                          humidity: sensorData?.humidity ?? 0.0,
                                          light: sensorData?.lux ?? 0.0,
                                          status: status,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),

          // ===== ADD SMART POT BUTTON =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddNewPotScreen()),
                );
                if (result == true) {
                  _loadData(); // Reload data after adding new device
                }
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
