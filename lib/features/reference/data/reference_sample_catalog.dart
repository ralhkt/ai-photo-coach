import '../../../models/scene_type.dart';

/// Bundled reference photos offered alongside gallery upload in the picker.
///
/// Each [assetPath] maps to a curated lifestyle portrait reference.
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
  // pexels:7968332 — cheerful Asian woman café selfie
  ReferenceSample(
    id: 'checkin_cafe',
    assetPath: 'assets/reference_samples/checkin_cafe.jpg',
    sceneType: SceneType.portrait,
    titleKey: 'referenceSampleCheckinCafe',
    subtitleKey: 'referenceSampleCheckinCafeHint',
  ),
  // pexels:3760850 — neon night mood portrait
  ReferenceSample(
    id: 'checkin_neon_city',
    assetPath: 'assets/reference_samples/checkin_neon_city.jpg',
    sceneType: SceneType.portrait,
    titleKey: 'referenceSampleCheckinNeon',
    subtitleKey: 'referenceSampleCheckinNeonHint',
  ),
  // pexels:8788701 — mirror OOTD full-body selfie
  ReferenceSample(
    id: 'checkin_street_portrait',
    assetPath: 'assets/reference_samples/checkin_street_portrait.jpg',
    sceneType: SceneType.portrait,
    titleKey: 'referenceSampleCheckinPortrait',
    subtitleKey: 'referenceSampleCheckinPortraitHint',
  ),
  // pexels:20775929 — white dress café window seat
  ReferenceSample(
    id: 'checkin_brunch',
    assetPath: 'assets/reference_samples/checkin_brunch.jpg',
    sceneType: SceneType.portrait,
    titleKey: 'referenceSampleCheckinBrunch',
    subtitleKey: 'referenceSampleCheckinBrunchHint',
  ),
  // pexels:1557802 — woman scenic mountain vista
  ReferenceSample(
    id: 'checkin_travel_alps',
    assetPath: 'assets/reference_samples/checkin_travel_alps.jpg',
    sceneType: SceneType.portrait,
    titleKey: 'referenceSampleCheckinTravel',
    subtitleKey: 'referenceSampleCheckinTravelHint',
  ),
  // pexels:2671078 — beach sunset mood portrait
  ReferenceSample(
    id: 'checkin_beach_sunset',
    assetPath: 'assets/reference_samples/checkin_beach_sunset.jpg',
    sceneType: SceneType.portrait,
    titleKey: 'referenceSampleCheckinBeach',
    subtitleKey: 'referenceSampleCheckinBeachHint',
  ),
];