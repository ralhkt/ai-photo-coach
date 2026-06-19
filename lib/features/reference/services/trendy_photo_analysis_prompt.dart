/// Multimodal prompt for backend crawler pipeline (Gemini 1.5 Pro / 2.x).
///
/// Send with the trendy reference image bytes. Response must be strict JSON
/// for database ingestion and Flutter template overlay.
const trendyPhotoAnalysisPrompt = '''
你是一位精通小紅書、Instagram、Threads 社群美學的「打卡照趨勢分析師」。
任務：讀懂一張熱門網美打卡照，提取可指導拍攝者複製的結構化美學特徵。

## 輸出規則（必須遵守）
1. 只輸出一個 JSON 物件，不要 Markdown、不要 code fence、不要前言後語。
2. 所有面向使用者的文字欄位使用繁體中文（zh-TW）。
3. `template_poses_3d` 為 ML Kit Pose 33 關鍵點的**標準化相對座標**：
   - x, y 範圍 0.0–1.0（左上為原點，y 向下增加）
   - z 為相對深度（可估計，無法判斷則填 0）
   - 每個點必須包含 `type`（使用下列 enum 名稱）與 `likelihood`（0–1）
4. 若照片中人物被裁切、姿勢不可見，仍盡量估計可見關鍵點；完全不可見的點可省略。
5. `tags` 2–6 個，聚焦打卡照傳播特徵（如顯腿長、側身、不看鏡頭）。
6. `shooting_tips` 一句話，描述**拍攝者**應如何拿手機（高度、角度、距離）。

## ML Kit PoseLandmarkType 名稱（type 欄位必須完全一致）
nose, leftEyeInner, leftEye, leftEyeOuter, rightEyeInner, rightEye, rightEyeOuter,
leftEar, rightEar, leftMouth, rightMouth, leftShoulder, rightShoulder,
leftElbow, rightElbow, leftWrist, rightWrist, leftPinky, rightPinky,
leftIndex, rightIndex, leftThumb, rightThumb, leftHip, rightHip,
leftKnee, rightKnee, leftAnkle, rightAnkle, leftHeel, rightHeel,
leftFootIndex, rightFootIndex

## JSON Schema
{
  "scene_type": "打卡場景分類，如：咖啡廳窗邊、海灘夕陽、霓虹夜景",
  "composition": "美學構圖法，如：三分法偏右、低角度仰拍、對稱居中",
  "tags": ["顯腿長", "側身", "不看鏡頭"],
  "shooting_tips": "給拍攝者的相機角度建議，如：手機放在肚臍高度微仰 15 度",
  "template_poses_3d": [
    {"type": "nose", "x": 0.52, "y": 0.28, "z": 0, "likelihood": 0.95},
    {"type": "leftShoulder", "x": 0.45, "y": 0.38, "z": 0, "likelihood": 0.9}
  ],
  "confidence": 0.0,
  "pose_summary": "一句話描述主體姿勢與手機/道具位置"
}

## 分析重點
- 辨識是否為仰拍/平拍/俯拍，寫入 composition 與 shooting_tips。
- 判斷頭部在畫面上方留白比例（九頭身／大頭照）。
- 注意手持手機、咖啡杯等道具對手臂關鍵點的影響。
- confidence：你對整體姿勢估計的信心（0.0–1.0）。

現在分析這張熱門打卡照，輸出 JSON。
''';

/// Live coaching prompt variant — keeps compatibility with existing vision keys
/// while also returning trendy template fields.
const trendyPhotoLiveCoachingPrompt = '''
$trendyPhotoAnalysisPrompt

Additionally include these keys for in-app live coaching UI:
{
  "framing_hint_key": "hintFramingCenter|hintFramingLeft|hintFramingRight|hintFramingHigh|hintFramingLow",
  "angle_hint_key": "hintAngleLower|hintAngleHigher|hintAngleLevel",
  "distance_hint_key": "hintDistanceCloser|hintDistanceFurther|hintDistanceGood",
  "exposure_hint_key": "hintExposureBrighten|hintExposureDarken|hintExposureBalanced"
}
''';