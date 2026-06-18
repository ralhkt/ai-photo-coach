import '../l10n/generated/app_localizations.dart';
import '../../models/body_part_labels.dart';
import '../../models/photo_frame_template.dart';
import '../../models/scene_type.dart';

String frameTemplateLabel(AppLocalizations l10n, PhotoFrameTemplate template) {
  return switch (template) {
    PhotoFrameTemplate.portraitPost => l10n.framePortraitPost,
    PhotoFrameTemplate.story => l10n.frameStory,
    PhotoFrameTemplate.squarePost => l10n.frameSquarePost,
    PhotoFrameTemplate.landscapePost => l10n.frameLandscapePost,
    PhotoFrameTemplate.classicPortrait => l10n.frameClassicPortrait,
  };
}

String sceneTypeLabel(AppLocalizations l10n, String sceneTypeKey) {
  return switch (sceneTypeKey) {
    'scenePortrait' => l10n.scenePortrait,
    'sceneLandscape' => l10n.sceneLandscape,
    'sceneSquare' => l10n.sceneSquare,
    _ => l10n.sceneLifestyle,
  };
}

String sceneTypeChoiceLabel(AppLocalizations l10n, SceneType scene) {
  return switch (scene) {
    SceneType.auto => l10n.sceneTypeAuto,
    SceneType.portrait => l10n.sceneTypePortrait,
    SceneType.landscape => l10n.sceneTypeLandscape,
    SceneType.lifestyle => l10n.sceneTypeLifestyle,
    SceneType.square => l10n.sceneTypeSquare,
    SceneType.group => l10n.sceneTypeGroup,
    SceneType.product => l10n.sceneTypeProduct,
  };
}

String guidanceHintLabel(AppLocalizations l10n, String hintKey) {
  return switch (hintKey) {
    'hintFramingLeft' => l10n.hintFramingLeft,
    'hintFramingRight' => l10n.hintFramingRight,
    'hintFramingHigh' => l10n.hintFramingHigh,
    'hintFramingLow' => l10n.hintFramingLow,
    'hintFramingCenter' => l10n.hintFramingCenter,
    'hintExposureBrighten' => l10n.hintExposureBrighten,
    'hintExposureDarken' => l10n.hintExposureDarken,
    'hintExposureBalanced' => l10n.hintExposureBalanced,
    'hintDistanceCloser' => l10n.hintDistanceCloser,
    'hintDistanceFurther' => l10n.hintDistanceFurther,
    'hintDistanceGood' => l10n.hintDistanceGood,
    'hintAngleLower' => l10n.hintAngleLower,
    'hintAngleHigher' => l10n.hintAngleHigher,
    _ => l10n.hintAngleLevel,
  };
}

BodyPartLabels bodyPartLabels(AppLocalizations l10n) {
  return BodyPartLabels(
    head: l10n.bodyPartHead,
    shoulders: l10n.bodyPartShoulders,
    torso: l10n.bodyPartTorso,
    hips: l10n.bodyPartHips,
    alignHead: l10n.alignmentStepHead,
    alignShoulders: l10n.alignmentStepShoulders,
    alignTorso: l10n.alignmentStepTorso,
    alignHips: l10n.alignmentStepHips,
  );
}

String insightLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'insightColorWarm' => l10n.insightColorWarm,
    'insightColorCool' => l10n.insightColorCool,
    'insightColorNeutral' => l10n.insightColorNeutral,
    'insightLightingTop' => l10n.insightLightingTop,
    'insightLightingBottom' => l10n.insightLightingBottom,
    'insightLightingBacklit' => l10n.insightLightingBacklit,
    'insightLightingEven' => l10n.insightLightingEven,
    'insightBalanceCentered' => l10n.insightBalanceCentered,
    'insightBalanceLeft' => l10n.insightBalanceLeft,
    'insightBalanceRight' => l10n.insightBalanceRight,
    'insightBalanceDynamic' => l10n.insightBalanceDynamic,
    'insightMoodDramatic' => l10n.insightMoodDramatic,
    'insightMoodBrightWarm' => l10n.insightMoodBrightWarm,
    'insightMoodSoft' => l10n.insightMoodSoft,
    'insightMoodNatural' => l10n.insightMoodNatural,
    'insightDepthShallow' => l10n.insightDepthShallow,
    'insightDepthDeep' => l10n.insightDepthDeep,
    'insightDepthModerate' => l10n.insightDepthModerate,
    'insightTipPortraitHeadroom' => l10n.insightTipPortraitHeadroom,
    'insightTipPortraitCropTight' => l10n.insightTipPortraitCropTight,
    'insightTipLandscapeHorizon' => l10n.insightTipLandscapeHorizon,
    'insightTipLandscapeForeground' => l10n.insightTipLandscapeForeground,
    'insightTipProductCleanBg' => l10n.insightTipProductCleanBg,
    'insightTipRaiseExposure' => l10n.insightTipRaiseExposure,
    'insightTipLowerExposure' => l10n.insightTipLowerExposure,
    'insightTipIncreaseContrast' => l10n.insightTipIncreaseContrast,
    'insightTipBacklitFill' => l10n.insightTipBacklitFill,
    'insightTipKeepNegativeSpace' => l10n.insightTipKeepNegativeSpace,
    'insightTipWarmSkinTones' => l10n.insightTipWarmSkinTones,
    'mlTipFaceDetected' => l10n.mlTipFaceDetected,
    'mlTipPoseDetected' => l10n.mlTipPoseDetected,
    'mlTipHighAesthetic' => l10n.mlTipHighAesthetic,
    _ => key,
  };
}

String mlAnalysisSourceLabel(AppLocalizations l10n, String source) {
  return switch (source) {
    'ml_kit' || 'ml_kit_hybrid' => l10n.mlAnalysisSourceMlKit,
    _ => l10n.mlAnalysisSourceFallback,
  };
}