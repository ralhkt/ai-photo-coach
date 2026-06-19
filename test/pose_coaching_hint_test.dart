import 'package:ai_photo_coach/core/l10n/generated/app_localizations_zh.dart';
import 'package:ai_photo_coach/core/utils/pose_coaching_hint.dart';
import 'package:ai_photo_coach/features/scene_stabilization/providers/scene_stability_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsZhTw();

  test('stable scene shows matched coaching copy', () {
    const status = SceneStabilityStatus(
      state: SceneStabilityState.stable,
      hammingDistance: 2,
    );

    expect(poseCoachingHint(l10n, status), l10n.poseCoachMatched);
    expect(isPoseAligned(status), isTrue);
  });

  test('monitoring scene shows aligning coaching copy', () {
    const status = SceneStabilityStatus(
      state: SceneStabilityState.monitoring,
      hammingDistance: 8,
    );

    expect(poseCoachingHint(l10n, status), l10n.poseCoachAligning);
    expect(isPoseAligned(status), isFalse);
  });
}