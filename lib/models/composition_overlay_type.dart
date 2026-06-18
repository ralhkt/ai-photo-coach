enum CompositionOverlayType {
  ruleOfThirds,
  goldenRatio,
  center,
  diagonal,
}

extension CompositionOverlayTypeX on CompositionOverlayType {
  CompositionOverlayType get next {
    final values = CompositionOverlayType.values;
    return values[(index + 1) % values.length];
  }
}