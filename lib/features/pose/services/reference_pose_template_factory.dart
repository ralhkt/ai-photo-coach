import '../models/pose_point3d.dart';
import '../models/trendy_photo_template.dart';

/// Builds a live-coaching template from an uploaded reference photo pose.
abstract final class ReferencePoseTemplateFactory {
  static TrendyPhotoTemplate? fromLandmarks(List<PosePoint3D> landmarks) {
    if (landmarks.length < 8) {
      return null;
    }

    return TrendyPhotoTemplate(
      id: 'reference_upload',
      sceneType: 'reference',
      composition: 'reference_pose',
      tags: const ['reference', 'upload'],
      shootingTips: '對齊參考照的姿勢與比例',
      templatePoses3d: landmarks,
      poseSummary: '參考照姿勢',
      confidence: 0.92,
      sourcePlatform: 'reference_photo',
    );
  }
}