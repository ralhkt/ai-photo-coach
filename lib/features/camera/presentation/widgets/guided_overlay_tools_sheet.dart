import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/guidance_text.dart';
import '../../../reference/providers/guided_frame_providers.dart';
import '../../../reference/providers/reference_providers.dart';
import '../../providers/camera_interaction_provider.dart';

Future<void> showGuidedOverlayToolsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surfaceGrouped,
    shape: const RoundedRectangleBorder(
      borderRadius: AppDesignTokens.sheetRadius,
    ),
    showDragHandle: true,
    builder: (context) => const _GuidedOverlayToolsSheet(),
  );
}

class _GuidedOverlayToolsSheet extends ConsumerWidget {
  const _GuidedOverlayToolsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ghostVisible = ref.watch(referenceGhostVisibleProvider);
    final analysis = ref.watch(referenceAnalysisProvider).value;
    final guidance = analysis?.guidance;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDesignTokens.screenPadding,
          AppDesignTokens.spaceLg,
          AppDesignTokens.screenPadding,
          AppDesignTokens.space2xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.guidedOverlayTools,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDesignTokens.spaceLg),
            _OverlayToggleTile(
              icon: Icons.opacity_rounded,
              title: l10n.toggleGhostOverlay,
              value: ghostVisible,
              onChanged: (value) {
                markGuidedUserActivity(ref);
                ref.read(referenceGhostVisibleProvider.notifier).state = value;
              },
            ),
            if (ghostVisible) ...[
              const SizedBox(height: AppDesignTokens.spaceSm),
              const RepaintBoundary(child: _GhostOpacitySlider()),
            ],
            if (guidance != null) ...[
              const SizedBox(height: AppDesignTokens.spaceMd),
              Text(
                guidanceHintLabel(l10n, guidance.framingHintKey),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (guidance.distanceHintKey.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  guidanceHintLabel(l10n, guidance.distanceHintKey),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppDesignTokens.textSecondary,
                      ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _GhostOpacitySlider extends ConsumerStatefulWidget {
  const _GhostOpacitySlider();

  @override
  ConsumerState<_GhostOpacitySlider> createState() =>
      _GhostOpacitySliderState();
}

class _GhostOpacitySliderState extends ConsumerState<_GhostOpacitySlider> {
  double? _dragOpacity;
  Timer? _commitTimer;

  @override
  void dispose() {
    _commitTimer?.cancel();
    super.dispose();
  }

  void _scheduleOpacityCommit(double value) {
    _commitTimer?.cancel();
    _commitTimer = Timer(const Duration(milliseconds: 48), () {
      if (!mounted) {
        return;
      }
      ref.read(referenceGhostOpacityProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storedOpacity = ref.watch(referenceGhostOpacityProvider);
    final opacity = (_dragOpacity ?? storedOpacity)
        .clamp(guidedGhostOpacityMin, guidedGhostOpacityMax);
    final percent = (opacity * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppTheme.coach, size: 22),
            const SizedBox(width: AppDesignTokens.spaceMd),
            Expanded(
              child: Text(
                l10n.guidedGhostOpacityLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              l10n.guidedGhostOpacityPercent(percent),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesignTokens.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
        Slider(
          value: opacity,
          min: guidedGhostOpacityMin,
          max: guidedGhostOpacityMax,
          divisions: 32,
          activeColor: AppTheme.coach,
          onChangeStart: (_) {
            markGuidedUserActivity(ref);
            _dragOpacity = storedOpacity;
          },
          onChanged: (value) {
            setState(() => _dragOpacity = value);
            _scheduleOpacityCommit(value);
          },
          onChangeEnd: (value) {
            _commitTimer?.cancel();
            ref.read(referenceGhostOpacityProvider.notifier).state = value;
            setState(() => _dragOpacity = null);
          },
        ),
      ],
    );
  }
}

class _OverlayToggleTile extends StatelessWidget {
  const _OverlayToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: AppTheme.coach),
      title: Text(title),
      value: value,
      activeThumbColor: Colors.black,
      activeTrackColor: AppTheme.coach,
      onChanged: onChanged,
    );
  }
}