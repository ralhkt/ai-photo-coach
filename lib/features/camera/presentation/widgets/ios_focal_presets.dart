import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ios_camera_ui_kit.dart';

/// iOS Camera zoom row — 0.5 · 1x · 2 · 5 above the shutter.
class IosFocalPresets extends StatelessWidget {
  const IosFocalPresets({
    super.key,
    required this.currentZoom,
    required this.onPresetTap,
  });

  final double currentZoom;
  final ValueChanged<double> onPresetTap;

  static const presets = <double>[0.5, 1.0, 2.0, 5.0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: IosCameraUiKit.zoomRowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: presets.map((preset) {
          final active = _isActive(currentZoom, preset);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onPresetTap(preset);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: IosCameraUiKit.morphAnimation,
                padding: EdgeInsets.symmetric(
                  horizontal: active ? 10 : 6,
                  vertical: active ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  _label(preset),
                  style: active
                      ? IosCameraUiKit.zoomActive.copyWith(fontSize: 14)
                      : IosCameraUiKit.zoomInactive.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isActive(double current, double preset) {
    if (preset == 1.0) {
      return (current - 1.0).abs() < 0.12;
    }
    return (current - preset).abs() < 0.18;
  }

  String _label(double preset) {
    if (preset == 0.5) {
      return '0.5';
    }
    if (preset == 1.0) {
      return '1x';
    }
    if (preset == 2.0) {
      return '2';
    }
    return '5';
  }
}