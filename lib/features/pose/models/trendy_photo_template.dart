import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_point3d.dart';

/// Database record for a crawler-sourced trendy check-in photo.
class TrendyPhotoTemplate {
  const TrendyPhotoTemplate({
    required this.id,
    required this.sceneType,
    required this.composition,
    required this.tags,
    required this.shootingTips,
    required this.templatePoses3d,
    this.poseSummary = '',
    this.confidence = 0.75,
    this.sourcePlatform,
  });

  final String id;
  final String sceneType;
  final String composition;
  final List<String> tags;
  final String shootingTips;
  final List<PosePoint3D> templatePoses3d;
  final String poseSummary;
  final double confidence;
  final String? sourcePlatform;

  bool get hasPoseTemplate => templatePoses3d.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'scene_type': sceneType,
        'composition': composition,
        'tags': tags,
        'shooting_tips': shootingTips,
        'template_poses_3d': templatePoses3d.map((p) => p.toJson()).toList(),
        if (poseSummary.isNotEmpty) 'pose_summary': poseSummary,
        'confidence': confidence,
        if (sourcePlatform != null) 'source_platform': sourcePlatform,
      };

  factory TrendyPhotoTemplate.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final posesRaw = json['template_poses_3d'];

    return TrendyPhotoTemplate(
      id: json['id']?.toString() ?? 'unknown',
      sceneType: json['scene_type']?.toString() ?? '打卡場景',
      composition: json['composition']?.toString() ?? '三分法',
      tags: tagsRaw is List
          ? tagsRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
          : const [],
      shootingTips: json['shooting_tips']?.toString() ?? '',
      templatePoses3d: _parsePoseList(posesRaw),
      poseSummary: json['pose_summary']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble().clamp(0.0, 1.0) ?? 0.75,
      sourcePlatform: json['source_platform']?.toString(),
    );
  }

  static List<PosePoint3D> _parsePoseList(Object? raw) {
    if (raw is! List) {
      return const [];
    }

    final points = <PosePoint3D>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      try {
        points.add(PosePoint3D.fromJson(item));
      } catch (_) {
        final typeName = item['type']?.toString();
        if (typeName == null) {
          continue;
        }
        try {
          points.add(
            PosePoint3D(
              type: PoseLandmarkType.values.byName(typeName),
              x: (item['x'] as num).toDouble(),
              y: (item['y'] as num).toDouble(),
              z: (item['z'] as num?)?.toDouble() ?? 0,
              likelihood: (item['likelihood'] as num?)?.toDouble() ?? 0.9,
            ),
          );
        } catch (_) {}
      }
    }
    return points;
  }
}