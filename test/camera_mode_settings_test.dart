import 'package:ai_photo_coach/features/camera/providers/camera_mode_settings_provider.dart';
import 'package:ai_photo_coach/features/camera/providers/camera_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('free and guided modes keep isolated zoom and exposure settings', () async {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final notifier = container.read(cameraModeSettingsProvider.notifier);

    container.read(focalPresetProvider.notifier).state = 2.0;
    container.read(manualExposureOffsetProvider.notifier).state = 1.5;
    container.read(proModeEnabledProvider.notifier).state = true;

    await notifier.activateMode(CameraUiMode.guided, applyHardware: false);

    expect(container.read(focalPresetProvider), 1.0);
    expect(container.read(manualExposureOffsetProvider), 0);
    expect(container.read(proModeEnabledProvider), isFalse);

    notifier.seedGuidedFromAnalysis(suggestedZoom: 1.2, exposureEv: -0.3);
    expect(container.read(focalPresetProvider), 1.2);
    expect(container.read(manualExposureOffsetProvider), closeTo(-0.3, 0.001));

    await notifier.activateMode(CameraUiMode.free, applyHardware: false);

    expect(container.read(focalPresetProvider), 2.0);
    expect(container.read(manualExposureOffsetProvider), 1.5);
    expect(container.read(proModeEnabledProvider), isTrue);
  });
}