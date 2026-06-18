import 'dart:typed_data';

import 'package:ai_photo_coach/core/performance/battery_session_tracker.dart';
import 'package:ai_photo_coach/core/performance/performance_tracker.dart';
import 'package:ai_photo_coach/core/settings/settings_repository.dart';
import 'package:ai_photo_coach/core/utils/image_downscaler.dart';
import 'package:ai_photo_coach/features/ml/services/nima_like_scorer.dart';
import 'package:ai_photo_coach/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageDownscaler', () {
    test('shrinks large generated image bytes', () {
      final image = img.Image(width: 1200, height: 1600);
      img.fill(image, color: img.ColorRgb8(120, 80, 40));
      final original = Uint8List.fromList(img.encodeJpg(image));

      final downscaled = ImageDownscaler.downscale(original, maxSide: 480);
      final decoded = img.decodeImage(downscaled);

      expect(decoded, isNotNull);
      expect(
        decoded!.width > decoded.height ? decoded.width : decoded.height,
        lessThanOrEqualTo(480),
      );
      expect(downscaled.length, lessThan(original.length));
    });
  });

  group('NimaLikeScorer', () {
    test('rewards balanced exposure and contrast', () {
      final scorer = NimaLikeScorer();
      final good = scorer.score(brightness: 0.52, contrast: 0.55);
      final dark = scorer.score(brightness: 0.15, contrast: 0.2);
      expect(good, greaterThan(dark));
    });
  });

  group('PerformanceTracker', () {
    test('records averages and over-budget counts', () {
      final tracker = PerformanceTracker();
      tracker.record('session_photo_quick', 80, budgetMs: 120);
      tracker.record('session_photo_quick', 140, budgetMs: 120);

      expect(tracker.averageMs('session_photo_quick'), 110);
      expect(tracker.countOverBudget('session_photo_quick'), 1);
    });
  });

  group('BatterySessionReport', () {
    test('computes per-10-minute drain', () {
      final report = BatterySessionReport(
        startPercent: 80,
        endPercent: 77,
        duration: const Duration(minutes: 10),
        recordedAt: DateTime(2026),
      );

      expect(report.deltaPercent, 3);
      expect(report.drainPer10Minutes, closeTo(3.0, 0.01));
      expect(report.withinMvpBudget, isTrue);
    });
  });

  group('SettingsRepository power save', () {
    test('persists power save flag', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = SettingsRepository();
      await repository.save(
        const AppSettings(powerSaveEnabled: true),
      );
      final loaded = await repository.load();
      expect(loaded.powerSaveEnabled, isTrue);
    });
  });
}