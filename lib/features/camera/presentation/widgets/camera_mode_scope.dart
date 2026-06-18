import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/camera_mode_settings_provider.dart';

/// Activates isolated camera UI settings for free vs guided shooting.
class CameraModeScope extends ConsumerStatefulWidget {
  const CameraModeScope({
    super.key,
    required this.mode,
    required this.child,
    this.onActivated,
  });

  final CameraUiMode mode;
  final Widget child;
  final Future<void> Function()? onActivated;

  @override
  ConsumerState<CameraModeScope> createState() => _CameraModeScopeState();
}

class _CameraModeScopeState extends ConsumerState<CameraModeScope> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_activateMode);
  }

  Future<void> _activateMode() async {
    await ref.read(cameraModeSettingsProvider.notifier).activateMode(widget.mode);
    if (!mounted) {
      return;
    }
    await widget.onActivated?.call();
  }

  @override
  void deactivate() {
    // 【修復】在 widget 仍掛載時持久化設定，避免 dispose 後再用 ref
    ref.read(cameraModeSettingsProvider.notifier).persistActiveFromProviders();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}