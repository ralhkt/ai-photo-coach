import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_point3d.dart';
import '../models/trendy_photo_template.dart';
import 'seated_phone_template_pose.dart';

/// MVP trendy templates keyed by [ReferenceSample.id].
///
/// Replace with crawler + Gemini-ingested JSON when backend pipeline is live.
final trendyTemplateCatalog = <String, TrendyPhotoTemplate>{
  'checkin_cafe': const TrendyPhotoTemplate(
    id: 'checkin_cafe',
    sceneType: '咖啡廳窗邊',
    composition: '三分法偏右、自然窗光',
    tags: const ['顯臉小', '手拿咖啡', '不看鏡頭'],
    shootingTips: '手機與胸口同高，微仰 10 度，人物靠窗站',
    templatePoses3d: seatedPhoneTemplatePose,
    poseSummary: '坐姿靠窗，一手拿咖啡杯，視線看向窗外',
    sourcePlatform: '小紅書',
  ),
  'checkin_neon_city': const TrendyPhotoTemplate(
    id: 'checkin_neon_city',
    sceneType: '霓虹夜景街拍',
    composition: '低角度仰拍、人物置中偏左',
    tags: const ['顯腿長', '夜景氛圍', '側身'],
    shootingTips: '手機放在肚臍高度仰拍 20 度，讓霓虹燈在頭頂留白',
    templatePoses3d: _standingSidePose,
    poseSummary: '側身站立，一腳前伸，視線斜向遠處',
    sourcePlatform: 'Instagram',
  ),
  'checkin_street_portrait': const TrendyPhotoTemplate(
    id: 'checkin_street_portrait',
    sceneType: '街頭全身鏡自拍',
    composition: '全身居中、鏡面對稱',
    tags: const ['OOTD', '顯腿長', '全身入鏡'],
    shootingTips: '手機與鏡面平行，略低於腰部高度仰拍',
    templatePoses3d: _mirrorSelfiePose,
    poseSummary: '全身站立，一手拿手機遮臉，重心在後腳',
    sourcePlatform: 'Threads',
  ),
  'checkin_brunch': const TrendyPhotoTemplate(
    id: 'checkin_brunch',
    sceneType: '早午餐窗邊',
    composition: '三分法、坐姿半身',
    tags: const ['溫柔氛圍', '坐姿', '顯鎖骨'],
    shootingTips: '手機與桌面同高略仰，讓窗光打在臉部側面',
    templatePoses3d: seatedPhoneTemplatePose,
    poseSummary: '窗邊坐姿，身體微側，雙手交疊放桌上',
    sourcePlatform: '小紅書',
  ),
  'checkin_travel_alps': const TrendyPhotoTemplate(
    id: 'checkin_travel_alps',
    sceneType: '旅行山景',
    composition: '人小景大、三分法下線',
    tags: const ['旅行打卡', '背影', '顯腿長'],
    shootingTips: '手機放低仰拍，人物腳踝貼近畫面下緣',
    templatePoses3d: _travelStandingPose,
    poseSummary: '背對鏡頭站立，雙手自然下垂，望向遠方',
    sourcePlatform: 'Instagram',
  ),
  'checkin_beach_sunset': const TrendyPhotoTemplate(
    id: 'checkin_beach_sunset',
    sceneType: '海灘夕陽',
    composition: '剪影輪廓、低角度仰拍',
    tags: const ['夕陽剪影', '顯腿長', '側身'],
    shootingTips: '手機貼近沙灘高度仰拍，夕陽留在肩膀上方',
    templatePoses3d: _standingSidePose,
    poseSummary: '側身迎向夕陽，一腳前點地拉長腿部線條',
    sourcePlatform: '小紅書',
  ),
};

TrendyPhotoTemplate? trendyTemplateForSample(String sampleId) {
  return trendyTemplateCatalog[sampleId];
}

const _standingSidePose = <PosePoint3D>[
  PosePoint3D(type: PoseLandmarkType.nose, x: 0.58, y: 0.24, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftEar, x: 0.54, y: 0.22, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightEar, x: 0.62, y: 0.22, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftShoulder, x: 0.50, y: 0.32, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightShoulder, x: 0.60, y: 0.30, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftElbow, x: 0.46, y: 0.44, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightElbow, x: 0.58, y: 0.38, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftWrist, x: 0.44, y: 0.52, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightWrist, x: 0.56, y: 0.28, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftHip, x: 0.48, y: 0.54, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightHip, x: 0.56, y: 0.54, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftKnee, x: 0.42, y: 0.72, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightKnee, x: 0.54, y: 0.68, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftAnkle, x: 0.40, y: 0.92, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightAnkle, x: 0.52, y: 0.88, z: 0),
];

const _mirrorSelfiePose = <PosePoint3D>[
  PosePoint3D(type: PoseLandmarkType.nose, x: 0.50, y: 0.18, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftEar, x: 0.46, y: 0.16, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightEar, x: 0.54, y: 0.16, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftShoulder, x: 0.42, y: 0.26, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightShoulder, x: 0.58, y: 0.26, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftElbow, x: 0.38, y: 0.38, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightElbow, x: 0.48, y: 0.22, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftWrist, x: 0.36, y: 0.48, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightWrist, x: 0.44, y: 0.14, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftHip, x: 0.44, y: 0.50, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightHip, x: 0.56, y: 0.50, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftKnee, x: 0.42, y: 0.68, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightKnee, x: 0.54, y: 0.66, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftAnkle, x: 0.40, y: 0.90, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightAnkle, x: 0.52, y: 0.88, z: 0),
];

const _travelStandingPose = <PosePoint3D>[
  PosePoint3D(type: PoseLandmarkType.nose, x: 0.52, y: 0.30, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftEar, x: 0.48, y: 0.28, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightEar, x: 0.56, y: 0.28, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftShoulder, x: 0.46, y: 0.38, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightShoulder, x: 0.54, y: 0.38, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftElbow, x: 0.44, y: 0.48, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightElbow, x: 0.56, y: 0.48, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftWrist, x: 0.42, y: 0.56, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightWrist, x: 0.58, y: 0.56, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftHip, x: 0.46, y: 0.54, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightHip, x: 0.54, y: 0.54, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftKnee, x: 0.44, y: 0.70, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightKnee, x: 0.52, y: 0.68, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftAnkle, x: 0.42, y: 0.91, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightAnkle, x: 0.50, y: 0.89, z: 0),
];