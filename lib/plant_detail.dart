import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'pot_settings.dart';
import 'custom_back_button.dart'; // <--- WAJIB ADA
import 'models/control_state.dart';
import 'models/sensor_data_model.dart';
import 'services/websocket_service.dart';
import 'services/sensor_data_service.dart';

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
  final String deviceId;
  final String plantName;
  final String location;
  final double moisture;
  final double temperature;
  final double humidity;
  final double light;
  final String status;

  const PlantDetailScreen({
    super.key,
    required this.deviceId,
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
  final WebSocketService _webSocketService = WebSocketService();
  final SensorDataService _sensorDataService = SensorDataService();
  StreamSubscription<Map<String, dynamic>>? _controlSubscription;
  StreamSubscription<Map<String, dynamic>>? _sensorSubscription;
  ControlState? _controlState;
  bool _controlLoading = true;
  String? _controlError;
  bool _isSendingControl = false;
  String? _modeOverride;
  String? _pumpOverride;
  double? _intervalSeconds;
  double? _intervalOverride;
  SensorData? _latestSensor;
  bool _sensorLoading = true;
  String? _sensorError;
  List<SensorData> _historyRecords = [];
  bool _historyLoading = true;
  String? _historyError;
  String _historyRange = '24h';

  @override
  void initState() {
    super.initState();
    _connectControlChannel();
    _loadLatestSensorFromApi();
    _loadSensorHistoryFromApi();
    _connectSensorChannel();
  }

  @override
  void dispose() {
    _controlSubscription?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moistureSeries = _buildHistorySeries((data) => data.soilPercent);
    final tempSeries = _buildHistorySeries((data) => data.temperature);
    final humiditySeries = _buildHistorySeries((data) => data.humidity);
    final lightSeries = _buildHistorySeries((data) => data.lux);
    final sensorStatusBanner = _sensorStatusBanner();

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
                  const CustomBackButton(),   // <--- SUDAH DIGANTI
                  const SizedBox(height: 20),
                  Text(widget.plantName, style: AppTextStyle.heading),
                  const SizedBox(height: 4),
                  Text(
                    widget.location,
                    style: AppTextStyle.subHeading,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Chip(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      label: Text(
                        _deviceStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: _statusColor(_deviceStatus),
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
              child: Column(
                children: [
                  if (sensorStatusBanner != null) ...[
                    sensorStatusBanner,
                    const SizedBox(height: 12),
                  ],
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _sensorCard("Moisture", "${_currentMoisture.toStringAsFixed(1)}%",
                          Icons.water_drop, Colors.green, _deviceStatus),
                      _sensorCard("Temp", "${_currentTemperature.toStringAsFixed(1)}°C",
                          Icons.thermostat, Colors.redAccent, 'Realtime'),
                      _sensorCard("Humidity", "${_currentHumidity.toStringAsFixed(1)}%",
                          Icons.cloud, Colors.blue, 'Realtime'),
                      _sensorCard("Light", _currentLight.toStringAsFixed(1),
                          Icons.wb_sunny, Colors.amber, 'Lux'),
                    ],
                  ),
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
                  _chartSection("Soil Moisture (%)", moistureSeries, Colors.green),
                  _chartSection("Temperature (°C)", tempSeries, Colors.redAccent),
                  _chartSection("Humidity (%)", humiditySeries, Colors.blue),
                  _chartSection("Light (Lux)", lightSeries, Colors.amber),
                ],
              ),
            ),

            // ===== WATERING CONTROL =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildControlCard(),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PotSettingsPage(
                            deviceId: widget.deviceId,
                            plantName: widget.plantName,
                          ),
                        ),
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

  bool get _controlReady => !_controlLoading && _controlError == null;

  bool get _isAutoMode => (_modeOverride ?? _controlState?.mode ?? 'AUTO') == 'AUTO';

  bool get _isPumpOn => (_pumpOverride ?? _controlState?.pumpStatus ?? 'OFF') == 'ON';

  bool get _hasIntervalConfig => _intervalSeconds != null || _intervalOverride != null;

  bool get _intervalDirty {
    if (_intervalOverride == null) return false;
    if (_intervalSeconds == null) return true;
    return (_intervalOverride! - _intervalSeconds!).abs() >= 0.5;
  }

  double get _currentIntervalSeconds {
    final value = _intervalOverride ?? _intervalSeconds ?? 10;
    if (value < 1) return 1;
    if (value > 60) return 60;
    return value;
  }

  double get _currentMoisture => _latestSensor?.soilPercent ?? widget.moisture;

  double get _currentTemperature => _latestSensor?.temperature ?? widget.temperature;

  double get _currentHumidity => _latestSensor?.humidity ?? widget.humidity;

  double get _currentLight => _latestSensor?.lux ?? widget.light;

  String get _deviceStatus => _latestSensor != null ? _deriveStatus(_latestSensor!) : widget.status;

  Future<void> _loadLatestSensorFromApi() async {
    setState(() {
      _sensorLoading = true;
      _sensorError = null;
    });

    try {
      final latest = await _sensorDataService.getLatestSensorData(widget.deviceId);
      if (!mounted) return;
      setState(() {
        _latestSensor = latest ?? _latestSensor;
        _sensorLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sensorLoading = false;
        _sensorError = 'Gagal memuat data sensor.';
      });
    }
  }

  Future<void> _loadSensorHistoryFromApi() async {
    setState(() {
      _historyLoading = true;
      _historyError = null;
    });

    try {
      final records = await _sensorDataService.getHistory(widget.deviceId, range: _historyRange);
      if (!mounted) return;
      setState(() {
        _historyRecords = records;
        _historyLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _historyLoading = false;
        _historyError = 'Gagal memuat histori sensor.';
      });
    }
  }

  Future<void> _connectSensorChannel() async {
    try {
      final stream = await _webSocketService.connectToSensorData();
      _sensorSubscription?.cancel();
      _sensorSubscription = stream.listen(
        _handleSensorMessage,
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _sensorError ??= 'Kanal sensor terputus.';
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            _sensorError ??= 'Kanal sensor ditutup.';
          });
        },
      );

      await _webSocketService.requestSensorLatest(widget.deviceId);
      await _webSocketService.requestSensorHistory(widget.deviceId, range: _historyRange);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sensorError = 'Tidak dapat membuka kanal sensor.';
      });
    }
  }

  void _handleSensorMessage(Map<String, dynamic> event) {
    final type = event['type']?.toString();
    if (type == null) return;
    final payload = event['payload'];

    switch (type) {
      case 'sensor-data:list':
        _applySensorListPayload(payload);
        break;
      case 'sensor-data:latest':
        _applySensorSnapshot(payload);
        break;
      case 'sensor-data:history':
        _applySensorHistory(payload);
        break;
      case 'sensor-data:error':
        final message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Sensor realtime error.';
        if (!mounted) return;
        setState(() {
          _sensorError = message;
        });
        break;
      default:
        break;
    }
  }

  void _applySensorListPayload(dynamic payload) {
    final entry = _findDeviceEntry(payload);
    if (entry == null) return;
    _applySensorSnapshot(entry);
  }

  void _applySensorSnapshot(dynamic payload) {
    final map = _asMap(payload);
    if (map == null) return;
    final device = _asMap(map['device']);
    if (device == null || device['id']?.toString() != widget.deviceId) return;
    final sensorMap = _asMap(map['latest_sensor']);

    if (!mounted) return;
    setState(() {
      _latestSensor = sensorMap != null ? SensorData.fromJson(sensorMap) : _latestSensor;
      _sensorLoading = false;
      _sensorError = null;
    });
  }

  void _applySensorHistory(dynamic payload) {
    final map = _asMap(payload);
    if (map == null) return;
    final device = _asMap(map['device']);
    if (device == null || device['id']?.toString() != widget.deviceId) return;
    final dataList = map['data'] as List<dynamic>?;
    if (dataList == null) return;

    final readings = dataList
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(SensorData.fromJson)
        .toList();

    if (!mounted) return;
    setState(() {
      _historyRecords = readings;
      _historyLoading = false;
      _historyError = null;
      if (map['requested_range'] != null) {
        _historyRange = map['requested_range'].toString();
      }
    });
  }

  Map<String, dynamic>? _findDeviceEntry(dynamic payload) {
    if (payload is List) {
      for (final item in payload) {
        final map = _asMap(item);
        final device = _asMap(map?['device']);
        if (device != null && device['id']?.toString() == widget.deviceId) {
          return map;
        }
      }
      return null;
    }

    if (payload is Map && payload['data'] is List) {
      return _findDeviceEntry(payload['data']);
    }

    return null;
  }

  Future<void> _connectControlChannel() async {
    setState(() {
      _controlLoading = true;
      _controlError = null;
    });

    try {
      final stream = await _webSocketService.connectToControl();
      _controlSubscription?.cancel();
      _controlSubscription = stream.listen(
        _handleControlMessage,
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _controlError = 'Koneksi kontrol terputus.';
            _controlLoading = false;
            _isSendingControl = false;
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            _controlError = 'Koneksi kontrol ditutup.';
            _isSendingControl = false;
          });
        },
      );

      await _webSocketService.sendControlMessage({
        'type': 'control:get',
        'payload': {'deviceId': widget.deviceId},
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _controlError = 'Tidak dapat membuka kanal kontrol.';
        _controlLoading = false;
      });
    }
  }

  void _handleControlMessage(Map<String, dynamic> event) {
    final type = event['type'];
    final payload = event['payload'];

    if (type == 'control:list') {
      final state = _extractControlFromList(payload);
      if (state != null) {
        _applyControlState(state);
      } else if (!_hasControlData) {
        setState(() {
          _controlLoading = false;
          _controlError = 'Perangkat belum memiliki data kontrol.';
        });
      }
      return;
    }

    if (type == 'control:updated' || type == 'control:detail') {
      final state = _extractControlState(payload);
      if (state != null) {
        _applyControlState(state);
      }
      return;
    }

    if (type == 'control:error') {
      if (!mounted) return;
      setState(() {
        _controlError = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Terjadi kesalahan kontrol.';
        _isSendingControl = false;
      });
      return;
    }
  }

  bool get _hasControlData => _controlState != null;

  ControlState? _extractControlState(dynamic payload) {
    final map = _asMap(payload);
    if (map == null) return null;
    final state = ControlState.fromJson(map);
    if (state.deviceId != widget.deviceId) return null;
    return state;
  }

  ControlState? _extractControlFromList(dynamic payload) {
    if (payload is List) {
      for (final item in payload) {
        final state = _extractControlState(item);
        if (state != null) return state;
      }
    }
    return null;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  void _applyControlState(ControlState state) {
    if (!mounted) return;
    setState(() {
      _controlState = state;
      _controlLoading = false;
      _controlError = null;
      _isSendingControl = false;
      _modeOverride = null;
      _pumpOverride = null;
      if (state.interval != null) {
        _intervalSeconds = state.interval! / 1000;
      }
      if (_intervalOverride != null && _intervalSeconds != null) {
        if ((_intervalOverride! - _intervalSeconds!).abs() < 0.1) {
          _intervalOverride = null;
        }
      }
    });
  }

  Future<void> _refreshControl() async {
    if (_controlSubscription == null) {
      await _connectControlChannel();
      return;
    }

    try {
      await _webSocketService.sendControlMessage({
        'type': 'control:get',
        'payload': {'deviceId': widget.deviceId},
      });
    } catch (_) {
      await _connectControlChannel();
    }
  }

  Future<void> _sendControlUpdate({String? mode, bool? pump, double? intervalSeconds}) async {
    final payload = <String, dynamic>{'deviceId': widget.deviceId};
    if (mode != null) payload['mode'] = mode;
    if (pump != null) payload['pump'] = pump;
    if (intervalSeconds != null) payload['interval'] = (intervalSeconds * 1000).round();

    if (payload.length == 1) return;

    setState(() {
      _isSendingControl = true;
      _controlError = null;
    });

    try {
      await _webSocketService.sendControlMessage({
        'type': 'control:update',
        'payload': payload,
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _isSendingControl = false;
        _controlError = 'Gagal mengirim perintah kontrol.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim perintah kontrol.')),
      );
    }
  }

  void _changeMode(bool isAuto) {
    final targetMode = isAuto ? 'AUTO' : 'MANUAL';
    setState(() {
      _modeOverride = targetMode;
    });
    _sendControlUpdate(mode: targetMode);
  }

  void _togglePump() {
    final next = !_isPumpOn;
    setState(() {
      _pumpOverride = next ? 'ON' : 'OFF';
    });
    _sendControlUpdate(pump: next);
  }

  Future<void> _saveInterval() async {
    final seconds = _intervalOverride ?? _intervalSeconds;
    if (seconds == null) return;
    await _sendControlUpdate(intervalSeconds: seconds);
  }

  Widget _buildControlCard() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kontrol Penyiraman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                color: Colors.green.shade700,
                tooltip: 'Segarkan kontrol',
                onPressed: _isSendingControl ? null : _refreshControl,
              )
            ],
          ),
          const SizedBox(height: 8),
          _buildControlStatusText(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode Otomatis',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Menyesuaikan threshold yang tersimpan.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isAutoMode,
                onChanged: _controlReady && !_isSendingControl ? _changeMode : null,
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                  (states) =>
                      states.contains(WidgetState.selected) ? Colors.white : Colors.grey.shade300,
                ),
                trackColor: WidgetStateProperty.resolveWith<Color>(
                  (states) =>
                      states.contains(WidgetState.selected) ? Colors.green : Colors.grey.shade200,
                ),
              )
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPumpOn ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _controlReady && !_isSendingControl ? _togglePump : null,
            icon: _isSendingControl && !_intervalDirty
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.water_drop),
            label: Text(
              _isPumpOn ? 'Pompa Manual (ON)' : 'Pompa Manual (OFF)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          _buildIntervalSection(),
        ],
      ),
    );
  }

  Widget _buildControlStatusText() {
    if (_controlLoading) {
      return const Text(
        'Mengambil status kontrol dari server...',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      );
    }

    if (_controlError != null) {
      return Text(
        _controlError!,
        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
      );
    }

    if (_isSendingControl) {
      return const Text(
        'Mengirim perintah ke perangkat...',
        style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
      );
    }

    return const Text(
      'Tersinkron dengan database secara realtime.',
      style: TextStyle(color: Colors.green, fontSize: 13),
    );
  }

  Widget _buildIntervalSection() {
    if (!_hasIntervalConfig) {
      return const Text(
        'Interval penyiraman belum dikonfigurasi. Simpan pengaturan threshold terlebih dahulu.',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interval Penyiraman Otomatis',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        Slider(
          value: _currentIntervalSeconds,
          min: 1,
          max: 60,
          divisions: 59,
          label: '${_currentIntervalSeconds.toStringAsFixed(0)} dtk',
          onChanged: _controlReady && !_isSendingControl
              ? (value) => setState(() => _intervalOverride = value)
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saat ini: ${_currentIntervalSeconds.toStringAsFixed(0)} detik',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            if (_controlState?.interval != null)
              Text(
                'Disimpan: ${(_intervalSeconds ?? 0).toStringAsFixed(0)} detik',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _intervalDirty && !_isSendingControl ? _saveInterval : null,
          icon: _isSendingControl && _intervalDirty
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save, size: 18),
          label: const Text('Simpan Interval'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green.shade700,
            side: BorderSide(color: Colors.green.shade400),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
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

  String _deriveStatus(SensorData data) {
    if (data.soilPercent < 30) return 'Needs Water';
    if (data.temperature > 30) return 'Too Hot';
    if (data.temperature < 15) return 'Too Cold';
    return 'Optimal';
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
            if (_historyLoading)
              _chartPlaceholder('Memuat histori sensor...')
            else if (_historyError != null)
              _chartPlaceholder(_historyError!)
            else if (data.isEmpty)
              _chartPlaceholder('Belum ada histori untuk rentang $_historyRange.')
            else
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

  List<FlSpot> _buildHistorySeries(double Function(SensorData) selector) {
    if (_historyRecords.isEmpty) return [];
    return _historyRecords.asMap().entries
        .map((entry) => FlSpot(entry.key.toDouble(), selector(entry.value)))
        .toList();
  }

  Widget? _sensorStatusBanner() {
    if (_sensorLoading) {
      return _sensorStatusTile(
        icon: Icons.sync,
        color: Colors.blueGrey.shade600,
        text: 'Sinkronisasi data sensor...',
      );
    }
    if (_sensorError != null) {
      return _sensorStatusTile(
        icon: Icons.error_outline,
        color: Colors.redAccent,
        text: _sensorError!,
      );
    }
    return null;
  }

  Widget _sensorStatusTile({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartPlaceholder(String message) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
