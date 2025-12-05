import 'dart:async';

import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'models/notification_model.dart';
import 'services/notification_service.dart';
import 'services/websocket_service.dart';

/// ===============================================================
/// BACK BUTTON REUSABLE (SAMA DENGAN PUNYA KAMU)
/// ===============================================================
Widget buildBackButton(VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
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
  );
}

/// ===============================================================
/// FADE + SLIDE ROUTE
/// ===============================================================
Route createFadeSlideRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      final fadeTween = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}

/// ===============================================================
/// NOTIFICATION PAGE
/// ===============================================================
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  final WebSocketService _webSocketService = WebSocketService();

  List<NotificationModel> _notifications = [];
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  bool _wsConnecting = false;
  bool _wsConnected = false;
  String? _wsError;
  Timer? _wsRetryTimer;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _wsRetryTimer?.cancel();
    _webSocketService.disconnect(key: 'notifications');
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _notificationService.fetchActiveNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = data;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat notifikasi. Tarik ke bawah untuk mencoba lagi.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializePage() async {
    await _loadNotifications();
    if (!mounted) return;
    await _connectRealtime();
  }

  Future<void> _connectRealtime() async {
    setState(() {
      _wsConnecting = true;
      _wsError = null;
    });

    try {
      final stream = await _webSocketService.connectToNotifications();
      await _wsSubscription?.cancel();
      _wsSubscription = stream.listen(
        _handleRealtimeEvent,
        onError: _handleRealtimeError,
        onDone: () => _handleRealtimeError(null),
      );
    } catch (err) {
      _handleRealtimeError(err);
    }
  }

  void _handleRealtimeEvent(Map<String, dynamic> event) {
    final type = (event['type'] ?? '').toString();
    final payload = event['payload'];

    switch (type) {
      case 'connection:ack':
        _wsRetryTimer?.cancel();
        _wsRetryTimer = null;
        if (!mounted) return;
        setState(() {
          _wsConnecting = false;
          _wsConnected = true;
          _wsError = null;
        });
        break;
      case 'notification:list':
        final fresh = _parseNotificationList(payload);
        if (!mounted || fresh == null) return;
        setState(() {
          _notifications = fresh;
          _errorMessage = null;
        });
        break;
      case 'notification:new':
        final model = _parseNotification(payload);
        if (!mounted || model == null) return;
        setState(() {
          _notifications = [
            model,
            ..._notifications.where((item) => item.id != model.id),
          ];
        });
        break;
      case 'notification:cleared':
        if (!mounted) return;
        setState(() {
          _notifications = [];
        });
        break;
      default:
        break;
    }
  }

  void _handleRealtimeError(Object? error) {
    if (!mounted) return;
    setState(() {
      _wsConnected = false;
      _wsConnecting = false;
      _wsError = 'Koneksi realtime terputus. Mencoba sambungan ulang...';
    });
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_wsRetryTimer != null && _wsRetryTimer!.isActive) return;
    _wsRetryTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      _connectRealtime();
    });
  }

  List<NotificationModel>? _parseNotificationList(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    }
    if (payload is Map<String, dynamic> && payload['data'] is List) {
      return (payload['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    }
    return null;
  }

  NotificationModel? _parseNotification(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return NotificationModel.fromJson(payload);
    }
    if (payload is Map) {
      return NotificationModel.fromJson(Map<String, dynamic>.from(payload));
    }
    return null;
  }

  Future<void> _clearAll() async {
    try {
      await _notificationService.clearNotifications();
      if (!mounted) return;
      setState(() => _notifications = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi berhasil dihapus.')),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus notifikasi: $err')),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';

    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(timestamp.day)}/${twoDigits(timestamp.month)}/${timestamp.year} ${twoDigits(timestamp.hour)}:${twoDigits(timestamp.minute)}';
  }

  _NotificationVisual _resolveVisual(NotificationModel notification) {
    final message = notification.message.toLowerCase();
    if (message.contains('kering')) {
      return _NotificationVisual(Icons.water_drop_outlined, Colors.orange);
    }
    if (message.contains('basah')) {
      return _NotificationVisual(Icons.water, Colors.blueAccent);
    }
    if (message.contains('cahaya') || message.contains('gelap')) {
      return _NotificationVisual(Icons.wb_sunny_outlined, Colors.amber);
    }
    if (message.contains('suhu') || message.contains('temperature')) {
      return _NotificationVisual(Icons.thermostat, Colors.redAccent);
    }
    return _NotificationVisual(Icons.notifications_active_outlined, Colors.green);
  }

  Widget? _buildRealtimeBanner() {
    if (_wsConnecting) {
      return _statusCallout(
        background: Colors.orange.shade50,
        borderColor: Colors.orange.shade200,
        icon: Icons.wifi_tethering,
        iconColor: Colors.orange,
        text: 'Menyambungkan realtime notifikasi...',
        trailing: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }

    if (_wsError != null) {
      return _statusCallout(
        background: Colors.red.shade50,
        borderColor: Colors.red.shade200,
        icon: Icons.wifi_off,
        iconColor: Colors.red,
        text: _wsError!,
        trailing: TextButton(
          onPressed: () {
            _wsRetryTimer?.cancel();
            _wsRetryTimer = null;
            _connectRealtime();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Coba Lagi'),
        ),
      );
    }

    if (_wsConnected) {
      return _statusCallout(
        background: Colors.green.shade50,
        borderColor: Colors.green.shade200,
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
          text: 'Realtime aktif - notifikasi baru akan muncul otomatis.',
      );
    }

    return null;
  }

  Widget _statusCallout({
    required Color background,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String text,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final realtimeBanner = _buildRealtimeBanner();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      body: Column(
        children: [
          // =========================================================
          // HEADER
          // =========================================================
          Container(
            padding: const EdgeInsets.only(
                top: 60, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 🔥 REUSABLE BACK BUTTON
                buildBackButton(() {
                  Navigator.pushReplacement(
                    context,
                    createFadeSlideRoute(const DashboardScreen()),
                  );
                }),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notifikasi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_notifications.length} notifikasi aktif',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (realtimeBanner != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: realtimeBanner,
            ),

          // =========================================================
          // CLEAR ALL BUTTON
          // =========================================================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: _notifications.isEmpty ? null : _clearAll,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "Hapus Semua",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =========================================================
          // NOTIFICATION LIST
          // =========================================================
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada notifikasi",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          final visual = _resolveVisual(notif);
          final potName = notif.deviceName ?? 'Perangkat SmartPot';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border(
                left: BorderSide(
                  color: visual.color,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: visual.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    visual.icon,
                    color: visual.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              potName,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 8,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif.message,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(notif.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationVisual {
  final IconData icon;
  final Color color;

  const _NotificationVisual(this.icon, this.color);
}
