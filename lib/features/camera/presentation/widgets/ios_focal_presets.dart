import 'package:flutter/material.dart';

class IosFocalPresets extends StatelessWidget {
  const IosFocalPresets({
    super.key,
    required this.currentZoom,
    required this.onPresetTap,
  });

  final double currentZoom;
  final ValueChanged<double> onPresetTap;

  static const presets = <double>[0.5, 1.0, 1.2, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: presets.map((preset) {
        final active = (currentZoom - preset).abs() < 0.08;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => onPresetTap(preset),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? const Color(0x33FFD60A) : const Color(0x33282828),
                border: Border.all(
                  color: active ? const Color(0xFFFFD60A) : Colors.white24,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _label(preset),
                style: TextStyle(
                  color: active ? const Color(0xFFFFD60A) : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(double preset) {
    if (preset == 0.5) {
      return '.5';
    }
    if (preset == 1.0) {
      return '1';
    }
    if (preset == 1.2) {
      return '1.2';
    }
    if (preset == 1.5) {
      return '1.5';
    }
    return '2';
  }
}