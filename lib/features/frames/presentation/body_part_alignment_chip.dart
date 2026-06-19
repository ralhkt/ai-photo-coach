import 'package:flutter/material.dart';

import '../../../models/body_part_labels.dart';

class BodyPartAlignmentChip extends StatelessWidget {
  const BodyPartAlignmentChip({
    super.key,
    required this.labels,
    required this.title,
    required this.hasBodyParts,
    this.maxSteps = 4,
  });

  final BodyPartLabels labels;
  final String title;
  final bool hasBodyParts;
  final int maxSteps;

  @override
  Widget build(BuildContext context) {
    if (!hasBodyParts) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.accessibility_new_rounded,
                color: Color(0xFF64D2FF),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._steps().take(maxSteps),
        ],
      ),
    );
  }

  List<Widget> _steps() {
    return [
      _StepRow(
        icon: Icons.face_retouching_natural_rounded,
        text: labels.alignHead,
      ),
      _StepRow(
        icon: Icons.switch_access_shortcut_rounded,
        text: labels.alignShoulders,
      ),
      _StepRow(
        icon: Icons.person_outline_rounded,
        text: labels.alignTorso,
      ),
      _StepRow(
        icon: Icons.airline_seat_legroom_normal_rounded,
        text: labels.alignHips,
      ),
    ];
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}