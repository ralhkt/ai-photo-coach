import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ar_providers.dart';

/// Horizon guide derived from device attitude (complements native AR plane hints).
class ArHorizonOverlay extends ConsumerWidget {
  const ArHorizonOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final attitude = ref.watch(deviceAttitudeProvider).value;
    if (attitude == null) {
      return const SizedBox.shrink();
    }

    final rollOffset = (attitude.rollDegrees / 30).clamp(-1.0, 1.0);

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centerY = constraints.maxHeight * (0.5 + rollOffset * 0.08);

          return Stack(
            children: [
              Positioned(
                left: 24,
                right: 24,
                top: centerY,
                child: Container(
                  height: 1.5,
                  color: attitude.isLevel
                      ? const Color(0xAAFFD60A)
                      : Colors.white38,
                ),
              ),
              if (!attitude.isLevel)
                Positioned(
                  left: 0,
                  right: 0,
                  top: centerY - 28,
                  child: Center(
                    child: Icon(
                      attitude.rollDegrees > 0
                          ? Icons.rotate_right_rounded
                          : Icons.rotate_left_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}