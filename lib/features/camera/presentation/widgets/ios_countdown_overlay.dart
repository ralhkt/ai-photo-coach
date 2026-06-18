import 'package:flutter/material.dart';

class IosCountdownOverlay extends StatelessWidget {
  const IosCountdownOverlay({super.key, required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(seconds),
        tween: Tween(begin: 1.4, end: 1.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$seconds',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}