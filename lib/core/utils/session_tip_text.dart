import '../l10n/generated/app_localizations.dart';

String sessionTipLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'sessionTipGuidedPractice' => l10n.sessionTipGuidedPractice,
    'sessionTipTryGuided' => l10n.sessionTipTryGuided,
    'sessionTipStrongComposition' => l10n.sessionTipStrongComposition,
    'sessionTipImproveLighting' => l10n.sessionTipImproveLighting,
    'sessionTipRefineFraming' => l10n.sessionTipRefineFraming,
    'sessionTipTooDark' => l10n.sessionTipTooDark,
    'sessionTipTooBright' => l10n.sessionTipTooBright,
    'sessionTipBalancedExposure' => l10n.sessionTipBalancedExposure,
    'sessionTipGreatVolume' => l10n.sessionTipGreatVolume,
    _ => key,
  };
}