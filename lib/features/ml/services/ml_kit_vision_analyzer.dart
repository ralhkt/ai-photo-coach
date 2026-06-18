import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image/image.dart' as img;

import '../../../models/body_part_guides.dart';
import '../../../models/ml_detection_result.dart';
import 'ml_aesthetic_scorer.dart';
import 'ml_input_image_helper.dart';
import 'pose_body_guide_mapper.dart';
import 'vision_analyzer.dart';

class MlKitVisionAnalyzer implements VisionAnalyzer {
  MlKitVisionAnalyzer({
    FaceDetector? faceDetector,
    PoseDetector? poseDetector,
    ImageLabeler? imageLabeler,
    PoseBodyGuideMapper? poseMapper,
    MlAestheticScorer? aestheticScorer,
  })  : _faceDetector = faceDetector ??
            FaceDetector(
              options: FaceDetectorOptions(
                enableContours: true,
                performanceMode: FaceDetectorMode.accurate,
              ),
            ),
        _poseDetector = poseDetector ??
            PoseDetector(
              options: PoseDetectorOptions(
                model: PoseDetectionModel.accurate,
              ),
            ),
        _imageLabeler = imageLabeler ??
            ImageLabeler(
              options: ImageLabelerOptions(confidenceThreshold: 0.42),
            ),
        _poseMapper = poseMapper ?? PoseBodyGuideMapper(),
        _aestheticScorer = aestheticScorer ?? MlAestheticScorer();

  final FaceDetector _faceDetector;
  final PoseDetector _poseDetector;
  final ImageLabeler _imageLabeler;
  final PoseBodyGuideMapper _poseMapper;
  final MlAestheticScorer _aestheticScorer;

  @override
  Future<MlDetectionResult> analyze({
    required Uint8List bytes,
    required int width,
    required int height,
  }) async {
    final stopwatch = Stopwatch()..start();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return MlDetectionResult(
        source: 'ml_kit',
        inferenceMs: stopwatch.elapsedMilliseconds,
      );
    }

    final input = MlInputImageHelper.fromDecodedImage(decoded);
    final imageWidth = decoded.width;
    final imageHeight = decoded.height;

    final faces = await _faceDetector.processImage(input);
    final poses = await _poseDetector.processImage(input);
    final labels = await _imageLabeler.processImage(input);

    final faceBounds = faces
        .map(
          (face) => _normalizeRect(face.boundingBox, imageWidth, imageHeight),
        )
        .toList();

    BodyPartGuides? bodyGuides;
    Rect? poseSubject;
    var hasPose = false;

    if (poses.isNotEmpty) {
      final primaryPose = poses.first;
      bodyGuides = _poseMapper.fromPose(
        primaryPose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
      poseSubject = _poseMapper.subjectRectFromPose(
        primaryPose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
      hasPose = bodyGuides != null;
    }

    final sceneLabels = labels
        .map(
          (label) => MlSceneLabel(
            text: label.label,
            confidence: label.confidence,
          ),
        )
        .toList();

    final primarySubject = poseSubject ?? _subjectFromFaces(faceBounds);

    stopwatch.stop();
    return MlDetectionResult(
      source: 'ml_kit',
      inferenceMs: stopwatch.elapsedMilliseconds,
      faceBounds: faceBounds,
      primarySubjectRect: primarySubject,
      bodyPartGuides: bodyGuides,
      sceneLabels: sceneLabels,
      aestheticScore: _aestheticScorer.scoreFromLabels(sceneLabels),
      faceCount: faces.length,
      hasPose: hasPose,
    );
  }

  Rect? _subjectFromFaces(List<Rect> faces) {
    if (faces.isEmpty) {
      return null;
    }

    var left = faces.first.left;
    var top = faces.first.top;
    var right = faces.first.right;
    var bottom = faces.first.bottom;

    for (final face in faces.skip(1)) {
      left = left < face.left ? left : face.left;
      top = top < face.top ? top : face.top;
      right = right > face.right ? right : face.right;
      bottom = bottom > face.bottom ? bottom : face.bottom;
    }

    final width = right - left;
    final height = bottom - top;
    return Rect.fromLTWH(
      (left - width * 0.18).clamp(0.0, 1.0),
      (top - height * 0.55).clamp(0.0, 1.0),
      (right + width * 0.18).clamp(0.0, 1.0),
      (bottom + height * 1.35).clamp(0.0, 1.0),
    );
  }

  Rect _normalizeRect(Rect rect, int width, int height) {
    return Rect.fromLTRB(
      (rect.left / width).clamp(0.0, 1.0),
      (rect.top / height).clamp(0.0, 1.0),
      (rect.right / width).clamp(0.0, 1.0),
      (rect.bottom / height).clamp(0.0, 1.0),
    );
  }

  @override
  Future<void> dispose() async {
    await _faceDetector.close();
    await _poseDetector.close();
    await _imageLabeler.close();
  }
}