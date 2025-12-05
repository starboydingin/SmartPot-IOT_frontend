import 'dart:async';

import 'package:flutter/material.dart';
import 'manage_pots_page.dart';
import 'remove_device.dart';
import 'profile_settings.dart';
import 'login_screen.dart';
import 'models/control_state.dart';
import 'services/websocket_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedRefresh = -1; // -1 = tidak sinkron / custom
  bool _shouldRefreshDashboard = false;
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _controlSubscription;
  bool _controlLoading = true;
  bool _isUpdatingRefresh = false;
  String? _controlError;
  int? _activeIntervalSeconds;
  Map<String, ControlState> _controlStates = {};
  final List<int> _refreshDurations = [5, 30, 60];

  Future<void> _handleBack() async {
    Navigator.pop(context, _shouldRefreshDashboard);
  }

  @override
  void initState() {
    super.initState();
    _connectControlChannel();
  }

  @override
  void dispose() {
    _controlSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
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
                    onTap: _handleBack,
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
                  iconColor: Colors.green,
                  title: "Manage Pots",
                  subtitle: "Rename or configure devices",
                  onTap: () {
                    _openManagePots();
                  },
                ),
                divider(),
                buildMenuTile(
                  icon: Icons.delete_outline,
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: Colors.red,
                  title: "Remove Devices",
                  subtitle: "Disconnect pots from app",
                  onTap: () {
                    _openRemoveDevices();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= DATA REFRESH =================
            buildSectionCard(
              title: "Data Refresh",
              children: [
                _buildRefreshStatus(),
                const SizedBox(height: 12),
                buildRefreshOption(
                  index: 0,
                  current: selectedRefresh,
                  title: "Every 5 seconds",
                  subtitle: "Real-time monitoring",
                  enabled: _canInteractRefresh,
                ),
                buildRefreshOption(
                  index: 1,
                  current: selectedRefresh,
                  title: "Every 30 seconds",
                  subtitle: "Balanced mode",
                  enabled: _canInteractRefresh,
                ),
                buildRefreshOption(
                  index: 2,
                  current: selectedRefresh,
                  title: "Every 1 minute",
                  subtitle: "Save battery",
                  enabled: _canInteractRefresh,
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
                  iconColor: Colors.blue,
                  title: "Profile Settings",
                  subtitle: "Edit your information",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= LOGOUT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
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
      ),
    );
  }

  Future<void> _openManagePots() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ManagePotsPage()),
    );
    if (changed == true && mounted) {
      setState(() => _shouldRefreshDashboard = true);
    }
  }

  Future<void> _openRemoveDevices() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RemoveDevicePage()),
    );
    if (changed == true && mounted) {
      setState(() => _shouldRefreshDashboard = true);
    }
  }

    bool get _hasControlDevices => _controlStates.isNotEmpty;

    bool get _allIntervalsMissing =>
      _hasControlDevices && _controlStates.values.every((state) => state.interval == null);

    bool get _canInteractRefresh =>
      _hasControlDevices && !_controlLoading && _controlError == null && !_isUpdatingRefresh;

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
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _controlError = 'Koneksi kontrol terputus.';
            _controlLoading = false;
            _isUpdatingRefresh = false;
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            _controlError = 'Koneksi kontrol ditutup.';
          });
        },
      );
    } catch (_) {
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
      _applyControlList(payload);
      return;
    }

    if (type == 'control:updated' || type == 'control:detail') {
      final state = _parseControlState(payload);
      if (state != null) {
        final next = Map<String, ControlState>.from(_controlStates);
        next[state.deviceId] = state;
        _applyControlStates(next);
      }
      return;
    }

    if (type == 'control:error') {
      final message = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : 'Terjadi kesalahan kanal kontrol.';
      if (!mounted) return;
      setState(() {
        _controlError = message;
        _isUpdatingRefresh = false;
        _controlLoading = false;
      });
    }
  }

  ControlState? _parseControlState(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return ControlState.fromJson(payload);
    }
    if (payload is Map) {
      return ControlState.fromJson(Map<String, dynamic>.from(payload));
    }
    return null;
  }

  void _applyControlList(dynamic payload) {
    final nextStates = <String, ControlState>{};
    if (payload is List) {
      for (final item in payload) {
        final state = _parseControlState(item);
        if (state != null) {
          nextStates[state.deviceId] = state;
        }
      }
    } else {
      final state = _parseControlState(payload);
      if (state != null) {
        nextStates[state.deviceId] = state;
      }
    }
    _applyControlStates(nextStates);
  }

  void _applyControlStates(Map<String, ControlState> states) {
    if (!mounted) return;

    int nextSelected = -1;
    int? nextIntervalSeconds;
    if (states.isNotEmpty) {
      final intervals = states.values
          .map((state) => state.interval)
          .whereType<int>()
          .map((value) => (value / 1000).round())
          .toSet();

      if (intervals.length == 1) {
        nextIntervalSeconds = intervals.first;
        final matchedIndex = _refreshDurations.indexOf(nextIntervalSeconds);
        nextSelected = matchedIndex;
      } else {
        nextIntervalSeconds = null;
        nextSelected = -1;
      }
    }

    setState(() {
      _controlStates = states;
      _activeIntervalSeconds = nextIntervalSeconds;
      selectedRefresh = nextSelected;
      _controlLoading = false;
      _controlError = null;
      _isUpdatingRefresh = false;
    });
  }

  Future<void> _handleRefreshSelection(int index) async {
    if (!_canInteractRefresh) return;
    if (index < 0 || index >= _refreshDurations.length) return;

    final int seconds = _refreshDurations[index];
    if (_activeIntervalSeconds == seconds && selectedRefresh == index) {
      return;
    }

    final devices = _controlStates.values.toList();
    if (devices.isEmpty) return;

    setState(() {
      selectedRefresh = index;
      _activeIntervalSeconds = seconds;
      _isUpdatingRefresh = true;
      _controlError = null;
    });

    try {
      for (final device in devices) {
        await _webSocketService.sendControlMessage({
          'type': 'control:update',
          'payload': {
            'deviceId': device.deviceId,
            'interval': seconds * 1000,
          },
        });
      }

      if (!mounted) return;
      setState(() {
        _isUpdatingRefresh = false;
        _shouldRefreshDashboard = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isUpdatingRefresh = false;
        _controlError = 'Gagal memperbarui interval refresh.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat menyimpan interval refresh.')),
      );
    }
  }

  Widget _buildRefreshStatus() {
    if (_controlLoading) {
      return _statusBanner(
        icon: Icons.sync,
        color: Colors.blueGrey.shade600,
        text: 'Sinkronisasi interval refresh dari server...',
      );
    }

    if (_controlError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusBanner(
            icon: Icons.error_outline,
            color: Colors.red.shade400,
            text: _controlError!,
            subtitle: 'Ketuk coba lagi untuk menyambung ulang.',
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _connectControlChannel,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba lagi'),
            ),
          ),
        ],
      );
    }

    if (!_hasControlDevices) {
      return _statusBanner(
        icon: Icons.info_outline,
        color: Colors.blueGrey.shade500,
        text: 'Belum ada perangkat yang terhubung.',
        subtitle: 'Tambahkan perangkat agar interval dapat disinkronkan.',
      );
    }

    if (_allIntervalsMissing) {
      return _statusBanner(
        icon: Icons.pending_outlined,
        color: Colors.blueGrey.shade600,
        text: 'Interval otomatis belum dikonfigurasi.',
        subtitle: 'Atur threshold penyiraman atau pilih opsi di bawah untuk memulai.',
      );
    }

    if (_activeIntervalSeconds == null) {
      return _statusBanner(
        icon: Icons.warning_amber_rounded,
        color: Colors.orange.shade600,
        text: 'Interval tiap perangkat berbeda.',
        subtitle: 'Pilih salah satu opsi untuk menyeragamkan semua perangkat.',
      );
    }

    final selectedLabel = (selectedRefresh >= 0 && selectedRefresh < _refreshDurations.length)
      ? '${_refreshDurations[selectedRefresh]} detik'
      : '$_activeIntervalSeconds detik';

    final subtitle = selectedRefresh == -1
        ? 'Server menggunakan nilai kustom.'
        : 'Semua perangkat mengikuti pilihan ini.';

    return _statusBanner(
      icon: Icons.check_circle,
      color: Colors.green.shade600,
      text: 'Tersinkron setiap $selectedLabel.',
      subtitle: subtitle,
    );
  }

  Widget _statusBanner({
    required IconData icon,
    required Color color,
    required String text,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          )
        ],
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
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
      ),
    );
  }

  Widget buildRefreshOption({
    required int index,
    required int current,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    final bool isSelected = index == current;

    return GestureDetector(
      onTap: !enabled
          ? null
          : () {
              _handleRefreshSelection(index);
            },
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
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
                        color: isSelected ? Colors.green[700] : Colors.black87,
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
            if (_isUpdatingRefresh && isSelected)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? Colors.green : Colors.grey,
              )
          ],
        ),
      ),
      ),
    );
  }
}
