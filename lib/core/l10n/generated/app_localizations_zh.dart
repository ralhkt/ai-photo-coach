// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '攝影師';

  @override
  String get cameraPermissionRequired => '需要相機權限才能使用此 App。';

  @override
  String get grantPermission => '授予權限';

  @override
  String get noCameraFound => '此裝置找不到相機。';

  @override
  String get initializingCamera => '正在初始化相機...';

  @override
  String get cameraError => '無法啟動相機。';

  @override
  String get retry => '重試';

  @override
  String get overlayRuleOfThirds => '三分法';

  @override
  String get overlayGoldenRatio => '黃金比例';

  @override
  String get overlayCenter => '置中';

  @override
  String get overlayDiagonal => '對角線';

  @override
  String get overlayLabel => '構圖';

  @override
  String get toggleOverlay => '切換構圖線';

  @override
  String get cycleOverlay => '切換構圖模式';

  @override
  String get homeSubtitle => '上载参考相片，自动分析并生成拍摄 frame 与相机参数建议。';

  @override
  String get uploadReferenceTitle => '分析参考相片';

  @override
  String get uploadReferenceSubtitle => '上载人像 post 或参考图，系统会分析构图并生成拍摄框线。';

  @override
  String get openCameraTitle => '开启相机';

  @override
  String get openCameraSubtitle => '自由拍摄模式，附构图辅助线。';

  @override
  String get pickFromGallery => '从相册选择';

  @override
  String get pickFromCamera => '拍摄参考图';

  @override
  String get uploadPrompt => '选择你想模仿的相片，例如人像 post 或生活照。';

  @override
  String get analyzingImage => '正在分析图片...';

  @override
  String get analysisFailed => '图片分析失败，请换一张相片再试。';

  @override
  String get analysisResultTitle => '分析结果';

  @override
  String detectedScene(String scene) {
    return '侦测场景：$scene';
  }

  @override
  String get recommendedFrame => '建议 frame';

  @override
  String get recommendedComposition => '构图方式';

  @override
  String get framingGuidance => '取景位置';

  @override
  String get exposureGuidance => '曝光';

  @override
  String get distanceGuidance => '距离';

  @override
  String get angleGuidance => '角度';

  @override
  String get chooseFrameTemplate => '选择 post 比例';

  @override
  String get startGuidedShoot => '开始引导拍摄';

  @override
  String get guidedShootTitle => '引导拍摄';

  @override
  String get noReferenceLoaded => '尚未载入参考分析结果。';

  @override
  String get toggleFrame => '切换 frame';

  @override
  String get cycleFrame => '切换比例';

  @override
  String get framePortraitPost => '人像 Post (4:5)';

  @override
  String get frameStory => 'Story (9:16)';

  @override
  String get frameSquarePost => '正方形 Post (1:1)';

  @override
  String get frameLandscapePost => '横向 (16:9)';

  @override
  String get frameClassicPortrait => '经典人像 (3:4)';

  @override
  String get scenePortrait => '人像';

  @override
  String get sceneLandscape => '风景';

  @override
  String get sceneSquare => '方形社群贴文';

  @override
  String get sceneLifestyle => '生活风格';

  @override
  String get hintFramingLeft => '将主体放在左侧三分线';

  @override
  String get hintFramingRight => '将主体放在右侧三分线';

  @override
  String get hintFramingHigh => '主体放在画面上方区域';

  @override
  String get hintFramingLow => '主体放在画面下方区域';

  @override
  String get hintFramingCenter => '将主体居中';

  @override
  String get hintExposureBrighten => '稍微提高曝光 (+EV)';

  @override
  String get hintExposureDarken => '稍微降低曝光 (-EV)';

  @override
  String get hintExposureBalanced => '曝光大致平衡';

  @override
  String get hintDistanceCloser => '靠近一点以匹配主体大小';

  @override
  String get hintDistanceFurther => '后退一点保留更多空间';

  @override
  String get hintDistanceGood => '距离合适';

  @override
  String get hintAngleLower => '降低角度约 8-12°';

  @override
  String get hintAngleHigher => '提高角度约 8-12°';

  @override
  String get hintAngleLevel => '保持镜头水平';

  @override
  String get cameraModePhoto => '相片';

  @override
  String get cameraModeGuided => '引导';

  @override
  String get captureFailed => '拍照失败。';

  @override
  String get photoPreview => '相片';

  @override
  String get galleryPreview => '相册';

  @override
  String get keepShooting => '继续拍摄';

  @override
  String get openGallery => '开启相册';

  @override
  String get exposureLock => '曝光锁定';

  @override
  String get timerOff => '定时器';

  @override
  String get timer3s => '3 秒';

  @override
  String get timer10s => '10 秒';

  @override
  String get aeAfLocked => '曝光/对焦锁定';

  @override
  String burstCapturing(int count) {
    return '连拍 · $count';
  }

  @override
  String burstReviewTitle(int current, int total) {
    return '连拍 $current / $total';
  }

  @override
  String get burstHint => '长按快门启动连拍';

  @override
  String arPlaneDetected(int count) {
    return '平面 ×$count';
  }

  @override
  String get arPlaneSearching => '寻找平面';

  @override
  String get arUnavailable => 'AR 不可用';

  @override
  String get arUnsupported => '不支持 AR';

  @override
  String get sceneStable => '场景已锁定';

  @override
  String get sceneChanged => '场景变化';

  @override
  String get sceneMonitoring => '监测场景';

  @override
  String get sceneIdle => '场景待命';

  @override
  String get selectSceneType => '这张照片是什么场景？';

  @override
  String get selectSceneTypeHint => '选择场景可帮助 AI 更准确分析主体与构图。';

  @override
  String get sceneTypeAuto => '自动识别';

  @override
  String get sceneTypePortrait => '人像';

  @override
  String get sceneTypeLandscape => '风景';

  @override
  String get sceneTypeLifestyle => '生活风格';

  @override
  String get sceneTypeSquare => '方形贴文';

  @override
  String get sceneTypeGroup => '团体照';

  @override
  String get sceneTypeProduct => '产品';

  @override
  String get userSelectedScene => '你选择的场景';

  @override
  String get analysisDetectedSceneLabel => '识别场景';

  @override
  String get subjectShapeTitle => '主体框线';

  @override
  String get subjectShapeHuman => '人形轮廓（参考图提取）';

  @override
  String get basicGuidanceTitle => '拍摄建议';

  @override
  String get deepAnalysisTitle => '深入分析';

  @override
  String get deepAnalysisSubtitle => '本机光线、构图与氛围解读';

  @override
  String get insightColorTitle => '色调';

  @override
  String get insightLightingTitle => '光线';

  @override
  String get insightBalanceTitle => '构图平衡';

  @override
  String get insightMoodTitle => '氛围';

  @override
  String get insightDepthTitle => '景深';

  @override
  String get insightConfidenceTitle => '信心度';

  @override
  String insightConfidenceValue(int percent) {
    return '$percent%';
  }

  @override
  String get insightDetailedTipsTitle => '详细建议';

  @override
  String get aiAgentNote => '目前使用本机分析。若需更深入（姿势、造型、故事感），日后可接入云端视觉 AI Agent。';

  @override
  String get aiAgentNoteMl => 'Phase 3 已启用本机 ML Kit（人脸、姿态、场景标签），无需云端 API。';

  @override
  String get mlAnalysisTitle => '本机 ML 分析';

  @override
  String mlFaceDetected(int count) {
    return '检测到 $count 张人脸';
  }

  @override
  String get mlPoseDetected => '已检测人体姿态';

  @override
  String mlInferenceMs(int ms) {
    return '推理耗时 $ms ms';
  }

  @override
  String mlAestheticScore(String score) {
    return '美学评分 $score';
  }

  @override
  String get mlAnalysisSourceMlKit => 'ML Kit（本机）';

  @override
  String get mlAnalysisSourceFallback => '启发式回退';

  @override
  String get mlTipFaceDetected => 'ML 检测到人脸，框架已对齐脸部范围';

  @override
  String get mlTipPoseDetected => 'ML 检测到人体姿态，头/肩/身引导已优化';

  @override
  String get mlTipHighAesthetic => 'ML 标签显示此参考图具有较高视觉吸引力';

  @override
  String get insightColorWarm => '暖色调';

  @override
  String get insightColorCool => '冷色调';

  @override
  String get insightColorNeutral => '中性色调';

  @override
  String get insightLightingTop => '顶部光为主';

  @override
  String get insightLightingBottom => '底部光较重';

  @override
  String get insightLightingBacklit => '逆光 — 建议补光';

  @override
  String get insightLightingEven => '光线均匀';

  @override
  String get insightBalanceCentered => '居中构图';

  @override
  String get insightBalanceLeft => '主体偏左';

  @override
  String get insightBalanceRight => '主体偏右';

  @override
  String get insightBalanceDynamic => '动态偏离构图';

  @override
  String get insightMoodDramatic => '戏剧感';

  @override
  String get insightMoodBrightWarm => '明亮温暖';

  @override
  String get insightMoodSoft => '柔和低对比';

  @override
  String get insightMoodNatural => '自然日常';

  @override
  String get insightDepthShallow => '浅景深 — 背景可能虚化';

  @override
  String get insightDepthDeep => '深景深 — 背景较清晰';

  @override
  String get insightDepthModerate => '中等景深';

  @override
  String get insightTipPortraitHeadroom => '人像贴文请保留头部上方空间';

  @override
  String get insightTipPortraitCropTight => '参考图裁切较紧 — 避免切到额头或下巴';

  @override
  String get insightTipLandscapeHorizon => '地平线宜放在上或下三分之一';

  @override
  String get insightTipLandscapeForeground => '加入前景可增加层次感';

  @override
  String get insightTipProductCleanBg => '产品拍摄建议使用干净背景';

  @override
  String get insightTipRaiseExposure => '画面偏暗 — 可稍微提高曝光';

  @override
  String get insightTipLowerExposure => '画面偏亮 — 可降低曝光保护高光';

  @override
  String get insightTipIncreaseContrast => '对比偏低 — 加强主体与背景分离';

  @override
  String get insightTipBacklitFill => '逆光主体 — 使用反光板或提高面部曝光';

  @override
  String get insightTipKeepNegativeSpace => '保留主体另一侧的留白';

  @override
  String get insightTipWarmSkinTones => '偏冷色 — 可暖化白平衡以改善肤色';

  @override
  String get proMode => '专业';

  @override
  String get aspectRatio4x3 => '4:3';

  @override
  String get aspectRatio16x9 => '16:9';

  @override
  String get aspectRatio1x1 => '1:1';

  @override
  String get aspectRatioFull => '全屏';

  @override
  String get histogram => '直方图';

  @override
  String get frontMirror => '镜像';

  @override
  String exposureEvLabel(String value) {
    return '曝光 $value';
  }

  @override
  String get bodyPartHead => '頭';

  @override
  String get bodyPartShoulders => '肩';

  @override
  String get bodyPartTorso => '身';

  @override
  String get bodyPartHips => '腰';

  @override
  String get alignmentGuideTitle => '姿勢對齊';

  @override
  String get alignmentStepHead => '1. 將眼睛對準黃色頭部橢圓';

  @override
  String get alignmentStepShoulders => '2. 肩膀對齊青色肩框';

  @override
  String get alignmentStepTorso => '3. 身體對齊白色軀幹框';

  @override
  String get alignmentStepHips => '4. 腰部對齊紫色臀框';

  @override
  String get toggleGhostOverlay => '切换参考半透明图';

  @override
  String get toggleBodyPartGuides => '切换身体部位框';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguageSection => '语言';

  @override
  String get settingsGuidanceSection => '引导提示';

  @override
  String get settingsVoiceGuidance => '语音引导';

  @override
  String get settingsVoiceGuidanceSubtitle => '拍摄时朗读提示（目前以浮动消息预览）';

  @override
  String get settingsPromptStrength => '提示强度';

  @override
  String get settingsPromptStrengthHint => '控制相机画面上显示多少引导信息';

  @override
  String get promptStrengthLow => '低';

  @override
  String get promptStrengthMedium => '中';

  @override
  String get promptStrengthHigh => '高';

  @override
  String get localeZhTw => '繁体中文';

  @override
  String get localeZhCn => '简体中文';

  @override
  String get localeEn => 'English';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String get onboardingTitle1 => '你的本机摄影教练';

  @override
  String get onboardingBody1 => '上传参考图或开启相机，所有分析都在手机本机完成。';

  @override
  String get onboardingTitle2 => '实时取景引导';

  @override
  String get onboardingBody2 => '构图格线、姿势对齐与曝光提示，帮你拍出参考同款构图。';

  @override
  String get onboardingTitle3 => '拍摄总结';

  @override
  String get onboardingBody3 => '结束拍摄后，快速查看最佳照片与改进建议。';

  @override
  String get endSession => '完成拍摄';

  @override
  String get sessionSummaryTitle => '拍摄总结';

  @override
  String get sessionSummarySubtitle => '本次拍摄表现如下';

  @override
  String get sessionSummaryLoading => '正在分析你的照片...';

  @override
  String get sessionStatPhotos => '张数';

  @override
  String get sessionStatDuration => '时长';

  @override
  String get sessionStatMode => '模式';

  @override
  String get sessionStatAesthetic => '平均美学分';

  @override
  String get sessionModeFree => '自由拍摄';

  @override
  String get sessionModeGuided => '引导拍摄';

  @override
  String get sessionBestShot => '最佳照片';

  @override
  String get sessionFeedbackTitle => '下次可以试试';

  @override
  String get sessionDone => '返回首页';

  @override
  String get sessionEndDialogTitle => '结束本次拍摄？';

  @override
  String get sessionEndDialogBody => '你已拍下照片。可查看总结，或直接离开不保存本次记录。';

  @override
  String get sessionEndDialogCancel => '继续拍摄';

  @override
  String get sessionEndDialogDiscard => '直接离开';

  @override
  String get sessionEndDialogSummarize => '查看总结';

  @override
  String get sessionTipGuidedPractice => '引导模式用得很好，继续对齐参考构图。';

  @override
  String get sessionTipTryGuided => '试试上传参考图并使用引导拍摄，构图会更精准。';

  @override
  String get sessionTipStrongComposition => '构图表现不错，可维持这种取景方式。';

  @override
  String get sessionTipImproveLighting => '试试更柔和的光线或调整曝光，画面会更有层次。';

  @override
  String get sessionTipRefineFraming => '微调取景（头顶留白、地平线）能让照片更出色。';

  @override
  String get sessionTipTooDark => '多张照片偏暗，可提高现场亮度或增加 EV。';

  @override
  String get sessionTipTooBright => '高光略过曝，可稍微降低曝光。';

  @override
  String get sessionTipBalancedExposure => '本次曝光平衡表现良好。';

  @override
  String get sessionTipGreatVolume => '拍摄张数充足，可挑选最清晰的神态或姿势。';

  @override
  String sessionSummaryProgress(int completed, int total) {
    return '正在分析 $completed / $total';
  }

  @override
  String get sessionStatAnalysisTime => '分析耗时';

  @override
  String sessionStatAnalysisMs(int ms) {
    return '$ms 毫秒';
  }

  @override
  String get sessionStatBattery => '电池消耗';

  @override
  String sessionStatBatteryDelta(int percent) {
    return '$percent%';
  }

  @override
  String get settingsPerformanceSection => '性能';

  @override
  String get settingsPowerSave => '省电模式';

  @override
  String get settingsPowerSaveSubtitle => '降低场景检测频率、关闭 AR、加快拍摄总结';

  @override
  String get diagnosticsTitle => '性能诊断';

  @override
  String get diagnosticsEntrySubtitle => '计时样本与电池 session 统计';

  @override
  String get diagnosticsSubtitle => '本机 MVP 目标（ML < 150 ms，10 分钟 < 7% 电量）。';

  @override
  String get diagnosticsMlBudget => 'ML 快速推理';

  @override
  String get diagnosticsSessionPhotoBudget => 'Session 照片快速评分';

  @override
  String get diagnosticsSessionTotalBudget => 'Session 总结总耗时';

  @override
  String diagnosticsBudgetValue(String avg, String budget, String count) {
    return '平均 $avg ms / 上限 $budget ms（超标 $count 次）';
  }

  @override
  String get diagnosticsLastBattery => '上次相机 session 电池';

  @override
  String diagnosticsBatteryDetail(int delta, String per10, String status) {
    return '消耗 $delta%（$per10%/10 分钟）— $status';
  }

  @override
  String get diagnosticsWithinBudget => '符合 MVP 目标';

  @override
  String get diagnosticsOverBudget => '超出 MVP 目标';

  @override
  String get diagnosticsRunBenchmark => '运行快速评分基准测试';

  @override
  String get diagnosticsRunningBenchmark => '基准测试运行中...';

  @override
  String get diagnosticsClearSamples => '清除计时样本';

  @override
  String get liveSceneAnalyze => '分析场景';

  @override
  String get liveSceneAnalyzing => '正在分析场景...';

  @override
  String get liveSceneAdviceTitle => 'AI 拍摄建议';

  @override
  String get liveSceneAnalyzeFailed => '无法分析目前场景，请再试一次。';

  @override
  String get liveSceneReanalyze => '重新分析';

  @override
  String liveSceneOverlayApplied(String overlay) {
    return '构图叠层：$overlay';
  }

  @override
  String liveSceneMlSummary(String source, String score) {
    return '$source · 美学分 $score';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '攝影師';

  @override
  String get cameraPermissionRequired => '需要相機權限才能使用此 App。';

  @override
  String get grantPermission => '授予權限';

  @override
  String get noCameraFound => '此裝置找不到相機。';

  @override
  String get initializingCamera => '正在初始化相機...';

  @override
  String get cameraError => '無法啟動相機。';

  @override
  String get retry => '重試';

  @override
  String get overlayRuleOfThirds => '三分法';

  @override
  String get overlayGoldenRatio => '黃金比例';

  @override
  String get overlayCenter => '置中';

  @override
  String get overlayDiagonal => '對角線';

  @override
  String get overlayLabel => '構圖';

  @override
  String get toggleOverlay => '切換構圖線';

  @override
  String get cycleOverlay => '切換構圖模式';

  @override
  String get homeSubtitle => '上載參考相片，自動分析並生成拍攝 frame 與相機參數建議。';

  @override
  String get uploadReferenceTitle => '分析參考相片';

  @override
  String get uploadReferenceSubtitle => '上載人像 post 或參考圖，系統會分析構圖並生成拍攝框線。';

  @override
  String get openCameraTitle => '開啟相機';

  @override
  String get openCameraSubtitle => '自由拍攝模式，附構圖輔助線。';

  @override
  String get pickFromGallery => '從相簿選擇';

  @override
  String get pickFromCamera => '拍攝參考圖';

  @override
  String get uploadPrompt => '選擇你想模仿的相片，例如人像 post 或生活照。';

  @override
  String get analyzingImage => '正在分析圖片...';

  @override
  String get analysisFailed => '圖片分析失敗，請換一張相片再試。';

  @override
  String get analysisResultTitle => '分析結果';

  @override
  String detectedScene(String scene) {
    return '偵測場景：$scene';
  }

  @override
  String get recommendedFrame => '建議 frame';

  @override
  String get recommendedComposition => '構圖方式';

  @override
  String get framingGuidance => '取景位置';

  @override
  String get exposureGuidance => '曝光';

  @override
  String get distanceGuidance => '距離';

  @override
  String get angleGuidance => '角度';

  @override
  String get chooseFrameTemplate => '選擇 post 比例';

  @override
  String get startGuidedShoot => '開始引導拍攝';

  @override
  String get guidedShootTitle => '引導拍攝';

  @override
  String get noReferenceLoaded => '尚未載入參考分析結果。';

  @override
  String get toggleFrame => '切換 frame';

  @override
  String get cycleFrame => '切換比例';

  @override
  String get framePortraitPost => '人像 Post (4:5)';

  @override
  String get frameStory => 'Story (9:16)';

  @override
  String get frameSquarePost => '正方形 Post (1:1)';

  @override
  String get frameLandscapePost => '橫向 (16:9)';

  @override
  String get frameClassicPortrait => '經典人像 (3:4)';

  @override
  String get scenePortrait => '人像';

  @override
  String get sceneLandscape => '風景';

  @override
  String get sceneSquare => '方形社群貼文';

  @override
  String get sceneLifestyle => '生活風格';

  @override
  String get hintFramingLeft => '將主體放在左側三分線';

  @override
  String get hintFramingRight => '將主體放在右側三分線';

  @override
  String get hintFramingHigh => '主體放在畫面上方區域';

  @override
  String get hintFramingLow => '主體放在畫面下方區域';

  @override
  String get hintFramingCenter => '將主體置中';

  @override
  String get hintExposureBrighten => '稍微提高曝光 (+EV)';

  @override
  String get hintExposureDarken => '稍微降低曝光 (-EV)';

  @override
  String get hintExposureBalanced => '曝光大致平衡';

  @override
  String get hintDistanceCloser => '靠近一點以匹配主體大小';

  @override
  String get hintDistanceFurther => '後退一點保留更多空間';

  @override
  String get hintDistanceGood => '距離合適';

  @override
  String get hintAngleLower => '降低角度約 8-12°';

  @override
  String get hintAngleHigher => '提高角度約 8-12°';

  @override
  String get hintAngleLevel => '保持鏡頭水平';

  @override
  String get cameraModePhoto => '相片';

  @override
  String get cameraModeGuided => '引導';

  @override
  String get captureFailed => '拍照失敗。';

  @override
  String get photoPreview => '相片';

  @override
  String get galleryPreview => '相簿';

  @override
  String get keepShooting => '繼續拍攝';

  @override
  String get openGallery => '開啟相簿';

  @override
  String get exposureLock => '曝光鎖定';

  @override
  String get timerOff => '定時器';

  @override
  String get timer3s => '3 秒';

  @override
  String get timer10s => '10 秒';

  @override
  String get aeAfLocked => '曝光/對焦鎖定';

  @override
  String burstCapturing(int count) {
    return '連拍 · $count';
  }

  @override
  String burstReviewTitle(int current, int total) {
    return '連拍 $current / $total';
  }

  @override
  String get burstHint => '長按快門啟動連拍';

  @override
  String arPlaneDetected(int count) {
    return '平面 ×$count';
  }

  @override
  String get arPlaneSearching => '尋找平面';

  @override
  String get arUnavailable => 'AR 不可用';

  @override
  String get arUnsupported => '不支援 AR';

  @override
  String get sceneStable => '場景已鎖定';

  @override
  String get sceneChanged => '場景變化';

  @override
  String get sceneMonitoring => '監測場景';

  @override
  String get sceneIdle => '場景待命';

  @override
  String get selectSceneType => '這張照片是什麼場景？';

  @override
  String get selectSceneTypeHint => '選擇場景可幫助 AI 更準確分析主體與構圖。';

  @override
  String get sceneTypeAuto => '自動識別';

  @override
  String get sceneTypePortrait => '人像';

  @override
  String get sceneTypeLandscape => '風景';

  @override
  String get sceneTypeLifestyle => '生活風格';

  @override
  String get sceneTypeSquare => '方形貼文';

  @override
  String get sceneTypeGroup => '團體照';

  @override
  String get sceneTypeProduct => '產品';

  @override
  String get userSelectedScene => '你選擇的場景';

  @override
  String get analysisDetectedSceneLabel => '識別場景';

  @override
  String get subjectShapeTitle => '主體框線';

  @override
  String get subjectShapeHuman => '人形輪廓（參考圖提取）';

  @override
  String get basicGuidanceTitle => '拍攝建議';

  @override
  String get deepAnalysisTitle => '深入分析';

  @override
  String get deepAnalysisSubtitle => '本機光線、構圖與氛圍解讀';

  @override
  String get insightColorTitle => '色調';

  @override
  String get insightLightingTitle => '光線';

  @override
  String get insightBalanceTitle => '構圖平衡';

  @override
  String get insightMoodTitle => '氛圍';

  @override
  String get insightDepthTitle => '景深';

  @override
  String get insightConfidenceTitle => '信心度';

  @override
  String insightConfidenceValue(int percent) {
    return '$percent%';
  }

  @override
  String get insightDetailedTipsTitle => '詳細建議';

  @override
  String get aiAgentNote => '目前使用本機分析。若需更深入（姿勢、造型、故事感），日後可接入雲端視覺 AI Agent。';

  @override
  String get aiAgentNoteMl => 'Phase 3 已啟用本機 ML Kit（人臉、姿態、場景標籤），無需雲端 API。';

  @override
  String get mlAnalysisTitle => '本機 ML 分析';

  @override
  String mlFaceDetected(int count) {
    return '偵測到 $count 張人臉';
  }

  @override
  String get mlPoseDetected => '已偵測人體姿態';

  @override
  String mlInferenceMs(int ms) {
    return '推理耗時 $ms ms';
  }

  @override
  String mlAestheticScore(String score) {
    return '美學評分 $score';
  }

  @override
  String get mlAnalysisSourceMlKit => 'ML Kit（本機）';

  @override
  String get mlAnalysisSourceFallback => '啟發式回退';

  @override
  String get mlTipFaceDetected => 'ML 偵測到人臉，框架已對齊臉部範圍';

  @override
  String get mlTipPoseDetected => 'ML 偵測到人體姿態，頭/肩/身引導已優化';

  @override
  String get mlTipHighAesthetic => 'ML 標籤顯示此參考圖具有較高視覺吸引力';

  @override
  String get insightColorWarm => '暖色調';

  @override
  String get insightColorCool => '冷色調';

  @override
  String get insightColorNeutral => '中性色調';

  @override
  String get insightLightingTop => '頂部光為主';

  @override
  String get insightLightingBottom => '底部光較重';

  @override
  String get insightLightingBacklit => '逆光 — 建議補光';

  @override
  String get insightLightingEven => '光線均勻';

  @override
  String get insightBalanceCentered => '置中構圖';

  @override
  String get insightBalanceLeft => '主體偏左';

  @override
  String get insightBalanceRight => '主體偏右';

  @override
  String get insightBalanceDynamic => '動態偏離構圖';

  @override
  String get insightMoodDramatic => '戲劇感';

  @override
  String get insightMoodBrightWarm => '明亮溫暖';

  @override
  String get insightMoodSoft => '柔和低對比';

  @override
  String get insightMoodNatural => '自然日常';

  @override
  String get insightDepthShallow => '淺景深 — 背景可能虛化';

  @override
  String get insightDepthDeep => '深景深 — 背景較清晰';

  @override
  String get insightDepthModerate => '中等景深';

  @override
  String get insightTipPortraitHeadroom => '人像貼文請保留頭部上方空間';

  @override
  String get insightTipPortraitCropTight => '參考圖裁切較緊 — 避免切到額頭或下巴';

  @override
  String get insightTipLandscapeHorizon => '地平線宜放在上或下三分之一';

  @override
  String get insightTipLandscapeForeground => '加入前景可增加層次感';

  @override
  String get insightTipProductCleanBg => '產品拍攝建議使用乾淨背景';

  @override
  String get insightTipRaiseExposure => '畫面偏暗 — 可稍微提高曝光';

  @override
  String get insightTipLowerExposure => '畫面偏亮 — 可降低曝光保護高光';

  @override
  String get insightTipIncreaseContrast => '對比偏低 — 加強主體與背景分離';

  @override
  String get insightTipBacklitFill => '逆光主體 — 使用反光板或提高面部曝光';

  @override
  String get insightTipKeepNegativeSpace => '保留主體另一側的留白';

  @override
  String get insightTipWarmSkinTones => '偏冷色 — 可暖化白平衡以改善膚色';

  @override
  String get proMode => '專業';

  @override
  String get aspectRatio4x3 => '4:3';

  @override
  String get aspectRatio16x9 => '16:9';

  @override
  String get aspectRatio1x1 => '1:1';

  @override
  String get aspectRatioFull => '全螢幕';

  @override
  String get histogram => '直方圖';

  @override
  String get frontMirror => '鏡像';

  @override
  String exposureEvLabel(String value) {
    return '曝光 $value';
  }

  @override
  String get bodyPartHead => '頭';

  @override
  String get bodyPartShoulders => '肩';

  @override
  String get bodyPartTorso => '身';

  @override
  String get bodyPartHips => '腰';

  @override
  String get alignmentGuideTitle => '姿勢對齊';

  @override
  String get alignmentStepHead => '1. 將眼睛對準黃色頭部橢圓';

  @override
  String get alignmentStepShoulders => '2. 肩膀對齊青色肩框';

  @override
  String get alignmentStepTorso => '3. 身體對齊白色軀幹框';

  @override
  String get alignmentStepHips => '4. 腰部對齊紫色臀框';

  @override
  String get toggleGhostOverlay => '切換參考半透明圖';

  @override
  String get toggleBodyPartGuides => '切換身體部位框';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguageSection => '語言';

  @override
  String get settingsGuidanceSection => '引導提示';

  @override
  String get settingsVoiceGuidance => '語音引導';

  @override
  String get settingsVoiceGuidanceSubtitle => '拍攝時朗讀提示（目前以浮動訊息預覽）';

  @override
  String get settingsPromptStrength => '提示強度';

  @override
  String get settingsPromptStrengthHint => '控制相機畫面上顯示多少引導資訊';

  @override
  String get promptStrengthLow => '低';

  @override
  String get promptStrengthMedium => '中';

  @override
  String get promptStrengthHigh => '高';

  @override
  String get localeZhTw => '繁體中文';

  @override
  String get localeZhCn => '簡體中文';

  @override
  String get localeEn => 'English';

  @override
  String get onboardingSkip => '略過';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingGetStarted => '開始使用';

  @override
  String get onboardingTitle1 => '你的本機攝影教練';

  @override
  String get onboardingBody1 => '上傳參考圖或開啟相機，所有分析都在手機本機完成。';

  @override
  String get onboardingTitle2 => '即時取景引導';

  @override
  String get onboardingBody2 => '構圖格線、姿勢對齊與曝光提示，幫你拍出參考同款構圖。';

  @override
  String get onboardingTitle3 => '拍攝總結';

  @override
  String get onboardingBody3 => '結束拍攝後，快速查看最佳照片與改進建議。';

  @override
  String get endSession => '完成拍攝';

  @override
  String get sessionSummaryTitle => '拍攝總結';

  @override
  String get sessionSummarySubtitle => '本次拍攝表現如下';

  @override
  String get sessionSummaryLoading => '正在分析你的照片...';

  @override
  String get sessionStatPhotos => '張數';

  @override
  String get sessionStatDuration => '時長';

  @override
  String get sessionStatMode => '模式';

  @override
  String get sessionStatAesthetic => '平均美學分';

  @override
  String get sessionModeFree => '自由拍攝';

  @override
  String get sessionModeGuided => '引導拍攝';

  @override
  String get sessionBestShot => '最佳照片';

  @override
  String get sessionFeedbackTitle => '下次可以試試';

  @override
  String get sessionDone => '返回首頁';

  @override
  String get sessionEndDialogTitle => '結束本次拍攝？';

  @override
  String get sessionEndDialogBody => '你已拍下照片。可查看總結，或直接離開不儲存本次紀錄。';

  @override
  String get sessionEndDialogCancel => '繼續拍攝';

  @override
  String get sessionEndDialogDiscard => '直接離開';

  @override
  String get sessionEndDialogSummarize => '查看總結';

  @override
  String get sessionTipGuidedPractice => '引導模式用得很好，繼續對齊參考構圖。';

  @override
  String get sessionTipTryGuided => '試試上傳參考圖並使用引導拍攝，構圖會更精準。';

  @override
  String get sessionTipStrongComposition => '構圖表現不錯，可維持這種取景方式。';

  @override
  String get sessionTipImproveLighting => '試試更柔和的光線或調整曝光，畫面會更有層次。';

  @override
  String get sessionTipRefineFraming => '微調取景（頭頂留白、地平線）能讓照片更出色。';

  @override
  String get sessionTipTooDark => '多張照片偏暗，可提高現場亮度或增加 EV。';

  @override
  String get sessionTipTooBright => '高光略過曝，可稍微降低曝光。';

  @override
  String get sessionTipBalancedExposure => '本次曝光平衡表現良好。';

  @override
  String get sessionTipGreatVolume => '拍攝張數充足，可挑選最清晰的神態或姿勢。';

  @override
  String sessionSummaryProgress(int completed, int total) {
    return '正在分析 $completed / $total';
  }

  @override
  String get sessionStatAnalysisTime => '分析耗時';

  @override
  String sessionStatAnalysisMs(int ms) {
    return '$ms 毫秒';
  }

  @override
  String get sessionStatBattery => '電池消耗';

  @override
  String sessionStatBatteryDelta(int percent) {
    return '$percent%';
  }

  @override
  String get settingsPerformanceSection => '效能';

  @override
  String get settingsPowerSave => '省電模式';

  @override
  String get settingsPowerSaveSubtitle => '降低場景偵測頻率、關閉 AR、加快拍攝總結';

  @override
  String get diagnosticsTitle => '效能診斷';

  @override
  String get diagnosticsEntrySubtitle => '計時樣本與電池 session 統計';

  @override
  String get diagnosticsSubtitle => '本機 MVP 目標（ML < 150 ms，10 分鐘 < 7% 電量）。';

  @override
  String get diagnosticsMlBudget => 'ML 快速推論';

  @override
  String get diagnosticsSessionPhotoBudget => 'Session 照片快速評分';

  @override
  String get diagnosticsSessionTotalBudget => 'Session 總結總耗時';

  @override
  String diagnosticsBudgetValue(String avg, String budget, String count) {
    return '平均 $avg ms / 上限 $budget ms（超標 $count 次）';
  }

  @override
  String get diagnosticsLastBattery => '上次相機 session 電池';

  @override
  String diagnosticsBatteryDetail(int delta, String per10, String status) {
    return '消耗 $delta%（$per10%/10 分鐘）— $status';
  }

  @override
  String get diagnosticsWithinBudget => '符合 MVP 目標';

  @override
  String get diagnosticsOverBudget => '超出 MVP 目標';

  @override
  String get diagnosticsRunBenchmark => '執行快速評分基準測試';

  @override
  String get diagnosticsRunningBenchmark => '基準測試執行中...';

  @override
  String get diagnosticsClearSamples => '清除計時樣本';

  @override
  String get liveSceneAnalyze => '分析場景';

  @override
  String get liveSceneAnalyzing => '正在分析場景...';

  @override
  String get liveSceneAdviceTitle => 'AI 拍攝建議';

  @override
  String get liveSceneAnalyzeFailed => '無法分析目前場景，請再試一次。';

  @override
  String get liveSceneReanalyze => '重新分析';

  @override
  String liveSceneOverlayApplied(String overlay) {
    return '構圖疊層：$overlay';
  }

  @override
  String liveSceneMlSummary(String source, String score) {
    return '$source · 美學分 $score';
  }
}
