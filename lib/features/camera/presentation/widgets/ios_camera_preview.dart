import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import 'camera_zoom_gesture_state.dart';
import 'ios_focus_indicator.dart';

/// Native camera texture — intentionally **not** a [ConsumerWidget] so Riverpod
/// rebuilds never invalidate the preview at 120 Hz.
class IosCameraPreview extends StatefulWidget {
  const IosCameraPreview({
    super.key,
    required this.controller,
    required this.isSwitching,
    required this.mirrorFront,
  });

  final CameraController controller;
  final bool isSwitching;
  final bool mirrorFront;

  @override
  State<IosCameraPreview> createState() => _IosCameraPreviewState();
}

class _IosCameraPreviewState extends State<IosCameraPreview> {
  final _zoomGesture = CameraZoomGestureState();
  int _pointerCount = 0;
  bool _previewReady = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _previewReady = _isPreviewReady(widget.controller);
  }

  @override
  void didUpdateWidget(covariant IosCameraPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _previewReady = _isPreviewReady(widget.controller);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  bool _isPreviewReady(CameraController controller) {
    return controller.value.isInitialized && controller.value.previewSize != null;
  }

  /// Only rebuild when preview readiness changes — NOT on every exposure tick.
  void _onControllerChanged() {
    final ready = _isPreviewReady(widget.controller);
    if (ready != _previewReady && mounted) {
      setState(() => _previewReady = ready);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSwitching || !_previewReady) {
      return const ColoredBox(color: Colors.black);
    }

    final controller = widget.controller;
    final previewSize = controller.value.previewSize!;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return Listener(
            onPointerDown: (_) => _pointerCount++,
            onPointerUp: (_) =>
                _pointerCount = (_pointerCount - 1).clamp(0, 10),
            onPointerCancel: (_) =>
                _pointerCount = (_pointerCount - 1).clamp(0, 10),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (_pointerCount > 0) {
                  return;
                }
                _CameraPreviewScope.of(context).setFocusAt(
                  details.localPosition,
                  size,
                );
              },
              onLongPressStart: (details) {
                _CameraPreviewScope.of(context).lockAeAfAt(
                  details.localPosition,
                  size,
                );
              },
              onScaleStart: (_) {
                if (_pointerCount >= 2) {
                  _zoomGesture.beginPinch();
                }
              },
              onScaleUpdate: (details) {
                if (_pointerCount >= 2) {
                  _zoomGesture.applyPinchScale(details.scale);
                  _CameraPreviewScope.of(context).setZoom(
                    _zoomGesture.currentZoom,
                  );
                }
              },
              child: _CameraPreviewTexture(
                key: ValueKey(controller.description.name),
                controller: controller,
                previewSize: previewSize,
                mirrorFront: widget.mirrorFront,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Provides camera actions without putting [Consumer] on the preview hot path.
class CameraPreviewScope extends ConsumerWidget {
  const CameraPreviewScope({
    super.key,
    required this.controller,
  });

  final CameraController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CameraPreviewScope(
      setFocusAt: (position, size) {
        ref.read(cameraControllerProvider.notifier).setFocusAt(position, size);
      },
      lockAeAfAt: (position, size) {
        ref.read(cameraControllerProvider.notifier).lockAeAfAt(position, size);
      },
      setZoom: (zoom) {
        ref.read(cameraControllerProvider.notifier).setZoom(zoom);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CameraPreviewVisualLayer(controller: controller),
          const _FocusIndicatorLayer(),
        ],
      ),
    );
  }
}

/// Isolates mirror / lens-switch state from the gesture + scope subtree.
class _CameraPreviewVisualLayer extends ConsumerWidget {
  const _CameraPreviewVisualLayer({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSwitching = ref.watch(cameraSwitchingProvider);
    final mirrorFront = ref.watch(frontMirrorEnabledProvider);

    return IosCameraPreview(
      key: ValueKey(controller.description.name),
      controller: controller,
      isSwitching: isSwitching,
      mirrorFront: mirrorFront,
    );
  }
}

class _CameraPreviewScope extends InheritedWidget {
  const _CameraPreviewScope({
    required this.setFocusAt,
    required this.lockAeAfAt,
    required this.setZoom,
    required super.child,
  });

  final void Function(Offset position, Size previewSize) setFocusAt;
  final void Function(Offset position, Size previewSize) lockAeAfAt;
  final void Function(double zoom) setZoom;

  static _CameraPreviewScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_CameraPreviewScope>();
    assert(scope != null, 'CameraPreviewScope missing');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant _CameraPreviewScope oldWidget) => false;
}

class _CameraPreviewTexture extends StatelessWidget {
  const _CameraPreviewTexture({
    super.key,
    required this.controller,
    required this.previewSize,
    required this.mirrorFront,
  });

  final CameraController controller;
  final Size previewSize;
  final bool mirrorFront;

  @override
  Widget build(BuildContext context) {
    final isFront =
        controller.description.lensDirection == CameraLensDirection.front;

    return ClipRect(
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
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class _FocusIndicatorLayer extends ConsumerWidget {
  const _FocusIndicatorLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusIndicatorProvider);
    if (focusState == null || !focusState.visible) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(child: IosFocusIndicator(state: focusState));
  }
}