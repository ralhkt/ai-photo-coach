import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import 'ios_camera_ui_kit.dart';

class IosExposureSlider extends StatelessWidget {
  const IosExposureSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback? onChangeStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IosCameraGlassPill(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.exposure, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: value,
              min: -2,
              max: 2,
              divisions: 16,
              activeColor: IosCameraUiKit.accentYellow,
              onChangeStart: onChangeStart == null
                  ? null
                  : (_) => onChangeStart!(),
              onChanged: onChanged,
            ),
          ),
          Text(
            l10n.exposureEvLabel(value.toStringAsFixed(1)),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}