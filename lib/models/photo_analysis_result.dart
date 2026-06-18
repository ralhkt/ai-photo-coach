import 'dart:typed_data';

import 'camera_guidance.dart';
import 'deep_photo_insights.dart';
import 'ml_detection_result.dart';
import 'photo_frame_template.dart';
import 'scene_type.dart';

class PhotoAnalysisResult {
  const PhotoAnalysisResult({
    required this.sourceAspectRatio,
    required this.brightness,
    required this.subjectFillRatio,
    required this.recommendedFrame,
    required this.guidance,
    required this.sceneTypeKey,
    required this.imageBytes,
    this.userSceneType = SceneType.auto,
    this.deepInsights,
    this.mlDetection,
  });

  final double sourceAspectRatio;
  final double brightness;
  final double subjectFillRatio;
  final PhotoFrameTemplate recommendedFrame;
  final CameraGuidance guidance;
  final String sceneTypeKey;
  final Uint8List imageBytes;
  final SceneType userSceneType;
  final DeepPhotoInsights? deepInsights;
  final MlDetectionResult? mlDetection;
}