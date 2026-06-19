import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/camera_aspect_ratio.dart';
import '../../../models/camera_timer_duration.dart';
import 'camera_providers.dart';
import 'camera_settings_provider.dart';

enum CameraUiMode { free, guided }

class CameraModeSettings {
  const CameraModeSettings({
    this.hdrEnabled = false,
    this.timerDuration = CameraTimerDuration.off,
    this.proModeEnabled = false,
    this.aspectRatio = CameraAspectRatio.ratio4x3,
    this.manualExposureOffset = 0,
    this.focalPreset = 1.0,
    this.showHistogram = false,
    this.frontMirrorEnabled = true,
    this.showCameraOptions = true,
  });

  final bool hdrEnabled;
  final CameraTimerDuration timerDuration;
  final bool proModeEnabled;
  final CameraAspectRatio aspectRatio;
  final double manualExposureOffset;
  final double focalPreset;
  final bool showHistogram;
  final bool frontMirrorEnabled;
  final bool showCameraOptions;

  CameraModeSettings copyWith({
    bool? hdrEnabled,
    CameraTimerDuration? timerDuration,
    bool? proModeEnabled,
    CameraAspectRatio? aspectRatio,
    double? manualExposureOffset,
    double? focalPreset,
    bool? showHistogram,
    bool? frontMirrorEnabled,
    bool? showCameraOptions,
  }) {
    return CameraModeSettings(
      hdrEnabled: hdrEnabled ?? this.hdrEnabled,
      timerDuration: timerDuration ?? this.timerDuration,
      proModeEnabled: proModeEnabled ?? this.proModeEnabled,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      manualExposureOffset: manualExposureOffset ?? this.manualExposureOffset,
      focalPreset: focalPreset ?? this.focalPreset,
      showHistogram: showHistogram ?? this.showHistogram,
      frontMirrorEnabled: frontMirrorEnabled ?? this.frontMirrorEnabled,
      showCameraOptions: showCameraOptions ?? this.showCameraOptions,
    );
  }
}

class CameraModeSettingsNotifier extends Notifier<CameraUiMode> {
  final Map<CameraUiMode, CameraModeSettings> _settings = {
    CameraUiMode.free: const CameraModeSettings(),
    CameraUiMode.guided: const CameraModeSettings(
      proModeEnabled: false,
      showCameraOptions: true,
    ),
  };

  CameraUiMode get activeMode => state;

  CameraModeSettings settingsFor(CameraUiMode mode) =>
      _settings[mode] ?? const CameraModeSettings();

  void _saveFromProviders(CameraUiMode mode) {
    _settings[mode] = CameraModeSettings(
      hdrEnabled: ref.read(hdrEnabledProvider),
      timerDuration: ref.read(timerDurationProvider),
      proModeEnabled: ref.read(proModeEnabledProvider),
      aspectRatio: ref.read(cameraAspectRatioProvider),
      manualExposureOffset: ref.read(manualExposureOffsetProvider),
      focalPreset: ref.read(focalPresetProvider),
      showHistogram: ref.read(showHistogramProvider),
      frontMirrorEnabled: ref.read(frontMirrorEnabledProvider),
      showCameraOptions: ref.read(showCameraOptionsProvider),
    );
  }

  void _restoreToProviders(CameraModeSettings settings) {
    ref.read(hdrEnabledProvider.notifier).state = settings.hdrEnabled;
    ref.read(timerDurationProvider.notifier).state = settings.timerDuration;
    ref.read(proModeEnabledProvider.notifier).state = settings.proModeEnabled;
    ref.read(cameraAspectRatioProvider.notifier).state = settings.aspectRatio;
    ref.read(manualExposureOffsetProvider.notifier).state =
        settings.manualExposureOffset;
    ref.read(focalPresetProvider.notifier).state = settings.focalPreset;
    ref.read(showHistogramProvider.notifier).state = settings.showHistogram;
    ref.read(frontMirrorEnabledProvider.notifier).state =
        settings.frontMirrorEnabled;
    ref.read(showCameraOptionsProvider.notifier).state =
        settings.showCameraOptions;
  }

  Future<void> applyHardwareSettings(CameraModeSettings settings) async {
    final controller = ref.read(cameraControllerProvider).value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    await ref
        .read(cameraControllerProvider.notifier)
        .setZoom(settings.focalPreset);
    await ref
        .read(cameraControllerProvider.notifier)
        .setManualExposure(settings.manualExposureOffset);
  }

  Future<void> activateMode(
    CameraUiMode mode, {
    bool applyHardware = true,
  }) async {
    if (state == mode) {
      return;
    }

    _saveFromProviders(state);
    state = mode;
    final settings = settingsFor(mode);
    _restoreToProviders(settings);
    if (applyHardware) {
      await applyHardwareSettings(settings);
    }
  }

  void updateActiveSettings(CameraModeSettings settings) {
    _settings[state] = settings;
    _restoreToProviders(settings);
  }

  void seedGuidedFromAnalysis({
    required double suggestedZoom,
    required double exposureEv,
  }) {
    final current = settingsFor(CameraUiMode.guided);
    final seeded = current.copyWith(
      focalPreset: suggestedZoom,
      manualExposureOffset: exposureEv,
      proModeEnabled: false,
    );
    _settings[CameraUiMode.guided] = seeded;
    if (state == CameraUiMode.guided) {
      _restoreToProviders(seeded);
    }
  }

  void persistActiveFromProviders() {
    _saveFromProviders(state);
  }

  @override
  CameraUiMode build() => CameraUiMode.free;
}

final cameraModeSettingsProvider =
    NotifierProvider<CameraModeSettingsNotifier, CameraUiMode>(
  CameraModeSettingsNotifier.new,
);