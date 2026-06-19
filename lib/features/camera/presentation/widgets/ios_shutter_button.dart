import 'package:flutter/material.dart';

import 'ios_camera_ui_kit.dart';

class IosShutterButton extends StatefulWidget {
  const IosShutterButton({
    super.key,
    required this.onPressed,
    this.onBurstStart,
    this.onBurstEnd,
    this.isCapturing = false,
    this.isBursting = false,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onBurstStart;
  final VoidCallback? onBurstEnd;
  final bool isCapturing;
  final bool isBursting;
  final bool enabled;

  @override
  State<IosShutterButton> createState() => _IosShutterButtonState();
}

class _IosShutterButtonState extends State<IosShutterButton> {
  bool _pressed = false;
  bool _burstTriggered = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? IosCameraUiKit.pressScale : 1.0;
    final bursting = widget.isBursting;
    final ringOpacity = widget.enabled ? 1.0 : 0.35;
    final innerSize = bursting || widget.isCapturing
        ? IosCameraUiKit.shutterBurstInner
        : IosCameraUiKit.shutterInnerDiameter;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              final wasBurst = _burstTriggered;
              setState(() {
                _pressed = false;
                _burstTriggered = false;
              });
              if (!wasBurst && !bursting) {
                widget.onPressed?.call();
              }
            }
          : null,
      onTapCancel: () => setState(() {
        _pressed = false;
        _burstTriggered = false;
      }),
      onLongPressStart: widget.enabled
          ? (_) {
              setState(() => _burstTriggered = true);
              widget.onBurstStart?.call();
            }
          : null,
      onLongPressEnd: widget.enabled
          ? (_) {
              if (_burstTriggered) {
                widget.onBurstEnd?.call();
              }
              setState(() {
                _pressed = false;
                _burstTriggered = false;
              });
            }
          : null,
      child: AnimatedScale(
        scale: scale,
        duration: IosCameraUiKit.pressAnimation,
        child: SizedBox(
          width: IosCameraUiKit.shutterOuterDiameter,
          height: IosCameraUiKit.shutterOuterDiameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: IosCameraUiKit.shutterOuterDiameter,
                height: IosCameraUiKit.shutterOuterDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: ringOpacity),
                    width: IosCameraUiKit.shutterRingWidth,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: IosCameraUiKit.morphAnimation,
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  color: bursting
                      ? IosCameraUiKit.accentYellow
                      : Colors.white.withValues(alpha: ringOpacity),
                  borderRadius: BorderRadius.circular(
                    bursting || widget.isCapturing
                        ? IosCameraUiKit.shutterBurstRadius
                        : innerSize / 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}