import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

import '../../../models/body_part_guides.dart';
import '../../../models/camera_guidance.dart';
import '../../../models/composition_overlay_type.dart';
import '../../../models/deep_photo_insights.dart';
import '../../../models/ml_detection_result.dart';
import '../../../models/photo_analysis_result.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/scene_type.dart';
import '../../../models/subject_shape_kind.dart';
import '../../../core/utils/image_bytes_normalizer.dart';
import '../../ml/services/heuristic_vision_analyzer.dart';
import '../../ml/services/vision_analyzer.dart';
import 'body_part_guide_service.dart';
import 'deep_analysis_service.dart';
import 'photo_analysis_agent.dart';
import 'subject_silhouette_service.dart';

class ImageAnalyzerService {
  ImageAnalyzerService({
    SubjectSilhouetteService? silhouetteService,
    BodyPartGuideService? bodyPartGuideService,
    DeepAnalysisService? deepAnalysisService,
    PhotoAnalysisAgent? agent,
    VisionAnalyzer? visionAnalyzer,
  })  : _silhouetteService = silhouetteService ?? SubjectSilhouetteService(),
        _bodyPartGuideService = bodyPartGuideService ?? BodyPartGuideService(),
        _deepAnalysisService = deepAnalysisService ?? DeepAnalysisService(),
        _agent = agent ?? HeuristicPhotoAnalysisAgent(),
        _visionAnalyzer = visionAnalyzer ?? HeuristicVisionAnalyzer();

  final SubjectSilhouetteService _silhouetteService;
  final BodyPartGuideService _bodyPartGuideService;
  final DeepAnalysisService _deepAnalysisService;
  final PhotoAnalysisAgent _agent;
  final VisionAnalyzer _visionAnalyzer;

  Future<PhotoAnalysisResult> analyze(
    Uint8List bytes, {
    SceneType userSceneType = SceneType.auto,
    bool forLiveCoaching = false,
  }) async {
    final normalizedBytes = ImageBytesNormalizer.forAnalysis(bytes);
    final decoded = img.decodeImage(normalizedBytes);
    if (decoded == null) {
      throw const FormatException('Unable to decode image');
    }

    final width = decoded.width;
    final height = decoded.height;
    final aspectRatio = width / height;
    final brightness = _averageBrightness(decoded);

    MlDetectionResult mlDetection;
    try {
      mlDetection = await _visionAnalyzer.analyze(
        bytes: normalizedBytes,
        width: width,
        height: height,
      );
    } catch (_) {
      mlDetection = await HeuristicVisionAnalyzer().analyze(
        bytes: normalizedBytes,
        width: width,
        height: height,
      );
    }

    final heuristicSubject = _detectSubjectRegion(decoded, userSceneType);
    final subjectRect = _mergeSubjectRect(
      heuristic: heuristicSubject,
      ml: mlDetection.primarySubjectRect,
    );
    final subjectFillRatio = subjectRect.width * subjectRect.height;
    final recommendedFrame = _matchFrameTemplate(aspectRatio, subjectRect, userSceneType);
    final overlayType = _pickOverlayType(subjectRect, userSceneType);
    var sceneTypeKey = _resolveSceneTypeKey(
      userSceneType: userSceneType,
      subjectRect: subjectRect,
      aspectRatio: aspectRatio,
    );
    sceneTypeKey = _preferMlSceneKey(sceneTypeKey, mlDetection, userSceneType);

    final prefersHuman = _shouldUseHumanSilhouette(
      userSceneType: userSceneType,
      sceneTypeKey: sceneTypeKey,
      subjectRect: subjectRect,
      aspectRatio: aspectRatio,
      mlDetection: mlDetection,
      forLiveCoaching: forLiveCoaching,
    );

    List<Offset>? silhouettePoints;
    var subjectShape = SubjectShapeKind.rectangle;
    if (prefersHuman) {
      silhouettePoints =
          _silhouetteService.extractPortraitSilhouette(decoded, subjectRect);
      subjectShape = SubjectShapeKind.humanSilhouette;
    }

    BodyPartGuides? bodyPartGuides;
    if (mlDetection.bodyPartGuides != null) {
      bodyPartGuides = mlDetection.bodyPartGuides;
    } else if (subjectShape == SubjectShapeKind.humanSilhouette) {
      bodyPartGuides = _bodyPartGuideService.derive(
        subjectRect: subjectRect,
        silhouettePoints: silhouettePoints,
      );
    }

    final guidance = _buildGuidance(
      frameTemplate: recommendedFrame,
      overlayType: overlayType,
      subjectRect: subjectRect,
      brightness: brightness,
      subjectFillRatio: subjectFillRatio,
      userSceneType: userSceneType,
      subjectShape: subjectShape,
      silhouettePoints: silhouettePoints,
      bodyPartGuides: bodyPartGuides,
    );

    var deepInsights = _deepAnalysisService.analyze(
      image: decoded,
      subjectRect: subjectRect,
      brightness: brightness,
      sceneType: userSceneType == SceneType.auto
          ? _sceneTypeFromKey(sceneTypeKey)
          : userSceneType,
    );
    deepInsights = _enrichDeepInsights(deepInsights, mlDetection);

    var result = PhotoAnalysisResult(
      sourceAspectRatio: aspectRatio,
      brightness: brightness,
      subjectFillRatio: subjectFillRatio,
      recommendedFrame: recommendedFrame,
      guidance: guidance,
      sceneTypeKey: sceneTypeKey,
      imageBytes: normalizedBytes,
      userSceneType: userSceneType,
      deepInsights: deepInsights,
      mlDetection: mlDetection,
    );

    result = await _agent.enrich(result);
    return result;
  }

  Rect _mergeSubjectRect({required Rect heuristic, Rect? ml}) {
    if (ml == null) {
      return heuristic;
    }

    final mlArea = ml.width * ml.height;
    final heuristicArea = heuristic.width * heuristic.height;
    if (mlArea < 0.04 || mlArea > 0.92) {
      return heuristic;
    }

    if (heuristicArea < 0.05) {
      return ml;
    }

    return Rect.fromLTRB(
      math.min(heuristic.left, ml.left),
      math.min(heuristic.top, ml.top),
      math.max(heuristic.right, ml.right),
      math.max(heuristic.bottom, ml.bottom),
    );
  }

  String _preferMlSceneKey(
    String heuristicKey,
    MlDetectionResult ml,
    SceneType userSceneType,
  ) {
    if (userSceneType != SceneType.auto) {
      return userSceneType.analysisSceneKey;
    }

    final labels = ml.sceneLabels.map((label) => label.text.toLowerCase()).toList();
    final portraitHints = ['portrait', 'selfie', 'face', 'person', 'smile'];
    final landscapeHints = ['sky', 'mountain', 'beach', 'landscape', 'city'];
    final productHints = ['product', 'food', 'furniture', 'clothing'];

    if (ml.hasFaces || ml.hasPose) {
      return 'scenePortrait';
    }
    if (labels.any((label) => portraitHints.any(label.contains))) {
      return 'scenePortrait';
    }
    if (labels.any((label) => landscapeHints.any(label.contains))) {
      return 'sceneLandscape';
    }
    if (labels.any((label) => productHints.any(label.contains))) {
      return 'sceneLifestyle';
    }
    return heuristicKey;
  }

  DeepPhotoInsights _enrichDeepInsights(
    DeepPhotoInsights base,
    MlDetectionResult ml,
  ) {
    if (!ml.isMlPowered) {
      return base;
    }

    final tips = [...base.detailedTips];
    if (ml.faceCount > 0) {
      tips.insert(0, 'mlTipFaceDetected');
    }
    if (ml.hasPose) {
      tips.insert(0, 'mlTipPoseDetected');
    }
    if (ml.aestheticScore != null && ml.aestheticScore! >= 0.72) {
      tips.add('mlTipHighAesthetic');
    }

    final confidence = math.min(
      0.98,
      base.confidence +
          (ml.hasPose ? 0.12 : 0) +
          (ml.faceCount > 0 ? 0.08 : 0) +
          (ml.sceneLabels.isNotEmpty ? 0.05 : 0),
    );

    return DeepPhotoInsights(
      contrastScore: base.contrastScore,
      colorTemperatureKey: base.colorTemperatureKey,
      lightingDirectionKey: base.lightingDirectionKey,
      compositionBalanceKey: base.compositionBalanceKey,
      moodKey: base.moodKey,
      depthHintKey: base.depthHintKey,
      confidence: confidence,
      detailedTips: tips,
      analysisSource: 'ml_kit_hybrid',
    );
  }

  double _averageBrightness(img.Image image) {
    final sample = img.copyResize(image, width: 48);
    var total = 0.0;
    final pixelCount = sample.width * sample.height;

    for (var y = 0; y < sample.height; y++) {
      for (var x = 0; x < sample.width; x++) {
        final pixel = sample.getPixel(x, y);
        total += (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255;
      }
    }

    return total / pixelCount;
  }

  Rect _detectSubjectRegion(img.Image image, SceneType sceneType) {
    final sample = img.copyResize(image, width: 72);
    final cellScores = <_CellScore>[];

    const grid = 6;
    final cellW = sample.width / grid;
    final cellH = sample.height / grid;

    for (var row = 0; row < grid; row++) {
      for (var col = 0; col < grid; col++) {
        final left = (col * cellW).floor();
        final top = (row * cellH).floor();
        final right = math.min(((col + 1) * cellW).ceil(), sample.width);
        final bottom = math.min(((row + 1) * cellH).ceil(), sample.height);

        final score = _cellContrastScore(sample, left, top, right, bottom);
        final centerX = (left + right) / 2 / sample.width;
        final centerY = (top + bottom) / 2 / sample.height;
        final centerWeight =
            1 - (centerX - 0.5).abs() * 0.35 - (centerY - 0.45).abs() * 0.5;

        cellScores.add(
          _CellScore(
            rect: Rect.fromLTRB(
              left / sample.width,
              top / sample.height,
              right / sample.width,
              bottom / sample.height,
            ),
            score: score * centerWeight,
          ),
        );
      }
    }

    cellScores.sort((a, b) => b.score.compareTo(a.score));
    final best = cellScores.first.rect;

    final widthScale = sceneType == SceneType.landscape ? 2.8 : 2.4;
    final heightScale = sceneType.prefersHumanSilhouette ? 2.8 : 2.6;
    final maxWidth = sceneType == SceneType.landscape ? 0.88 : 0.72;
    final maxHeight = sceneType.prefersHumanSilhouette ? 0.88 : 0.82;

    return Rect.fromCenter(
      center: best.center,
      width: math.min(maxWidth, best.width * widthScale),
      height: math.min(maxHeight, best.height * heightScale),
    );
  }

  double _cellContrastScore(
    img.Image image,
    int left,
    int top,
    int right,
    int bottom,
  ) {
    var luminance = <double>[];
    for (var y = top; y < bottom; y++) {
      for (var x = left; x < right; x++) {
        final pixel = image.getPixel(x, y);
        luminance.add((0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255);
      }
    }

    if (luminance.isEmpty) {
      return 0;
    }

    final mean = luminance.reduce((a, b) => a + b) / luminance.length;
    final variance = luminance
            .map((value) => math.pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        luminance.length;

    return math.sqrt(variance) + mean.abs() * 0.15;
  }

  PhotoFrameTemplate _matchFrameTemplate(
    double aspectRatio,
    Rect subjectRect,
    SceneType sceneType,
  ) {
    if (sceneType == SceneType.portrait || sceneType == SceneType.group) {
      return aspectRatio < 0.9
          ? PhotoFrameTemplate.classicPortrait
          : PhotoFrameTemplate.portraitPost;
    }
    if (sceneType == SceneType.landscape) {
      return PhotoFrameTemplate.landscapePost;
    }
    if (sceneType == SceneType.square) {
      return PhotoFrameTemplate.squarePost;
    }

    final portraitBias = subjectRect.height >= subjectRect.width * 1.1;
    final candidates = PhotoFrameTemplate.values;
    PhotoFrameTemplate best = PhotoFrameTemplate.portraitPost;
    var bestDelta = double.infinity;

    for (final template in candidates) {
      var delta = (aspectRatio - template.aspectRatio).abs();
      if (portraitBias && template == PhotoFrameTemplate.landscapePost) {
        delta += 0.4;
      }
      if (!portraitBias && template == PhotoFrameTemplate.story) {
        delta += 0.15;
      }
      if (delta < bestDelta) {
        bestDelta = delta;
        best = template;
      }
    }

    return best;
  }

  CompositionOverlayType _pickOverlayType(Rect subjectRect, SceneType sceneType) {
    if (sceneType == SceneType.landscape) {
      return CompositionOverlayType.ruleOfThirds;
    }
    if (sceneType == SceneType.product) {
      return CompositionOverlayType.center;
    }

    final center = subjectRect.center;
    const third = 1 / 3;
    final nearVerticalThird =
        (center.dx - third).abs() < 0.12 || (center.dx - third * 2).abs() < 0.12;
    final nearHorizontalThird =
        (center.dy - third).abs() < 0.12 || (center.dy - third * 2).abs() < 0.12;

    if (nearVerticalThird && nearHorizontalThird) {
      return CompositionOverlayType.ruleOfThirds;
    }
    if ((center.dx - 0.5).abs() < 0.1 && (center.dy - 0.5).abs() < 0.1) {
      return CompositionOverlayType.center;
    }
    if (center.dx > 0.62 || center.dy > 0.62) {
      return CompositionOverlayType.goldenRatio;
    }
    return CompositionOverlayType.diagonal;
  }

  CameraGuidance _buildGuidance({
    required PhotoFrameTemplate frameTemplate,
    required CompositionOverlayType overlayType,
    required Rect subjectRect,
    required double brightness,
    required double subjectFillRatio,
    required SceneType userSceneType,
    required SubjectShapeKind subjectShape,
    required List<Offset>? silhouettePoints,
    required BodyPartGuides? bodyPartGuides,
  }) {
    final centerY = subjectRect.center.dy;
    final angleDegrees = ((centerY - 0.42) * -18).clamp(-12.0, 12.0);
    final exposureEv = (0.5 - brightness).clamp(-1.2, 1.2);
    var suggestedZoom = subjectFillRatio < 0.18
        ? 1.15
        : subjectFillRatio > 0.42
            ? 0.92
            : 1.0;

    if (userSceneType == SceneType.portrait && subjectFillRatio < 0.22) {
      suggestedZoom = 1.2;
    }

    return CameraGuidance(
      frameTemplate: frameTemplate,
      overlayType: overlayType,
      subjectTargetRect: subjectRect,
      suggestedZoom: suggestedZoom,
      angleDegrees: angleDegrees,
      exposureEv: exposureEv,
      framingHintKey: _framingHintKey(subjectRect),
      exposureHintKey: _exposureHintKey(brightness),
      distanceHintKey: _distanceHintKey(subjectFillRatio),
      angleHintKey: _angleHintKey(angleDegrees),
      subjectShape: subjectShape,
      subjectSilhouettePoints: silhouettePoints,
      bodyPartGuides: bodyPartGuides,
    );
  }

  String _resolveSceneTypeKey({
    required SceneType userSceneType,
    required Rect subjectRect,
    required double aspectRatio,
  }) {
    if (userSceneType != SceneType.auto) {
      return userSceneType.analysisSceneKey;
    }
    return _sceneTypeKey(subjectRect, aspectRatio);
  }

  bool _shouldUseHumanSilhouette({
    required SceneType userSceneType,
    required String sceneTypeKey,
    required Rect subjectRect,
    required double aspectRatio,
    required MlDetectionResult mlDetection,
    bool forLiveCoaching = false,
  }) {
    if (userSceneType.prefersHumanSilhouette) {
      return true;
    }
    if (sceneTypeKey == 'scenePortrait') {
      return true;
    }
    if (mlDetection.hasFaces || mlDetection.hasPose) {
      return true;
    }

    final tallSubject = subjectRect.height > subjectRect.width * 1.02;
    final centeredSubject = subjectRect.center.dx > 0.18 &&
        subjectRect.center.dx < 0.82;
    final portraitImage = aspectRatio < 1.15;
    final subjectFill = subjectRect.width * subjectRect.height;

    if (forLiveCoaching && sceneTypeKey != 'sceneLandscape') {
      if (tallSubject || mlDetection.faceCount > 0) {
        return true;
      }
      if (portraitImage && subjectFill > 0.04 && subjectFill < 0.82) {
        return true;
      }
    }

    return tallSubject &&
        centeredSubject &&
        portraitImage &&
        subjectFill > 0.05 &&
        subjectFill < 0.78;
  }

  String _sceneTypeKey(Rect subjectRect, double aspectRatio) {
    final tallSubject = subjectRect.height > subjectRect.width * 1.08;
    if (tallSubject && aspectRatio < 1.1) {
      return 'scenePortrait';
    }
    if (aspectRatio > 1.2) {
      return 'sceneLandscape';
    }
    if ((aspectRatio - 1).abs() < 0.08) {
      return 'sceneSquare';
    }
    return 'sceneLifestyle';
  }

  SceneType _sceneTypeFromKey(String key) {
    return switch (key) {
      'scenePortrait' => SceneType.portrait,
      'sceneLandscape' => SceneType.landscape,
      'sceneSquare' => SceneType.square,
      _ => SceneType.lifestyle,
    };
  }

  String _framingHintKey(Rect subjectRect) {
    final center = subjectRect.center;
    if (center.dx < 0.38) {
      return 'hintFramingLeft';
    }
    if (center.dx > 0.62) {
      return 'hintFramingRight';
    }
    if (center.dy < 0.34) {
      return 'hintFramingHigh';
    }
    if (center.dy > 0.66) {
      return 'hintFramingLow';
    }
    return 'hintFramingCenter';
  }

  String _exposureHintKey(double brightness) {
    if (brightness < 0.35) {
      return 'hintExposureBrighten';
    }
    if (brightness > 0.68) {
      return 'hintExposureDarken';
    }
    return 'hintExposureBalanced';
  }

  String _distanceHintKey(double subjectFillRatio) {
    if (subjectFillRatio < 0.16) {
      return 'hintDistanceCloser';
    }
    if (subjectFillRatio > 0.4) {
      return 'hintDistanceFurther';
    }
    return 'hintDistanceGood';
  }

  String _angleHintKey(double angleDegrees) {
    if (angleDegrees <= -4) {
      return 'hintAngleLower';
    }
    if (angleDegrees >= 4) {
      return 'hintAngleHigher';
    }
    return 'hintAngleLevel';
  }
}

class _CellScore {
  const _CellScore({required this.rect, required this.score});

  final Rect rect;
  final double score;
}