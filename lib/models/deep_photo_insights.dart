class DeepPhotoInsights {
  const DeepPhotoInsights({
    required this.contrastScore,
    required this.colorTemperatureKey,
    required this.lightingDirectionKey,
    required this.compositionBalanceKey,
    required this.moodKey,
    required this.depthHintKey,
    required this.confidence,
    required this.detailedTips,
    required this.analysisSource,
  });

  final double contrastScore;
  final String colorTemperatureKey;
  final String lightingDirectionKey;
  final String compositionBalanceKey;
  final String moodKey;
  final String depthHintKey;
  final double confidence;
  final List<String> detailedTips;
  final String analysisSource;
}