import 'package:flutter/material.dart';

/// Helper: show the edit pot modal.
/// - [context] BuildContext
/// - [initialName] initial pot name to prefill
/// - [onSave] callback with new name when user taps Save
Future<void> showEditPotModal({
  required BuildContext context,
  required String initialName,
  required ValueChanged<String> onSave,
}) {
  final TextEditingController controller = TextEditingController(text: initialName);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.28,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.only(
              top: 18,
              left: 18,
              right: 18,
              // ensure above keyboard when editing
              bottom: MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grab bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    'Edit Pot',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Pot Name',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g., Basil Plant',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      // Cancel (white + border thin + X icon)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close, color: Colors.black54),
                          label: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Save (green solid + save icon)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final newName = controller.text.trim();
                            if (newName.isNotEmpty) {
                              onSave(newName);
                              Navigator.of(context).pop();
                            } else {
                              // simple feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Name cannot be empty')),
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
