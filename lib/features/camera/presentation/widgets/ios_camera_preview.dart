import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/native_camera_preview_service.dart';
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
    required this.mirrorFront,
  });

  final CameraController controller;
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
    if (!_previewReady) {
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
    final mirrorFront = ref.watch(frontMirrorEnabledProvider);

    return IosCameraPreview(
      key: ValueKey(controller.description.name),
      controller: controller,
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

class _CameraPreviewTexture extends StatefulWidget {
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
  State<_CameraPreviewTexture> createState() => _CameraPreviewTextureState();
}

class _CameraPreviewTextureState extends State<_CameraPreviewTexture> {
  bool _nativePreview = false;
  bool _texturePreviewPaused = false;

  @override
  void initState() {
    super.initState();
    _resolvePreviewMode();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant _CameraPreviewTexture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      // Old controller may already be disposed during lens switch — never resume it.
      _texturePreviewPaused = false;
      _resolvePreviewMode();
    } else if (oldWidget.mirrorFront != widget.mirrorFront) {
      _syncNativePreviewSettings();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!widget.controller.value.isInitialized) {
      return;
    }
    if (_nativePreview && !_texturePreviewPaused) {
      unawaited(_pauseTexturePreview());
    }
  }

  Future<void> _resolvePreviewMode() async {
    final useNative =
        !kIsWeb && Platform.isIOS && await NativeCameraPreviewService.instance.isSupported();
    if (!mounted) {
      return;
    }
    setState(() => _nativePreview = useNative);
    if (useNative && widget.controller.value.isInitialized) {
      unawaited(_pauseTexturePreview());
      unawaited(_syncNativePreviewSettings());
    }
  }

  Future<void> _pauseTexturePreview() async {
    if (_texturePreviewPaused || !widget.controller.value.isInitialized) {
      return;
    }
    try {
      await widget.controller.pausePreview();
      _texturePreviewPaused = true;
    } catch (error) {
      debugPrint('IosCameraPreview: pausePreview failed: $error');
    }
  }

  Future<void> _resumeTexturePreview() async {
    if (!_texturePreviewPaused || !widget.controller.value.isInitialized) {
      return;
    }
    try {
      await widget.controller.resumePreview();
    } catch (error) {
      debugPrint('IosCameraPreview: resumePreview failed: $error');
    } finally {
      _texturePreviewPaused = false;
    }
  }

  Future<void> _syncNativePreviewSettings() async {
    await NativeCameraPreviewService.instance.updateSettings(
      mirrorFront: widget.mirrorFront,
      lensDirection: widget.controller.description.lensDirection.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_nativePreview) {
      return UiKitView(
        viewType: NativeCameraPreviewService.platformViewType,
        layoutDirection: TextDirection.ltr,
        creationParams: {
          'mirrorFront': widget.mirrorFront,
          'lensDirection': widget.controller.description.lensDirection.name,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    final isFront =
        widget.controller.description.lensDirection == CameraLensDirection.front;

    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: widget.previewSize.height,
          height: widget.previewSize.width,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scaleByDouble(
                isFront && widget.mirrorFront ? -1.0 : 1.0,
                1.0,
                1.0,
                1.0,
              ),
            child: CameraPreview(widget.controller),
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