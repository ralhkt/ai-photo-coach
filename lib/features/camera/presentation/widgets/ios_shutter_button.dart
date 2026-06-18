import 'package:flutter/material.dart';

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
    final scale = _pressed ? 0.9 : 1.0;
    final bursting = widget.isBursting;

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
        duration: const Duration(milliseconds: 80),
        child: SizedBox(
          width: 78,
          height: 78,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(widget.enabled ? 1 : 0.35),
                    width: 4,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: bursting || widget.isCapturing ? 34 : 64,
                height: bursting || widget.isCapturing ? 34 : 64,
                decoration: BoxDecoration(
                  color: bursting
                      ? const Color(0xFFFFD60A)
                      : Colors.white.withOpacity(widget.enabled ? 1 : 0.35),
                  borderRadius: BorderRadius.circular(
                    bursting || widget.isCapturing ? 8 : 32,
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