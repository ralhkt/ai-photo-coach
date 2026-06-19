import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../../../core/theme/app_design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_glass_widgets.dart';

/// One-time coach mark for the free-shoot AI analyze button.
class LiveSceneCoachBanner extends ConsumerWidget {
  const LiveSceneCoachBanner({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.15),
      duration: AppDesignTokens.motionMedium,
      curve: AppDesignTokens.motionEaseOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: AppDesignTokens.motionMedium,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: AppGlassSurface(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.coach,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.liveSceneCoachTitle,
                        style: const TextStyle(
                          color: AppDesignTokens.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.liveSceneCoachHint,
                        style: const TextStyle(
                          color: AppDesignTokens.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(appSettingsProvider.notifier)
                        .dismissLiveSceneCoach();
                  },
                  child: Text(l10n.liveSceneCoachDismiss),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}