import '../../models/app_settings.dart';

class PromptStrengthFilter {
  const PromptStrengthFilter(this.strength);

  final PromptStrength strength;

  bool get showBodyPartSteps => strength != PromptStrength.low;

  bool get showSecondaryHints => strength != PromptStrength.low;

  bool get showExposureHints => strength == PromptStrength.high;

  int get bodyPartStepCount => switch (strength) {
        PromptStrength.low => 1,
        PromptStrength.medium => 2,
        PromptStrength.high => 4,
      };
}