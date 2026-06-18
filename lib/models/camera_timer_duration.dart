enum CameraTimerDuration {
  off,
  three,
  ten,
}

extension CameraTimerDurationX on CameraTimerDuration {
  int get seconds {
    return switch (this) {
      CameraTimerDuration.off => 0,
      CameraTimerDuration.three => 3,
      CameraTimerDuration.ten => 10,
    };
  }

  CameraTimerDuration get next {
    final values = CameraTimerDuration.values;
    return values[(index + 1) % values.length];
  }
}