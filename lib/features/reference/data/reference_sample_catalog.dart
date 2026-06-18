import '../../../models/scene_type.dart';

/// Bundled reference photo offered in the picker (no camera / gallery upload).
class ReferenceSample {
  const ReferenceSample({
    required this.id,
    required this.assetPath,
    required this.sceneType,
    required this.titleKey,
    required this.subtitleKey,
  });

  final String id;
  final String assetPath;
  final SceneType sceneType;
  final String titleKey;
  final String subtitleKey;
}

const referenceSampleCatalog = <ReferenceSample>[
  ReferenceSample(
    id: 'portrait_classic',
    assetPath: 'assets/reference_samples/portrait_classic.jpg',
    sceneType: SceneType.portrait,
    titleKey: 'referenceSamplePortraitClassic',
    subtitleKey: 'referenceSamplePortraitClassicHint',
  ),
  ReferenceSample(
    id: 'portrait_story',
    assetPath: 'assets/reference_samples/portrait_story.jpg',
    sceneType: SceneType.portrait,
    titleKey: 'referenceSamplePortraitStory',
    subtitleKey: 'referenceSamplePortraitStoryHint',
  ),
  ReferenceSample(
    id: 'portrait_square',
    assetPath: 'assets/reference_samples/portrait_square.jpg',
    sceneType: SceneType.square,
    titleKey: 'referenceSamplePortraitSquare',
    subtitleKey: 'referenceSamplePortraitSquareHint',
  ),
  ReferenceSample(
    id: 'lifestyle_cafe',
    assetPath: 'assets/reference_samples/lifestyle_cafe.jpg',
    sceneType: SceneType.lifestyle,
    titleKey: 'referenceSampleLifestyleCafe',
    subtitleKey: 'referenceSampleLifestyleCafeHint',
  ),
];