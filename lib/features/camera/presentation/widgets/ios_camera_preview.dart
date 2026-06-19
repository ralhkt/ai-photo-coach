import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import 'camera_zoom_gesture_state.dart';
import 'ios_focus_indicator.dart';

class IosCameraPreview extends ConsumerStatefulWidget {
  const IosCameraPreview({super.key, required this.controller});

  final CameraController controller;

  @override
  ConsumerState<IosCameraPreview> createState() => _IosCameraPreviewState();
}

class _IosCameraPreviewState extends ConsumerState<IosCameraPreview> {
  final _zoomGesture = CameraZoomGestureState();
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _syncZoomFromProvider();
  }

  @override
  void didUpdateWidget(covariant IosCameraPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _syncZoomFromProvider();
    }
  }

  void _syncZoomFromProvider() {
    _zoomGesture.syncFromProvider(ref.read(focalPresetProvider));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<double>(focalPresetProvider, (previous, next) {
      if (previous == next) {
        return;
      }
      if ((_zoomGesture.currentZoom - next).abs() > 0.01) {
        setState(() => _zoomGesture.syncFromProvider(next));
      }
    });

    final previewSize = widget.controller.value.previewSize;
    final focusState = ref.watch(focusIndicatorProvider);
    final mirrorFront = ref.watch(frontMirrorEnabledProvider);
    final isFront = widget.controller.description.lensDirection ==
        CameraLensDirection.front;

    if (previewSize == null) {
      return const ColoredBox(color: Colors.black);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Listener(
          onPointerDown: (_) => setState(() => _pointerCount++),
          onPointerUp: (_) =>
              setState(() => _pointerCount = (_pointerCount - 1).clamp(0, 10)),
          onPointerCancel: (_) =>
              setState(() => _pointerCount = (_pointerCount - 1).clamp(0, 10)),
          child: GestureDetector(
            onTapUp: (details) {
              if (_pointerCount > 0) {
                return;
              }
              ref.read(cameraControllerProvider.notifier).setFocusAt(
                    details.localPosition,
                    size,
                  );
            },
            onLongPressStart: (details) {
              ref.read(cameraControllerProvider.notifier).lockAeAfAt(
                    details.localPosition,
                    size,
                  );
            },
            onScaleStart: (_) {
              if (_pointerCount >= 2) {
                setState(() => _zoomGesture.beginPinch());
              }
            },
            onScaleUpdate: (details) {
              if (_pointerCount >= 2) {
                setState(() => _zoomGesture.applyPinchScale(details.scale));
                ref
                    .read(cameraControllerProvider.notifier)
                    .setZoom(_zoomGesture.currentZoom);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: previewSize.height,
                      height: previewSize.width,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..scaleByDouble(
                            isFront && mirrorFront ? -1.0 : 1.0,
                            1.0,
                            1.0,
                            1.0,
                          ),
                        child: CameraPreview(widget.controller),
                      ),
                    ),
                  ),
                ),
                if (focusState != null)
                  IosFocusIndicator(state: focusState),
              ],
            ),
          ),
        );
      },
    );
  }
}