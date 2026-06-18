import 'package:flutter/material.dart';

import '../../../../models/focus_indicator_state.dart';

class IosFocusIndicator extends StatelessWidget {
  const IosFocusIndicator({
    super.key,
    required this.state,
  });

  final FocusIndicatorState state;

  @override
  Widget build(BuildContext context) {
    if (!state.visible) {
      return const SizedBox.shrink();
    }

    const size = 76.0;

    return Positioned(
      left: state.position.dx - size / 2,
      top: state.position.dy - size / 2,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.25, end: 1.0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
              color: state.isLocked
                  ? const Color(0xFFFFD60A)
                  : Colors.white,
              width: 1.5,
            ),
            color: state.isLocked
                ? const Color(0x33FFD60A)
                : Colors.transparent,
          ),
          child: state.isLocked
              ? const Center(
                  child: Text(
                    'AE/AF',
                    style: TextStyle(
                      color: Color(0xFFFFD60A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}