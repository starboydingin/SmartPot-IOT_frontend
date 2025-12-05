import 'package:flutter/material.dart';
import 'custom_back_button.dart';
import 'edit_pots_widget.dart';
import 'models/device_model.dart';
import 'services/device_service.dart';

class ManagePotsPage extends StatefulWidget {
  const ManagePotsPage({super.key});

  @override
  State<ManagePotsPage> createState() => _ManagePotsPageState();
}

class _ManagePotsPageState extends State<ManagePotsPage> {
  final DeviceService _deviceService = DeviceService();

  List<Device> _devices = [];
  bool _isLoading = true;
  String? _error;
  String? _mutatingDeviceId;
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

  Future<void> _handleRename(Device device, String newName) async {
    setState(() => _mutatingDeviceId = device.id);
    try {
      final updated = await _deviceService.updateDevice(
        device.id,
        potName: newName,
      );

      if (updated) {
        setState(() {
          _devices = _devices
              .map((d) => d.id == device.id
                  ? Device(
                      id: d.id,
                      deviceName: d.deviceName,
                      potName: newName,
                      mode: d.mode,
                      pumpStatus: d.pumpStatus,
                      createdAt: d.createdAt,
                      updatedAt: DateTime.now(),
                    )
                  : d)
              .toList();
          _hasChanges = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pot name updated')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update pot name')),
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
        setState(() => _mutatingDeviceId = null);
      }
    }
  }

  Future<void> _handleBack() async {
    Navigator.pop(context, _hasChanges);
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
        body: Column(
          children: [
            _buildHeader(),

          // LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _devices.isEmpty
                        ? const Center(child: Text('No devices yet'))
                        : RefreshIndicator(
                            onRefresh: _loadDevices,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                              itemCount: _devices.length,
                              itemBuilder: (context, index) {
                                final device = _devices[index];
                                return _buildPotCard(device);
                              },
                            ),
                          ),
          ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // HEADER
  // ==============================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 22),
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomBackButton(onPressed: _handleBack),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Manage Pots',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rename or configure devices',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================
  // LIST ITEM CARD
  // ==============================
  Widget _buildPotCard(Device device) {
    final isBusy = _mutatingDeviceId == device.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            // LEFT side: Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "ID: ${device.deviceName}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT side: EDIT button
            OutlinedButton.icon(
              onPressed: isBusy
                  ? null
                  : () {
                      showEditPotModal(
                        context: context,
                        initialName: device.displayName,
                        onSave: (newName) => _handleRename(device, newName),
                      );
                    },
              icon: const Icon(
                Icons.edit,
                size: 18,
                color: Color(0xFF2E7D32),
              ),
              label: isBusy
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Edit Pot",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4CAF50), width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
