import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';

/// Semi-transparent preview overlay while live scene analysis runs.
class LiveSceneAnalyzingOverlay extends StatelessWidget {
  const LiveSceneAnalyzingOverlay({
    super.key,
    required this.visible,
    required this.autoTriggered,
  });

  final bool visible;
  final bool autoTriggered;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final message = autoTriggered
        ? l10n.liveSceneAutoAnalyzing
        : l10n.liveSceneAnalyzingOverlay;

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.22),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x55FFD60A)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFFFD60A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.liveSceneAnalyzingHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}