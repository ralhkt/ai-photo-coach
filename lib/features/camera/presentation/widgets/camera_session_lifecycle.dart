import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/performance/battery_session_tracker.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../../../models/shoot_session.dart';
import '../../../ar/providers/ar_providers.dart';
import '../../../scene_stabilization/services/camera_frame_monitor.dart';
import '../../../session/providers/shoot_session_provider.dart';

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
  @override
  void initState() {
    super.initState();
    Future.microtask(_startServices);
  }

  @override
  void didUpdateWidget(covariant CameraSessionLifecycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      Future.microtask(_restartServices);
    }
  }

  @override
  void dispose() {
    Future.microtask(_stopServices);
    super.dispose();
  }

  Future<void> _startServices() async {
    final mode = widget.shootSessionMode;
    if (mode != null) {
      ref.read(shootSessionProvider.notifier).startSession(mode);
      await ref.read(batterySessionTrackerProvider).begin();
    }
    await ref.read(cameraFrameMonitorProvider).start(widget.controller);

    final powerSave = ref.read(powerSaveEnabledProvider);
    final shouldRunAr = widget.enableAr && !powerSave;
    if (shouldRunAr) {
      await ref.read(arSessionProvider.notifier).start();
    }
  }

  Future<void> _restartServices() async {
    await _stopServices();
    await _startServices();
  }

  Future<void> _stopServices() async {
    await ref.read(cameraFrameMonitorProvider).stop();
    if (widget.enableAr) {
      await ref.read(arSessionProvider.notifier).stop();
    }

    if (widget.shootSessionMode != null) {
      final report = await ref.read(batterySessionTrackerProvider).end();
      if (report != null && report.startPercent >= 0 && report.endPercent >= 0) {
        ref.read(lastBatteryReportProvider.notifier).state = report;
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}