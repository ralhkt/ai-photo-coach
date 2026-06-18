import 'dart:ui';

class FocusIndicatorState {
  const FocusIndicatorState({
    required this.position,
    required this.normalizedPoint,
    required this.isLocked,
    required this.visible,
  });

  final Offset position;
  final Offset normalizedPoint;
  final bool isLocked;
  final bool visible;

  FocusIndicatorState copyWith({
    Offset? position,
    Offset? normalizedPoint,
    bool? isLocked,
    bool? visible,
  }) {
    return FocusIndicatorState(
      position: position ?? this.position,
      normalizedPoint: normalizedPoint ?? this.normalizedPoint,
      isLocked: isLocked ?? this.isLocked,
      visible: visible ?? this.visible,
    );
  }
}