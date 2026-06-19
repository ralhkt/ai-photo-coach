import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Normalized 3D pose landmark (0.0–1.0 image space).
///
/// Alias for product docs that refer to "Point3D" template coordinates.
typedef Point3D = PosePoint3D;

class PosePoint3D {
  const PosePoint3D({
    required this.x,
    required this.y,
    this.z = 0,
    this.type,
    this.likelihood = 1,
  });

  final double x;
  final double y;
  final double z;
  final PoseLandmarkType? type;
  final double likelihood;

  PosePoint3D copyWith({
    double? x,
    double? y,
    double? z,
    PoseLandmarkType? type,
    double? likelihood,
  }) {
    return PosePoint3D(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      type: type ?? this.type,
      likelihood: likelihood ?? this.likelihood,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'z': z,
        if (type != null) 'type': type!.name,
        'likelihood': likelihood,
      };

  factory PosePoint3D.fromJson(Map<String, dynamic> json) {
    final typeName = json['type']?.toString();
    return PosePoint3D(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num?)?.toDouble() ?? 0,
      type: typeName == null
          ? null
          : PoseLandmarkType.values.byName(typeName),
      likelihood: (json['likelihood'] as num?)?.toDouble() ?? 1,
    );
  }
}