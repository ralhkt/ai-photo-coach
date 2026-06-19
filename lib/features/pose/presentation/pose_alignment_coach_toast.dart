import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../providers/pose_coaching_provider.dart';
import '../providers/pose_silhouette_provider.dart';
import '../services/alignment_overlay_state.dart';

/// Flutter 對齊提示（Android 或原生輪廓不可用時的 fallback）。
class PoseAlignmentCoachToast extends ConsumerWidget {
  const PoseAlignmentCoachToast({
    super.key,
    this.visible = true,
    this.bottomInset = 132,
  });

  final bool visible;
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final nativeSupported =
        ref.watch(poseSilhouetteNativeSupportedProvider).valueOrNull ?? false;
    if (nativeSupported) {
      return const SizedBox.shrink();
    }

    final coaching = ref.watch(poseCoachingResultProvider);
    if (coaching == null || coaching.poseScore <= 0) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final phase = AlignmentOverlayState.phaseForScore(coaching.poseScore);
    final message = AlignmentOverlayState.toastForPhase(phase, l10n: l10n);
    final accent = AlignmentOverlayState.strokeColorForPhase(phase);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + bottomInset,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _ToastCapsule(
            key: ValueKey(message),
            message: message,
            accent: accent,
          ),
        ),
      ),
    );
  }
}

class _ToastCapsule extends StatelessWidget {
  const _ToastCapsule({
    super.key,
    required this.message,
    required this.accent,
  });

  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}