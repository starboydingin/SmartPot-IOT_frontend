import 'package:flutter/material.dart';

import 'custom_back_button.dart';
import 'models/device_model.dart';
import 'services/device_service.dart';

class RemoveDevicePage extends StatefulWidget {
  const RemoveDevicePage({super.key});

  @override
  State<RemoveDevicePage> createState() => _RemoveDevicePageState();
}

class _RemoveDevicePageState extends State<RemoveDevicePage> {
  final DeviceService _deviceService = DeviceService();

  List<Device> _devices = [];
  bool _isLoading = true;
  String? _error;
  String? _removingId;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final devices = await _deviceService.getAllDevices();
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndRemove(Device device) async {
    final removed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmRemoveDialog(deviceName: device.displayName),
    );

    if (removed == true) {
      await _removeDevice(device);
    }
  }

  Future<void> _removeDevice(Device device) async {
    setState(() => _removingId = device.id);
    try {
      final success = await _deviceService.deleteDevice(device.id);
      if (success) {
        setState(() {
          _devices = _devices.where((d) => d.id != device.id).toList();
          _hasChanges = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${device.displayName} removed')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to remove ${device.displayName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _removingId = null);
      }
    }
  }

  Future<void> _handleBack() async {
    Navigator.pop(context, _hasChanges);
  }

  @override
  Widget build(BuildContext context) {
    const Color red = Color(0xFFE23939);

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
          // ================= HEADER =================
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16, top: 28),
            decoration: const BoxDecoration(
              color: red,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============ BACK BUTTON FIXED ============
                  CustomBackButton(
                    onPressed: _handleBack,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Remove Devices",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Disconnect pots from app",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ================= LIST DEVICE =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _devices.isEmpty
                          ? const Center(child: Text('No devices to remove'))
                          : RefreshIndicator(
                              onRefresh: _loadDevices,
                              child: ListView.separated(
                                itemCount: _devices.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                padding: const EdgeInsets.only(top: 8, bottom: 24),
                                itemBuilder: (context, index) {
                                  final device = _devices[index];
                                  return DeviceCard(
                                    device: device,
                                    isRemoving: _removingId == device.id,
                                    onRemovePressed: () => _confirmAndRemove(device),
                                  );
                                },
                              ),
                            ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

// ================= DEVICE CARD =================

class DeviceCard extends StatelessWidget {
  final Device device;
  final bool isRemoving;
  final VoidCallback onRemovePressed;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isRemoving,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    const Color red = Color(0xFFE23939);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            // LEFT SIDE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.displayName,
                    style: const TextStyle(
                      color: Color(0xFF3DAA3D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device.deviceName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // REMOVE BUTTON
            SizedBox(
              height: 45,
              child: OutlinedButton.icon(
                onPressed: isRemoving ? null : onRemovePressed,
                icon: isRemoving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline, size: 18),
                label: isRemoving
                    ? const Text('Removing...')
                    : const Text("Remove Device"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DIALOG =================

class ConfirmRemoveDialog extends StatelessWidget {
  final String deviceName;

  const ConfirmRemoveDialog({
    super.key,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    const Color red = Color(0xFFE23939);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Remove $deviceName?",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              "This action cannot be undone. This will permanently delete the device data, settings, and history for $deviceName.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF5E5E5E),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTONS
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Remove"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
