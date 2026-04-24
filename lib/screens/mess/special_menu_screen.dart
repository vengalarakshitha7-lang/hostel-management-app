import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class SpecialMenuScreen extends StatefulWidget {
  const SpecialMenuScreen({super.key});

  @override
  State<SpecialMenuScreen> createState() => _SpecialMenuScreenState();
}

class _SpecialMenuScreenState extends State<SpecialMenuScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  String _menuType = "regular";
  
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Menu Control", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _service.getMenuForDate(_today),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            // Prefill only if needed or show current
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentMenuSummary(snapshot),
                const SizedBox(height: 24),
                const Text("Update Today's Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // Menu Type Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      _toggleButton("regular"),
                      _toggleButton("special"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _inputField("Lunch Items", "e.g. Rice, Dal, Veg Curry", _lunchController, Icons.wb_sunny_outlined),
                const SizedBox(height: 16),
                _inputField("Dinner Items", "e.g. Roti, Paneer, Sweet", _dinnerController, Icons.nightlight_round_outlined),
                
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: _submitMenu,
                    child: const Text("Set Today's Menu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _toggleButton(String type) {
    bool isSelected = _menuType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _menuType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(
              type.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blue),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentMenuSummary(AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (!snapshot.hasData || !snapshot.data!.exists) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
        child: const Text("No custom menu set for today. Regular weekly menu will be used."),
      );
    }

    var data = snapshot.data!.data() as Map<String, dynamic>;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Current Set Menu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              Chip(label: Text(data['type'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.blue),
            ],
          ),
          const Divider(),
          _menuRow("Lunch", List<String>.from(data['lunch'] ?? [])),
          const SizedBox(height: 8),
          _menuRow("Dinner", List<String>.from(data['dinner'] ?? [])),
        ],
      ),
    );
  }

  Widget _menuRow(String label, List<String> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(items.join(", "))),
      ],
    );
  }

  void _submitMenu() async {
    if (_lunchController.text.isEmpty || _dinnerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter items for both meals")));
      return;
    }

    List<String> lunchItems = _lunchController.text.split(',').map((e) => e.trim()).toList();
    List<String> dinnerItems = _dinnerController.text.split(',').map((e) => e.trim()).toList();

    await _service.updateMenu(
      date: _today,
      type: _menuType,
      lunchItems: lunchItems,
      dinnerItems: dinnerItems,
    );

    _lunchController.clear();
    _dinnerController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu updated successfully!")));
    }
  }
}
