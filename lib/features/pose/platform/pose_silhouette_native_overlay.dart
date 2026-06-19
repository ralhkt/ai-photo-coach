import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pose_silhouette_provider.dart';
import 'pose_silhouette_platform_service.dart';

/// Metal-backed dynamic silhouette overlay on iOS 15+.
class PoseSilhouetteNativeOverlay extends ConsumerStatefulWidget {
  const PoseSilhouetteNativeOverlay({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  ConsumerState<PoseSilhouetteNativeOverlay> createState() =>
      _PoseSilhouetteNativeOverlayState();
}

class _PoseSilhouetteNativeOverlayState
    extends ConsumerState<PoseSilhouetteNativeOverlay> {
  bool _supported = false;

  @override
  void initState() {
    super.initState();
    _loadSupport();
  }

  Future<void> _loadSupport() async {
    final supported = await ref.read(poseSilhouetteServiceProvider).isSupported();
    if (!mounted) {
      return;
    }
    setState(() => _supported = supported);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || !_supported || !Platform.isIOS) {
      return const SizedBox.shrink();
    }

    return const IgnorePointer(
      child: SizedBox.expand(
        child: UiKitView(
          viewType: PoseSilhouettePlatformService.platformViewType,
          layoutDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}