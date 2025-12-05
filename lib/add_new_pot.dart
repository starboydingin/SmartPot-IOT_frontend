import 'package:flutter/material.dart';

import 'services/device_service.dart';

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

class AddNewPotScreen extends StatefulWidget {
  const AddNewPotScreen({super.key});

  @override
  State<AddNewPotScreen> createState() => _AddNewPotScreenState();
}

class _AddNewPotScreenState extends State<AddNewPotScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _potNameController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();
  bool _isSubmitting = false;

  final DeviceService _deviceService = DeviceService();

  @override
  void dispose() {
    _potNameController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _registerDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await _deviceService.createDevice(
        deviceName: _deviceIdController.text.trim(),
        potName: _potNameController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device registered successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
        
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 30, // dikurangi dari 40 → supaya tidak nabrak
            ),
            constraints: const BoxConstraints(
              minHeight: 170, 
            ),
           decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildBackButton(() => Navigator.pop(context)),

                const SizedBox(height: 20),

                const Text(
                  "Add New Pot",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Connect a new smart plant pot",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 20),

          /// ================= FORM CARD =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pot Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInput(
                      controller: _potNameController,
                      hint: "e.g., Basil Plant",
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Choose a friendly name for your plant",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Device ID",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInput(
                      controller: _deviceIdController,
                      hint: "e.g., SPP-12345",
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Found on the device label",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // ================= BUTTON =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _registerDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Register Device",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Input Field
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'This field is required' : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
