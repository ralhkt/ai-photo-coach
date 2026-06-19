import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/performance/battery_session_tracker.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../../../models/shoot_session.dart';
import '../../../ar/providers/ar_providers.dart';
import '../../../scene_stabilization/services/camera_frame_monitor.dart';
import '../../../session/providers/shoot_session_provider.dart';
import 'ios_scene_stability_poller.dart';
import 'pose_coaching_lifecycle.dart';

/// Starts/stops Phase 2 AR session + pHash scene monitor with camera lifecycle.
class CameraSessionLifecycle extends ConsumerStatefulWidget {
  const CameraSessionLifecycle({
    super.key,
    required this.controller,
    required this.enableAr,
    required this.child,
    this.shootSessionMode,
  });

  final CameraController controller;
  final bool enableAr;
  final Widget child;
  final ShootSessionMode? shootSessionMode;

  @override
  ConsumerState<CameraSessionLifecycle> createState() =>
      _CameraSessionLifecycleState();
}

class _CameraSessionLifecycleState extends ConsumerState<CameraSessionLifecycle> {
  bool _sessionStarted = false;
  bool _servicesStopped = false;
  late final CameraFrameMonitor _frameMonitor;
  late final ArSessionNotifier _arNotifier;
  late final BatterySessionTracker _batteryTracker;

  @override
  void initState() {
    super.initState();
    _frameMonitor = ref.read(cameraFrameMonitorProvider);
    _arNotifier = ref.read(arSessionProvider.notifier);
    _batteryTracker = ref.read(batterySessionTrackerProvider);
    Future.microtask(_startServices);
  }

  @override
  void didUpdateWidget(covariant CameraSessionLifecycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      Future.microtask(_restartHardwareServices);
    }
  }

  @override
  void dispose() {
    _stopServices();
    super.dispose();
  }

  Future<void> _startServices() async {
    if (!mounted) {
      return;
    }

    final mode = widget.shootSessionMode;
    if (mode != null && !_sessionStarted) {
      ref.read(shootSessionProvider.notifier).startSession(mode);
      _sessionStarted = true;
      await _batteryTracker.begin();
    }
    await _frameMonitor.start(widget.controller);

    final powerSave = ref.read(powerSaveEnabledProvider);
    final shouldRunAr = widget.enableAr && !powerSave;
    if (shouldRunAr) {
      await _arNotifier.start();
    }
  }

  Future<void> _restartHardwareServices() async {
    if (!mounted) {
      return;
    }

    await _frameMonitor.stop();
    if (widget.enableAr) {
      await _arNotifier.stop();
    }

    if (!widget.controller.value.isInitialized) {
      return;
    }

    await _frameMonitor.start(widget.controller);

    final powerSave = ref.read(powerSaveEnabledProvider);
    if (widget.enableAr && !powerSave) {
      await _arNotifier.start();
    }
  }

  void _stopServices() {
    if (_servicesStopped) {
      return;
    }
    _servicesStopped = true;

    _frameMonitor.stop();
    if (widget.enableAr) {
      _arNotifier.stop();
    }

    if (widget.shootSessionMode != null && _sessionStarted) {
      _batteryTracker.end().then((report) {
        if (report != null &&
            report.startPercent >= 0 &&
            report.endPercent >= 0 &&
            mounted) {
          ref.read(lastBatteryReportProvider.notifier).state = report;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        const PoseCoachingLifecycle(),
        const IosSceneStabilityPoller(),
      ],
    );
  }
}