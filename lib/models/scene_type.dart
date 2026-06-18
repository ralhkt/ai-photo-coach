enum SceneType {
  auto,
  portrait,
  landscape,
  lifestyle,
  square,
  group,
  product,
}

extension SceneTypeX on SceneType {
  String get l10nKey => switch (this) {
        SceneType.auto => 'sceneTypeAuto',
        SceneType.portrait => 'sceneTypePortrait',
        SceneType.landscape => 'sceneTypeLandscape',
        SceneType.lifestyle => 'sceneTypeLifestyle',
        SceneType.square => 'sceneTypeSquare',
        SceneType.group => 'sceneTypeGroup',
        SceneType.product => 'sceneTypeProduct',
      };

  String get analysisSceneKey => switch (this) {
        SceneType.auto => 'sceneLifestyle',
        SceneType.portrait => 'scenePortrait',
        SceneType.landscape => 'sceneLandscape',
        SceneType.lifestyle => 'sceneLifestyle',
        SceneType.square => 'sceneSquare',
        SceneType.group => 'scenePortrait',
        SceneType.product => 'sceneLifestyle',
      };

  bool get prefersHumanSilhouette =>
      this == SceneType.portrait || this == SceneType.group;
}