import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings_provider.dart';

final voiceGuidanceServiceProvider = Provider<VoiceGuidanceService>((ref) {
  return VoiceGuidanceService(ref);
});

/// Placeholder for future TTS — when enabled, surfaces guidance as snackbars.
class VoiceGuidanceService {
  VoiceGuidanceService(this._ref);

  final Ref _ref;

  void speak(BuildContext context, String message) {
    final enabled = _ref.read(voiceGuidanceEnabledProvider);
    if (!enabled || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}