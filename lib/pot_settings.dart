import 'dart:async';

import 'package:flutter/material.dart';
import 'custom_back_button.dart'; // ⬅️ pastikan path sesuai
import 'models/threshold_models.dart';
import 'services/threshold_service.dart';
import 'services/websocket_service.dart';

class PotSettingsPage extends StatefulWidget {
  final String deviceId;
  final String plantName;
  const PotSettingsPage({super.key, required this.deviceId, this.plantName = "Basil Plant"});

  @override
  State<PotSettingsPage> createState() => _PotSettingsPageState();
}

class _PotSettingsPageState extends State<PotSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ThresholdService _thresholdService = ThresholdService();
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _thresholdSubscription;

  SoilThresholds? _soilThresholds;
  bool _soilLoading = true;
  String? _soilError;
  bool _soilSaving = false;

  Bh1750Threshold? _bhThreshold;
  bool _bhLoading = true;
  String? _bhError;
  bool _bhSaving = false;

  Dht22Threshold? _dhtThreshold;
  bool _dhtLoading = true;
  String? _dhtError;
  bool _dhtSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bootstrapThresholds();
    _connectThresholdChannel();
  }

  @override
  void dispose() {
    _thresholdSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
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
    if (_soilLoading && _soilThresholds == null) {
      return _buildCenteredStatus('Mengambil ambang tanah dari server...');
    }

    if (_soilThresholds == null) {
      return _buildErrorState(
        _soilError ?? 'Ambang tanah belum tersedia untuk perangkat ini.',
        _loadSoilFromApi,
      );
    }

    final soil = _soilThresholds!;
    return _buildScrollableColumn([
      if (_soilError != null)
        _infoBanner(_soilError!, isError: true),
      _buildSliderCard(
        title: "Batas Tanah Kering",
        color: Colors.green,
        description: "Titik kelembapan tanah di mana sistem mulai penyiraman otomatis.",
        value: _clampValue(soil.soilDry, 20, 80),
        min: 20,
        max: 80,
        unit: "%",
        labelMin: "Dry (20%)",
        labelMax: "Moist (80%)",
        onChanged: (v) => setState(() => _soilThresholds = soil.copyWith(soilDry: v)),
        enabled: !_soilSaving,
      ),
      _buildSliderCard(
        title: "Batas Tanah Basah",
        color: Colors.green,
        description: "Titik kelembapan tanah di mana sistem berhenti menyiram.",
        value: _clampValue(soil.soilWet, 30, 90),
        min: 30,
        max: 90,
        unit: "%",
        labelMin: "Moist (30%)",
        labelMax: "Wet (90%)",
        onChanged: (v) => setState(() => _soilThresholds = soil.copyWith(soilWet: v)),
        enabled: !_soilSaving,
      ),
      _buildSliderCard(
        title: "Jeda Antar Penyiraman",
        color: Colors.green,
        description: "Waktu tunggu sebelum penyiraman otomatis berikutnya.",
        value: _clampValue(soil.wateringDelay, 30, 900),
        min: 30,
        max: 900,
        unit: " s",
        labelMin: "Fast (30s)",
        labelMax: "Slow (900s)",
        onChanged: (v) => setState(() => _soilThresholds = soil.copyWith(wateringDelay: v)),
        enabled: !_soilSaving,
      ),
      _buildSliderCard(
        title: "Durasi Maksimal Pompa Aktif",
        color: Colors.green,
        description: "Batas maksimal pompa menyala untuk mencegah overwatering.",
        value: _clampValue(soil.maxPumpDuration, 5, 180),
        min: 5,
        max: 180,
        unit: " s",
        labelMin: "Short (5s)",
        labelMax: "Long (180s)",
        onChanged: (v) => setState(() => _soilThresholds = soil.copyWith(maxPumpDuration: v)),
        enabled: !_soilSaving,
      ),
      _buildSaveButton(
        label: 'Simpan Ambang Tanah',
        loading: _soilSaving,
        onPressed: _soilSaving ? null : _saveSoilThreshold,
      ),
    ]);
  }

  // ============================================================
  // LUX INTENSITY
  // ============================================================

  Widget _buildLuxIntensitySettings() {
    if (_bhLoading && _bhThreshold == null) {
      return _buildCenteredStatus('Mengambil ambang cahaya dari server...');
    }

    if (_bhThreshold == null) {
      return _buildErrorState(
        _bhError ?? 'Belum ada ambang cahaya untuk perangkat ini.',
        _loadBhFromApi,
      );
    }

    final bh = _bhThreshold!;
    return _buildScrollableColumn([
      if (_bhError != null) _infoBanner(_bhError!, isError: true),
      _buildSliderCard(
        title: "Ambang Cahaya Minimum",
        color: Colors.orange,
        description:
            "Intensitas cahaya yang memicu lampu tambahan atau notifikasi kekurangan cahaya.",
        value: _clampValue(bh.lightLowThreshold, 100, 40000),
        min: 100,
        max: 40000,
        unit: " lx",
        labelMin: "Redup (100 lx)",
        labelMax: "Terang (40k lx)",
        onChanged: (v) => setState(() => _bhThreshold = bh.copyWith(lightLowThreshold: v)),
        enabled: !_bhSaving,
      ),
      const SizedBox(height: 12),
      _infoBanner(
        'Nilai ini akan dikirim ke firmware (topic `smartpot/<device>/bh1750`) dan dibroadcast ke semua layar yang terhubung.',
        isError: false,
      ),
      _buildSaveButton(
        label: 'Simpan Ambang Cahaya',
        loading: _bhSaving,
        onPressed: _bhSaving ? null : _saveBhThreshold,
      ),
    ]);
  }

  // ============================================================
  // TEMP & HUMIDITY
  // ============================================================

  Widget _buildTempHumiditySettings() {
    if (_dhtLoading && _dhtThreshold == null) {
      return _buildCenteredStatus('Mengambil ambang suhu & kelembapan...');
    }

    if (_dhtThreshold == null) {
      return _buildErrorState(
        _dhtError ?? 'Belum ada ambang DHT22 yang tersimpan.',
        _loadDhtFromApi,
      );
    }

    final dht = _dhtThreshold!;
    return _buildScrollableColumn([
      if (_dhtError != null) _infoBanner(_dhtError!, isError: true),
      _buildSliderCard(
        title: "Ambang Suhu Panas",
        color: Colors.blue,
        description: "Suhu udara mulai dianggap tinggi (penyiraman lebih cepat).",
        value: _clampValue(dht.tempHot, 20, 45),
        min: 20,
        max: 45,
        unit: " °C",
        labelMin: "Sejuk",
        labelMax: "Panas",
        onChanged: (v) => setState(() => _dhtThreshold = dht.copyWith(tempHot: v)),
        enabled: !_dhtSaving,
      ),
      _buildSliderCard(
        title: "Ambang Suhu Ekstrem",
        color: Colors.blue,
        description: "Suhu kritis yang memicu notifikasi panas berlebih.",
        value: _clampValue(dht.tempExtreme, 25, 55),
        min: 25,
        max: 55,
        unit: " °C",
        labelMin: "Nyaman",
        labelMax: "Ekstrem",
        onChanged: (v) => setState(() => _dhtThreshold = dht.copyWith(tempExtreme: v)),
        enabled: !_dhtSaving,
      ),
      _buildSliderCard(
        title: "Ambang Kelembapan Udara Rendah",
        color: Colors.blue,
        description: "Kelembapan udara di mana sistem menyesuaikan penyiraman.",
        value: _clampValue(dht.humLow, 10, 90),
        min: 10,
        max: 90,
        unit: " %",
        labelMin: "Kering",
        labelMax: "Lembap",
        onChanged: (v) => setState(() => _dhtThreshold = dht.copyWith(humLow: v)),
        enabled: !_dhtSaving,
      ),
      _buildSaveButton(
        label: 'Simpan Ambang DHT22',
        loading: _dhtSaving,
        onPressed: _dhtSaving ? null : _saveDhtThreshold,
      ),
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
    bool enabled = true,
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
              activeColor: enabled ? Colors.black : Colors.grey,
              inactiveColor: Colors.grey.shade300,
              onChanged: enabled ? onChanged : null,
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

  Widget _buildSaveButton({
    required String label,
    required bool loading,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(loading ? 'Menyimpan...' : label),
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

  Widget _buildCenteredStatus(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, Future<void> Function() retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner(String message, {bool isError = false}) {
    final color = isError ? Colors.red : Colors.green;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isError ? Colors.red.shade50 : Colors.green.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isError ? Icons.warning_amber_rounded : Icons.info_outline, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  double _clampValue(double value, double min, double max) {
    return value.clamp(min, max).toDouble();
  }

  Future<void> _bootstrapThresholds() async {
    await Future.wait([
      _loadSoilFromApi(),
      _loadBhFromApi(),
      _loadDhtFromApi(),
    ]);
  }

  Future<void> _loadSoilFromApi() async {
    setState(() {
      _soilLoading = true;
      _soilError = null;
    });

    try {
      final snapshot = await _thresholdService.fetchSoil(widget.deviceId);
      if (!mounted) return;
      setState(() {
        _soilThresholds = snapshot.soil;
        _soilLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _soilLoading = false;
        _soilError = 'Gagal memuat ambang tanah: $error';
      });
    }
  }

  Future<void> _loadBhFromApi() async {
    setState(() {
      _bhLoading = true;
      _bhError = null;
    });

    try {
      final snapshot = await _thresholdService.fetchBh1750(widget.deviceId);
      if (!mounted) return;
      setState(() {
        _bhThreshold = snapshot.bh1750;
        _bhLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bhLoading = false;
        _bhError = 'Gagal memuat ambang cahaya: $error';
      });
    }
  }

  Future<void> _loadDhtFromApi() async {
    setState(() {
      _dhtLoading = true;
      _dhtError = null;
    });

    try {
      final snapshot = await _thresholdService.fetchDht22(widget.deviceId);
      if (!mounted) return;
      setState(() {
        _dhtThreshold = snapshot.dht22;
        _dhtLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _dhtLoading = false;
        _dhtError = 'Gagal memuat ambang DHT22: $error';
      });
    }
  }

  Future<void> _connectThresholdChannel() async {
    try {
      final stream = await _webSocketService.connectToThresholds();
      if (_thresholdSubscription != null) {
        await _thresholdSubscription!.cancel();
      }
      _thresholdSubscription = stream.listen(
        _handleThresholdEvent,
        onError: (error) {
          if (!mounted) return;
          final friendly = 'Koneksi threshold terputus: $error';
          setState(() {
            _soilError ??= friendly;
            _bhError ??= friendly;
            _dhtError ??= friendly;
          });
        },
      );

      await Future.wait([
        _webSocketService.requestSoilThreshold(widget.deviceId),
        _webSocketService.requestBh1750Threshold(widget.deviceId),
        _webSocketService.requestDht22Threshold(widget.deviceId),
      ]);
    } catch (error) {
      if (!mounted) return;
      final friendly = 'Tidak bisa terhubung ke channel threshold: $error';
      setState(() {
        _soilError ??= friendly;
        _bhError ??= friendly;
        _dhtError ??= friendly;
        _soilLoading = false;
        _bhLoading = false;
        _dhtLoading = false;
      });
    }
  }

  void _handleThresholdEvent(Map<String, dynamic> event) {
    final type = (event['type'] ?? '').toString();
    final payload = _mapOrEmpty(event['payload']);

    switch (type) {
      case 'threshold:soil:detail':
      case 'threshold:soil:updated':
        _applySoilSnapshot(payload);
        break;
      case 'threshold:bh1750:detail':
      case 'threshold:bh1750:updated':
        _applyBhSnapshot(payload);
        break;
      case 'threshold:dht22:detail':
      case 'threshold:dht22:updated':
        _applyDhtSnapshot(payload);
        break;
      case 'threshold:error':
        final message = payload['message']?.toString() ?? 'Terjadi kesalahan pada kanal threshold.';
        if (!mounted) return;
        setState(() {
          _soilError = message;
          _bhError = message;
          _dhtError = message;
          _soilSaving = false;
          _bhSaving = false;
          _dhtSaving = false;
        });
        break;
      default:
        break;
    }
  }

  void _applySoilSnapshot(Map<String, dynamic> payload) {
    try {
      final snapshot = SoilThresholdSnapshot.fromJson(payload);
      if (!mounted) return;
      setState(() {
        _soilThresholds = snapshot.soil;
        _soilLoading = false;
        _soilSaving = false;
        _soilError = null;
      });
    } catch (error) {
      debugPrint('Gagal mem-parsing payload soil: $error');
    }
  }

  void _applyBhSnapshot(Map<String, dynamic> payload) {
    try {
      final snapshot = Bh1750ThresholdSnapshot.fromJson(payload);
      if (!mounted) return;
      setState(() {
        _bhThreshold = snapshot.bh1750;
        _bhLoading = false;
        _bhSaving = false;
        _bhError = null;
      });
    } catch (error) {
      debugPrint('Gagal mem-parsing payload bh1750: $error');
    }
  }

  void _applyDhtSnapshot(Map<String, dynamic> payload) {
    try {
      final snapshot = Dht22ThresholdSnapshot.fromJson(payload);
      if (!mounted) return;
      setState(() {
        _dhtThreshold = snapshot.dht22;
        _dhtLoading = false;
        _dhtSaving = false;
        _dhtError = null;
      });
    } catch (error) {
      debugPrint('Gagal mem-parsing payload dht22: $error');
    }
  }

  Future<void> _saveSoilThreshold() async {
    final soil = _soilThresholds;
    if (soil == null) return;
    setState(() {
      _soilSaving = true;
      _soilError = null;
    });

    try {
      await _webSocketService.updateSoilThreshold(widget.deviceId, soil.toMap());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _soilSaving = false;
        _soilError = 'Gagal menyimpan ambang tanah: $error';
      });
    }
  }

  Future<void> _saveBhThreshold() async {
    final bh = _bhThreshold;
    if (bh == null) return;
    setState(() {
      _bhSaving = true;
      _bhError = null;
    });

    try {
      await _webSocketService.updateBh1750Threshold(widget.deviceId, bh.toMap());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bhSaving = false;
        _bhError = 'Gagal menyimpan ambang cahaya: $error';
      });
    }
  }

  Future<void> _saveDhtThreshold() async {
    final dht = _dhtThreshold;
    if (dht == null) return;
    setState(() {
      _dhtSaving = true;
      _dhtError = null;
    });

    try {
      await _webSocketService.updateDht22Threshold(widget.deviceId, dht.toMap());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _dhtSaving = false;
        _dhtError = 'Gagal menyimpan ambang DHT22: $error';
      });
    }
  }

  Map<String, dynamic> _mapOrEmpty(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}
