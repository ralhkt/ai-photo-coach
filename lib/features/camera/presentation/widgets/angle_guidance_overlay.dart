import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/guidance_text.dart';

/// Visual tilt arrow for live angle guidance (MVP spec: text + arrow hints).
class AngleGuidanceOverlay extends StatelessWidget {
  const AngleGuidanceOverlay({
    super.key,
    required this.angleDegrees,
    required this.angleHintKey,
    required this.visible,
  });

  final double angleDegrees;
  final String angleHintKey;
  final bool visible;

  static const double _visibleThreshold = 2.0;

  @override
  Widget build(BuildContext context) {
    if (!visible || angleDegrees.abs() < _visibleThreshold) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final tiltUp = angleDegrees >= _visibleThreshold;
    final label = guidanceHintLabel(l10n, angleHintKey);

    return IgnorePointer(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tiltUp
                    ? Icons.arrow_circle_up_rounded
                    : Icons.arrow_circle_down_rounded,
                color: const Color(0xFFFFD60A),
                size: 44,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x44FFD60A)),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}