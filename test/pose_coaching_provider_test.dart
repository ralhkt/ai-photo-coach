import 'package:ai_photo_coach/core/l10n/generated/app_localizations_zh.dart';
import 'package:ai_photo_coach/core/utils/pose_coaching_hint.dart';
import 'package:ai_photo_coach/features/pose/models/pose_coaching_result.dart';
import 'package:ai_photo_coach/features/pose/providers/pose_coaching_provider.dart';
import 'package:ai_photo_coach/features/scene_stabilization/providers/scene_stability_provider.dart';
import 'package:ai_photo_coach/models/shoot_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsZhTw();

  group('shouldRunPoseCoaching', () {
    test('runs in guided mode when power save is off', () {
      expect(
        shouldRunPoseCoaching(
          session: ShootSession(
            id: '1',
            mode: ShootSessionMode.guided,
            startedAt: DateTime(2026),
            captures: const [],
          ),
          hasLiveSceneAnalysis: false,
          powerSaveEnabled: false,
        ),
        isTrue,
      );
    });

    test('runs in free mode when live scene analysis is active', () {
      expect(
        shouldRunPoseCoaching(
          session: ShootSession(
            id: '1',
            mode: ShootSessionMode.free,
            startedAt: DateTime(2026),
            captures: const [],
          ),
          hasLiveSceneAnalysis: true,
          powerSaveEnabled: false,
        ),
        isTrue,
      );
    });

    test('pauses when power save is enabled', () {
      expect(
        shouldRunPoseCoaching(
          session: ShootSession(
            id: '1',
            mode: ShootSessionMode.guided,
            startedAt: DateTime(2026),
            captures: const [],
          ),
          hasLiveSceneAnalysis: true,
          powerSaveEnabled: true,
        ),
        isFalse,
      );
    });
  });

  group('resolvePoseCoachingMessage', () {
    test('prefers combined guidance from live coaching', () {
      const coaching = PoseCoachingResult(
        isLevel: false,
        poseScore: 40,
        proportionStatus: 'OK',
        tiltGuidance: '手機請向右旋轉 3 度',
        combinedGuidance: '手機請向右旋轉 3 度',
      );

      expect(
        resolvePoseCoachingMessage(
          l10n: l10n,
          stability: const SceneStabilityStatus(
            state: SceneStabilityState.stable,
            hammingDistance: 1,
          ),
          coaching: coaching,
        ),
        '手機請向右旋轉 3 度',
      );
    });
  });

  group('isPoseCoachingAligned', () {
    test('requires level, proportion, and pose match when coaching exists', () {
      const coaching = PoseCoachingResult(
        isLevel: true,
        poseScore: 92,
        proportionStatus: 'OK',
        tiltGuidance: 'OK',
        combinedGuidance: '完美！',
        poseMatched: true,
      );

      expect(
        isPoseCoachingAligned(
          stability: const SceneStabilityStatus(
            state: SceneStabilityState.monitoring,
            hammingDistance: 8,
          ),
          coaching: coaching,
        ),
        isTrue,
      );
    });
  });
}