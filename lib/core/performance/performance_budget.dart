abstract final class PerformanceBudget {
  static const int mlInferenceMs = 150;
  static const int sessionPhotoAnalysisMs = 120;
  static const int sessionTotalAnalysisMs = 2000;
  static const int phashFrameIntervalMs = 1500;
  static const int phashFrameIntervalPowerSaveMs = 1600;
  static const double batteryDrainPercentPer10Min = 7.0;
}