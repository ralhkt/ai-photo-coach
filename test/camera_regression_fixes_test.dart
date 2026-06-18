import 'dart:typed_data';

import 'package:ai_photo_coach/features/camera/presentation/widgets/camera_error_view.dart';
import 'package:ai_photo_coach/features/session/providers/shoot_session_provider.dart';
import 'package:ai_photo_coach/models/captured_photo.dart';
import 'package:ai_photo_coach/models/shoot_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('camera regression fixes', () {
    testWidgets('CameraErrorView shows retry button and invokes callback', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CameraErrorView(
            message: '相機錯誤',
            detail: '模擬錯誤詳情',
            retryLabel: '重試',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('相機錯誤'), findsOneWidget);
      expect(find.text('模擬錯誤詳情'), findsOneWidget);
      expect(find.text('重試'), findsOneWidget);

      await tester.tap(find.text('重試'));
      await tester.pump();

      expect(retried, isTrue);
    });

    test('repeated startSession clears captures — lifecycle must guard with flag', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(shootSessionProvider.notifier);
      notifier.startSession(ShootSessionMode.guided);

      notifier.recordCapture(
        CapturedPhoto(
          path: 'a.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
          capturedAt: DateTime(2026, 1, 1),
        ),
      );
      expect(container.read(shootSessionProvider)!.captures, hasLength(1));

      // 模擬修復前的 didUpdateWidget 行為：無條件再次 startSession
      notifier.startSession(ShootSessionMode.guided);
      expect(
        container.read(shootSessionProvider)!.captures,
        isEmpty,
        reason: 'CameraSessionLifecycle 必須用 _sessionStarted 避免切鏡時重設',
      );
    });

    test('startSession only once preserves captures across simulated camera flip', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(shootSessionProvider.notifier);
      var sessionStarted = false;

      void startServicesOnce() {
        if (!sessionStarted) {
          notifier.startSession(ShootSessionMode.guided);
          sessionStarted = true;
        }
      }

      startServicesOnce();
      notifier.recordCapture(
        CapturedPhoto(
          path: 'b.jpg',
          bytes: Uint8List.fromList([4, 5, 6]),
          capturedAt: DateTime(2026, 1, 2),
        ),
      );

      // 模擬切換前後鏡頭：只重啟硬體服務，不重新 startSession
      startServicesOnce();

      expect(container.read(shootSessionProvider)!.captures, hasLength(1));
    });
  });
}