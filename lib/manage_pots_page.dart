import 'package:flutter/material.dart';
import 'custom_back_button.dart';
import 'edit_pots_widget.dart';

class ManagePotsPage extends StatefulWidget {
  const ManagePotsPage({super.key});

  @override
  State<ManagePotsPage> createState() => _ManagePotsPageState();
}

class _ManagePotsPageState extends State<ManagePotsPage> {
  // dummy initial data
  final List<Map<String, String>> _pots = [
    {"name": "Basil Plant", "id": "SPP-10001"},
    {"name": "Succulent", "id": "SPP-10003"},
    {"name": "Basil Plant", "id": "SPP-10002"},
  ];

  void _editPotName(int index, String newName) {
    setState(() {
      _pots[index]['name'] = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          _buildHeader(),

          // LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              itemCount: _pots.length,
              itemBuilder: (context, index) {
                final pot = _pots[index];
                return _buildPotCard(index, pot['name']!, pot['id']!);
              },
            ),
          ),
        ],
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
          CustomBackButton(onPressed: () => Navigator.pop(context)),
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
  Widget _buildPotCard(int index, String name, String id) {
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
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "ID: $id",
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
              onPressed: () {
                showEditPotModal(
                  context: context,
                  initialName: name,
                  onSave: (newName) => _editPotName(index, newName),
                );
              },
              icon: const Icon(
                Icons.edit,
                size: 18,
                color: Color(0xFF2E7D32),
              ),
              label: const Text(
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
