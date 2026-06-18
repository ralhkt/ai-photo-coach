import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SceneStabilityState {
  idle,
  monitoring,
  stable,
  changed,
}

class SceneStabilityStatus {
  const SceneStabilityStatus({
    required this.state,
    required this.hammingDistance,
    this.skippedAnalysisCount = 0,
  });

  final SceneStabilityState state;
  final int hammingDistance;
  final int skippedAnalysisCount;

  SceneStabilityStatus copyWith({
    SceneStabilityState? state,
    int? hammingDistance,
    int? skippedAnalysisCount,
  }) {
    return SceneStabilityStatus(
      state: state ?? this.state,
      hammingDistance: hammingDistance ?? this.hammingDistance,
      skippedAnalysisCount: skippedAnalysisCount ?? this.skippedAnalysisCount,
    );
  }
}

final sceneStabilityProvider =
    NotifierProvider<SceneStabilityNotifier, SceneStabilityStatus>(
  SceneStabilityNotifier.new,
);

class SceneStabilityNotifier extends Notifier<SceneStabilityStatus> {
  @override
  SceneStabilityStatus build() {
    return const SceneStabilityStatus(
      state: SceneStabilityState.idle,
      hammingDistance: 0,
    );
  }

  void setMonitoring() {
    state = state.copyWith(state: SceneStabilityState.monitoring);
  }

  void reportStable({required int hammingDistance}) {
    state = SceneStabilityStatus(
      state: SceneStabilityState.stable,
      hammingDistance: hammingDistance,
      skippedAnalysisCount: state.skippedAnalysisCount + 1,
    );
  }

  void reportChanged({required int hammingDistance}) {
    state = SceneStabilityStatus(
      state: SceneStabilityState.changed,
      hammingDistance: hammingDistance,
      skippedAnalysisCount: state.skippedAnalysisCount,
    );
  }

  void reset() {
    state = const SceneStabilityStatus(
      state: SceneStabilityState.idle,
      hammingDistance: 0,
    );
  }
}

/// When true, live analysis / guidance refresh should be skipped (scene unchanged).
final shouldSkipLiveAnalysisProvider = Provider<bool>((ref) {
  final status = ref.watch(sceneStabilityProvider);
  return status.state == SceneStabilityState.stable;
});