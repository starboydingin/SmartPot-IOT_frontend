import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_back_button.dart';

class RemoveDevicePage extends StatelessWidget {
  const RemoveDevicePage({super.key});

  static final List<Map<String, String>> _devices = [
    {"name": "Basil Plant", "id": "SPP-10001"},
    {"name": "Mint Plant", "id": "SPP-10002"},
    {"name": "Succulent", "id": "SPP-10003"},
  ];

  @override
  Widget build(BuildContext context) {
    const Color red = Color(0xFFE23939);

    return Scaffold(
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
                    onPressed: () => Navigator.pop(context),
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
              child: ListView.separated(
                itemCount: _devices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return DeviceCard(
                    name: device['name']!,
                    id: device['id']!,
                    onRemovePressed: () async {
                      final removed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) =>
                            ConfirmRemoveDialog(deviceName: device['name']!),
                      );

                      if (removed == true && context.mounted) {
                        debugPrint("Device ${device['name']} removed");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Device ${device['name']} removed"),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= DEVICE CARD =================

class DeviceCard extends StatelessWidget {
  final String name;
  final String id;
  final VoidCallback onRemovePressed;

  const DeviceCard({
    super.key,
    required this.name,
    required this.id,
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
                    name,
                    style: const TextStyle(
                      color: Color(0xFF3DAA3D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    id,
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
                onPressed: onRemovePressed,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text("Remove Device"),
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
