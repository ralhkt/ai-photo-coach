import 'package:ai_photo_coach/features/camera/providers/live_scene_analysis_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manual analyze ignores UI interaction pause', () {
    expect(
      isLiveSceneCameraBusy(
        bursting: false,
        timerActive: false,
        capturing: false,
        switching: false,
        uiInteractionPaused: true,
        manual: true,
      ),
      isFalse,
    );
  });

  test('auto analyze respects UI interaction pause', () {
    expect(
      isLiveSceneCameraBusy(
        bursting: false,
        timerActive: false,
        capturing: false,
        switching: false,
        uiInteractionPaused: true,
        manual: false,
      ),
      isTrue,
    );
  });
}