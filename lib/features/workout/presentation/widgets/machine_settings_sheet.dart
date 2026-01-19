import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MachineSettingsSheet extends StatefulWidget {
  final String initialSettings;
  final Function(String) onSave;

  const MachineSettingsSheet({
    super.key,
    required this.initialSettings,
    required this.onSave,
  });

  @override
  State<MachineSettingsSheet> createState() => _MachineSettingsSheetState();
}

class _MachineSettingsSheetState extends State<MachineSettingsSheet> {
  int? _seatHeight;
  int? _backRest;
  int? _cableHeight;
  int? _pinNumber;
  String? _benchAngle;
  final TextEditingController _noteController = TextEditingController();


  final List<String> _angles = ["-15°", "0°", "15°", "30°", "45°", "60°", "75°", "90°"];

  @override
  void initState() {
    super.initState();
    _parseSettings(widget.initialSettings);
  }

  void _parseSettings(String settings) {
    if (settings.isEmpty) return;

    final parts = settings.split(' | ');
    for (var part in parts) {
      if (part.startsWith("Seat:")) {
        _seatHeight = int.tryParse(part.split(':')[1].trim());
      } else if (part.startsWith("Back:")) {
        _backRest = int.tryParse(part.split(':')[1].trim());
      } else if (part.startsWith("Cable:")) {
        _cableHeight = int.tryParse(part.split(':')[1].trim());
      } else if (part.startsWith("Pin:")) {
        _pinNumber = int.tryParse(part.split(':')[1].trim());
      } else if (part.startsWith("Angle:")) {
        _benchAngle = part.split(':')[1].trim();
      } else {
        // Add everything to note that is not defined
        if (_noteController.text.isNotEmpty) _noteController.text += " ";
        _noteController.text += part;
      }
    }
  }

  // Create string from variables
  String _generateSettingsString() {
    List<String> parts = [];
    if (_benchAngle != null) parts.add("Angle: $_benchAngle");
    if (_seatHeight != null) parts.add("Seat: $_seatHeight");
    if (_backRest != null) parts.add("Back: $_backRest");
    if (_cableHeight != null) parts.add("Cable: $_cableHeight");
    if (_pinNumber != null) parts.add("Pin: $_pinNumber");
    if (_noteController.text.trim().isNotEmpty) parts.add(_noteController.text.trim());

    return parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Machine Settings",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  // Clear button
                  setState(() {
                    _seatHeight = null;
                    _backRest = null;
                    _cableHeight = null;
                    _pinNumber = null;
                    _benchAngle = null;
                    _noteController.clear();
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.grey, size: 20),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // --- Bench angle ---
          const Text("Bench Angle", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _angles.map((angle) {
                final isSelected = _benchAngle == angle;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _benchAngle = isSelected ? null : angle;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.neonAccent : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.neonAccent : Colors.white10,
                      ),
                    ),
                    child: Text(
                      angle,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // --- Grid structure ---
          Row(
            children: [
              Expanded(child: _buildNumberSelector("Seat Height", _seatHeight, (val) => setState(() => _seatHeight = val))),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberSelector("Back Rest", _backRest, (val) => setState(() => _backRest = val))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildNumberSelector("Cable Height", _cableHeight, (val) => setState(() => _cableHeight = val), max: 20)),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberSelector("Pin Order", _pinNumber, (val) => setState(() => _pinNumber = val), max: 25)),
            ],
          ),

          const SizedBox(height: 20),

          // --- Special note ---
          TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Special note (Optional)",
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final result = _generateSettingsString();
                widget.onSave(result);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("AYARLARI KAYDET", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // +/- box
  Widget _buildNumberSelector(String label, int? value, Function(int?) onChanged, {int max = 15}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus button
              InkWell(
                onTap: () {
                  if (value != null && value > 1) {
                    onChanged(value - 1);
                  } else {
                    onChanged(null); // Reset if goes below 1
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.remove, color: Colors.white, size: 16),
                ),
              ),
              
              // Value
              Text(
                value?.toString() ?? "-",
                style: TextStyle(
                  color: value != null ? AppTheme.neonAccent : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              // Plus button
              InkWell(
                onTap: () {
                  final current = value ?? 0;
                  if (current < max) {
                    onChanged(current + 1);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}