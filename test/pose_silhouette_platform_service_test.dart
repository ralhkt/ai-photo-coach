import 'dart:ui';

import 'package:ai_photo_coach/features/pose/platform/pose_silhouette_platform_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses alignment event payload', () {
    final event = PoseSilhouetteAlignmentEvent.fromJson({
      'score': 72,
      'phase': 'aligning',
      'toast': '肢體對齊中…請將身體套入輪廓',
      'enabled': true,
      'phaseChanged': true,
      'autoCaptureRequested': false,
    });

    expect(event.score, 72);
    expect(event.phase, PoseSilhouettePhase.aligning);
    expect(event.enabled, isTrue);
    expect(event.phaseChanged, isTrue);
  });

  test('parses matched auto capture request', () {
    final event = PoseSilhouetteAlignmentEvent.fromJson({
      'score': 90,
      'phase': 'matched',
      'toast': '完美對齊！可以拍了',
      'enabled': true,
      'phaseChanged': true,
      'autoCaptureRequested': true,
    });

    expect(event.autoCaptureRequested, isTrue);
    expect(event.phase, PoseSilhouettePhase.matched);
  });

  test('setGuideContour forwards normalized points', () async {
    final calls = <MethodCall>[];
    final service = PoseSilhouettePlatformService(
      methodChannel: MethodChannel('test/pose_silhouette'),
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('test/pose_silhouette'),
      (call) async {
        calls.add(call);
        return null;
      },
    );

    await service.setGuideContour([
      const Offset(0.3, 0.1),
      const Offset(0.7, 0.9),
      const Offset(0.4, 0.8),
      const Offset(0.5, 0.2),
    ]);

    expect(calls, hasLength(1));
    expect(calls.single.method, 'setGuideContour');
    final points = calls.single.arguments['points'] as List<dynamic>;
    expect(points, hasLength(4));
  });
}