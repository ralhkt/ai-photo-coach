// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Photographer';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to use this app.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get noCameraFound => 'No camera found on this device.';

  @override
  String get initializingCamera => 'Initializing camera...';

  @override
  String get cameraError => 'Failed to start camera.';

  @override
  String get retry => 'Retry';

  @override
  String get overlayRuleOfThirds => 'Rule of Thirds';

  @override
  String get overlayGoldenRatio => 'Golden Ratio';

  @override
  String get overlayCenter => 'Center';

  @override
  String get overlayDiagonal => 'Diagonal';

  @override
  String get overlayLabel => 'Composition';

  @override
  String get toggleOverlay => 'Toggle overlay';

  @override
  String get cycleOverlay => 'Cycle overlay';

  @override
  String get homeSubtitle => 'Choose a reference. Get guidance. Take the shot.';

  @override
  String get homeHeadlineContinue => 'Continue guided shoot';

  @override
  String get homeHeadlineStart => 'Start guided shoot';

  @override
  String get homeSectionStartNew => 'More options';

  @override
  String get homeSectionGetStarted => 'Get started';

  @override
  String get homeEnterGuidedCamera => 'Enter guided camera';

  @override
  String get poseCoachAligning => 'Align your body to the outline.';

  @override
  String get poseCoachMatched => 'Pose aligned. Ready to shoot.';

  @override
  String get poseCoachAdjust => 'Adjust position to align your face.';

  @override
  String get alignmentToastNoMatch => 'Step into the center of the outline';

  @override
  String get alignmentToastAligning =>
      'Aligning limbs… fit your body to the outline';

  @override
  String get alignmentToastMatched => 'Perfect alignment! Ready to shoot';

  @override
  String get openCameraSkipTitle => 'Skip guidance';

  @override
  String get openCameraSkipSubtitle => 'Free shoot without pose guidance.';

  @override
  String get homeWorkflowLabel => 'Reference → Analyze → Shoot';

  @override
  String get homeFlowStepReference => 'Reference';

  @override
  String get homeFlowStepAnalyze => 'Analyze';

  @override
  String get homeFlowStepShoot => 'Shoot';

  @override
  String get homeContinueGuided => 'Continue guided shoot';

  @override
  String get homeContinueGuidedSubtitle =>
      'Reference analyzed. Open the camera to continue.';

  @override
  String get analysisExpandDetails => 'Show full analysis';

  @override
  String get analysisCollapseDetails => 'Hide details';

  @override
  String get guidedOverlayTools => 'Overlays';

  @override
  String get uploadReferenceTitle => 'Choose Example Photo';

  @override
  String get uploadReferenceSubtitle =>
      'Use a built-in sample or choose from your library.';

  @override
  String get openCameraTitle => 'Open Camera';

  @override
  String get openCameraSubtitle => 'Free shoot with live scene analysis.';

  @override
  String get pickFromGallery => 'Choose from Gallery';

  @override
  String get pickFromCamera => 'Take Reference Photo';

  @override
  String get uploadPrompt => 'Choose a sample or upload your own photo.';

  @override
  String get referenceSamplesSection => 'Sample photos';

  @override
  String get uploadOwnPhotoSection => 'Upload a photo';

  @override
  String get referenceSampleCheckinCafe => 'Café selfie';

  @override
  String get referenceSampleCheckinCafeHint =>
      'Warm pendant lamp, standing pose';

  @override
  String get referenceSampleCheckinNeon => 'Neon street';

  @override
  String get referenceSampleCheckinNeonHint => 'Night side light, sign glow';

  @override
  String get referenceSampleCheckinPortrait => 'Mirror OOTD';

  @override
  String get referenceSampleCheckinPortraitHint =>
      'Full-length mirror, fitting room';

  @override
  String get referenceSampleCheckinBrunch => 'Window seat';

  @override
  String get referenceSampleCheckinBrunchHint => 'Soft side light, seated pose';

  @override
  String get referenceSampleCheckinTravel => 'Summit view';

  @override
  String get referenceSampleCheckinTravelHint =>
      'Small figure, hiking back view';

  @override
  String get referenceSampleCheckinBeach => 'Beach sunset';

  @override
  String get referenceSampleCheckinBeachHint => 'Back silhouette, rocky shore';

  @override
  String get analyzingImage => 'Analyzing image...';

  @override
  String get analysisFailed =>
      'Image analysis failed. Please try another photo.';

  @override
  String get analysisResultTitle => 'Analysis Result';

  @override
  String detectedScene(String scene) {
    return 'Detected scene: $scene';
  }

  @override
  String get recommendedFrame => 'Recommended frame';

  @override
  String get recommendedComposition => 'Composition';

  @override
  String get framingGuidance => 'Framing';

  @override
  String get exposureGuidance => 'Exposure';

  @override
  String get distanceGuidance => 'Distance';

  @override
  String get angleGuidance => 'Angle';

  @override
  String get chooseFrameTemplate => 'Choose post frame';

  @override
  String get startGuidedShoot => 'Start Guided Shoot';

  @override
  String get guidedShootTitle => 'Guided Shoot';

  @override
  String get noReferenceLoaded => 'No reference analysis loaded.';

  @override
  String get toggleFrame => 'Toggle frame';

  @override
  String get cycleFrame => 'Cycle frame';

  @override
  String get framePortraitPost => 'Portrait Post (4:5)';

  @override
  String get frameStory => 'Story (9:16)';

  @override
  String get frameSquarePost => 'Square Post (1:1)';

  @override
  String get frameLandscapePost => 'Landscape (16:9)';

  @override
  String get frameClassicPortrait => 'Classic Portrait (3:4)';

  @override
  String get scenePortrait => 'Portrait';

  @override
  String get sceneLandscape => 'Landscape';

  @override
  String get sceneSquare => 'Square social post';

  @override
  String get sceneLifestyle => 'Lifestyle';

  @override
  String get hintFramingLeft => 'Place subject on the left third';

  @override
  String get hintFramingRight => 'Place subject on the right third';

  @override
  String get hintFramingHigh => 'Keep subject in the upper area of the frame';

  @override
  String get hintFramingLow => 'Keep subject in the lower area of the frame';

  @override
  String get hintFramingCenter => 'Center the subject in the frame';

  @override
  String get hintExposureBrighten => 'Increase exposure slightly (+EV)';

  @override
  String get hintExposureDarken => 'Decrease exposure slightly (-EV)';

  @override
  String get hintExposureBalanced => 'Exposure looks balanced';

  @override
  String get hintDistanceCloser => 'Move closer to match subject size';

  @override
  String get hintDistanceFurther => 'Step back for more headroom';

  @override
  String get hintDistanceGood => 'Distance looks good';

  @override
  String get hintAngleLower => 'Lower angle about 8-12°';

  @override
  String get hintAngleHigher => 'Raise angle about 8-12°';

  @override
  String get hintAngleLevel => 'Keep camera level';

  @override
  String get cameraModePhoto => 'PHOTO';

  @override
  String get cameraModeVideo => 'VIDEO';

  @override
  String get cameraModeGuided => 'GUIDED';

  @override
  String get cameraModeVideoComingSoon => 'Video recording is coming soon';

  @override
  String get cameraFormatJpeg => 'JPEG';

  @override
  String get cameraFormatMegapixel => '24';

  @override
  String get cameraModeSwitchNeedReference =>
      'Upload and analyze a reference photo before using guided mode.';

  @override
  String get cameraModeUploadReference => 'Upload reference';

  @override
  String get cameraModeSwipeHint =>
      'Swipe or tap to switch between Photo and Guided mode';

  @override
  String get cameraModeCoachGotIt => 'Got it';

  @override
  String get captureFailed => 'Failed to capture photo.';

  @override
  String get photoPreview => 'Photo';

  @override
  String get galleryPreview => 'Gallery';

  @override
  String get keepShooting => 'Keep Shooting';

  @override
  String get saveToGallery => 'Save to Photos';

  @override
  String get photoSavedToGallery => 'Saved to Photos';

  @override
  String get photoSaveFailed =>
      'Could not save — allow Photos access in Settings and try again';

  @override
  String get savingPhoto => 'Saving…';

  @override
  String get openGallery => 'Open Gallery';

  @override
  String get hdrLabel => 'HDR';

  @override
  String get hdrComingSoon =>
      'HDR capture is not available yet on this device.';

  @override
  String get exposureLock => 'AE/AF Lock';

  @override
  String get timerOff => 'Timer';

  @override
  String get timer3s => '3s';

  @override
  String get timer10s => '10s';

  @override
  String get aeAfLocked => 'AE/AF LOCK';

  @override
  String burstCapturing(int count) {
    return 'Burst · $count';
  }

  @override
  String burstReviewTitle(int current, int total) {
    return 'Burst $current of $total';
  }

  @override
  String get burstHint => 'Hold shutter for burst mode';

  @override
  String arPlaneDetected(int count) {
    return 'Plane ×$count';
  }

  @override
  String get arPlaneSearching => 'Finding plane';

  @override
  String get arUnavailable => 'AR unavailable';

  @override
  String get arUnsupported => 'AR unsupported';

  @override
  String get sceneStable => 'Scene locked';

  @override
  String get sceneChanged => 'Scene changed';

  @override
  String get sceneMonitoring => 'Watching scene';

  @override
  String get sceneIdle => 'Scene idle';

  @override
  String get selectSceneType => 'What is in this photo?';

  @override
  String get selectSceneTypeHint =>
      'Choosing a scene helps the analyzer focus on the right subject and framing.';

  @override
  String get sceneTypeAuto => 'Auto detect';

  @override
  String get sceneTypePortrait => 'Portrait';

  @override
  String get sceneTypeLandscape => 'Landscape';

  @override
  String get sceneTypeLifestyle => 'Lifestyle';

  @override
  String get sceneTypeSquare => 'Square post';

  @override
  String get sceneTypeGroup => 'Group photo';

  @override
  String get sceneTypeProduct => 'Product';

  @override
  String get userSelectedScene => 'Your scene choice';

  @override
  String get analysisDetectedSceneLabel => 'Detected scene';

  @override
  String get subjectShapeTitle => 'Subject frame';

  @override
  String get subjectShapeHuman => 'Human silhouette (from reference)';

  @override
  String get basicGuidanceTitle => 'Camera guidance';

  @override
  String get deepAnalysisTitle => 'Deep analysis';

  @override
  String get deepAnalysisSubtitle =>
      'On-device lighting, composition and mood breakdown';

  @override
  String get insightColorTitle => 'Color tone';

  @override
  String get insightLightingTitle => 'Lighting';

  @override
  String get insightBalanceTitle => 'Composition balance';

  @override
  String get insightMoodTitle => 'Mood';

  @override
  String get insightDepthTitle => 'Depth of field';

  @override
  String get insightConfidenceTitle => 'Confidence';

  @override
  String insightConfidenceValue(int percent) {
    return '$percent%';
  }

  @override
  String get insightDetailedTipsTitle => 'Detailed tips';

  @override
  String get aiAgentNote =>
      'This MVP uses on-device analysis. For richer feedback (pose, styling, story), a cloud vision AI agent can be plugged in later via PhotoAnalysisAgent.';

  @override
  String get aiAgentNoteMl =>
      'Phase 3 ML Kit runs fully on-device (face, pose, scene labels). No cloud API is used.';

  @override
  String get mlAnalysisTitle => 'On-device ML';

  @override
  String get mlSourceLabel => 'Analysis source';

  @override
  String get mlFaceCountLabel => 'Face detection';

  @override
  String get mlPerformanceLabel => 'Performance';

  @override
  String mlFaceDetected(int count) {
    return '$count face(s) detected';
  }

  @override
  String get mlPoseDetected => 'Body pose detected';

  @override
  String mlInferenceMs(int ms) {
    return 'Inference $ms ms';
  }

  @override
  String mlAestheticScore(String score) {
    return 'Aesthetic score $score';
  }

  @override
  String get mlAnalysisSourceMlKit => 'ML Kit (on-device)';

  @override
  String get mlAnalysisSourceGemini => 'Gemini Vision';

  @override
  String get mlAnalysisSourceOpenRouter => 'OpenRouter (Gemini)';

  @override
  String get mlAnalysisSourceFallback => 'Heuristic fallback';

  @override
  String get referenceMatchTip =>
      'Matched a similar reference style — adjust pose and framing using the overlay.';

  @override
  String get mlTipFaceDetected =>
      'ML detected a face — framing aligned to facial bounds';

  @override
  String get mlTipPoseDetected =>
      'ML detected body pose — head/shoulder/torso guides refined';

  @override
  String get mlTipHighAesthetic =>
      'ML labels suggest strong visual appeal in this reference';

  @override
  String get insightColorWarm => 'Warm tones';

  @override
  String get insightColorCool => 'Cool tones';

  @override
  String get insightColorNeutral => 'Neutral tones';

  @override
  String get insightLightingTop => 'Top-lit scene';

  @override
  String get insightLightingBottom => 'Bottom-weighted light';

  @override
  String get insightLightingBacklit => 'Backlit — add fill light';

  @override
  String get insightLightingEven => 'Even lighting';

  @override
  String get insightBalanceCentered => 'Centered composition';

  @override
  String get insightBalanceLeft => 'Subject weighted left';

  @override
  String get insightBalanceRight => 'Subject weighted right';

  @override
  String get insightBalanceDynamic => 'Dynamic off-center balance';

  @override
  String get insightMoodDramatic => 'Dramatic mood';

  @override
  String get insightMoodBrightWarm => 'Bright & warm';

  @override
  String get insightMoodSoft => 'Soft & low contrast';

  @override
  String get insightMoodNatural => 'Natural everyday mood';

  @override
  String get insightDepthShallow => 'Shallow depth — blurred background likely';

  @override
  String get insightDepthDeep => 'Deep focus — more background detail';

  @override
  String get insightDepthModerate => 'Moderate depth of field';

  @override
  String get insightTipPortraitHeadroom =>
      'Leave headroom above the subject for portrait posts';

  @override
  String get insightTipPortraitCropTight =>
      'Reference crop is tight — avoid cutting forehead or chin';

  @override
  String get insightTipLandscapeHorizon =>
      'Keep horizon near upper or lower third, not center';

  @override
  String get insightTipLandscapeForeground =>
      'Include foreground interest for depth';

  @override
  String get insightTipProductCleanBg =>
      'Use a clean background to isolate the product';

  @override
  String get insightTipRaiseExposure =>
      'Scene is dark — raise exposure slightly';

  @override
  String get insightTipLowerExposure =>
      'Scene is bright — lower exposure to protect highlights';

  @override
  String get insightTipIncreaseContrast =>
      'Low contrast — add separation between subject and background';

  @override
  String get insightTipBacklitFill =>
      'Backlit subject — use reflector or increase exposure on face';

  @override
  String get insightTipKeepNegativeSpace =>
      'Preserve negative space on the opposite side of the subject';

  @override
  String get insightTipWarmSkinTones =>
      'Cool cast detected — warm white balance for skin';

  @override
  String get proMode => 'Pro';

  @override
  String get aspectRatio4x3 => '4:3';

  @override
  String get aspectRatio16x9 => '16:9';

  @override
  String get aspectRatio1x1 => '1:1';

  @override
  String get aspectRatioFull => 'Full';

  @override
  String get histogram => 'Histogram';

  @override
  String get frontMirror => 'Mirror';

  @override
  String exposureEvLabel(String value) {
    return 'EV $value';
  }

  @override
  String get bodyPartHead => 'Head';

  @override
  String get bodyPartShoulders => 'Shoulders';

  @override
  String get bodyPartTorso => 'Torso';

  @override
  String get bodyPartHips => 'Hips';

  @override
  String get alignmentGuideTitle => 'Pose alignment';

  @override
  String get alignmentStepHead => '1. Place eyes in the yellow head oval';

  @override
  String get alignmentStepShoulders => '2. Match shoulder width to cyan frame';

  @override
  String get alignmentStepTorso => '3. Align torso inside white frame';

  @override
  String get alignmentStepHips => '4. Match hip position to purple frame';

  @override
  String get toggleGhostOverlay => 'Toggle reference ghost';

  @override
  String get guidedGhostOpacityLabel => 'Ghost opacity';

  @override
  String guidedGhostOpacityPercent(int percent) {
    return '$percent%';
  }

  @override
  String get toggleBodyPartGuides => 'Toggle body-part guides';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsGuidanceSection => 'Guidance';

  @override
  String get settingsVoiceGuidance => 'Voice guidance';

  @override
  String get settingsVoiceGuidanceSubtitle =>
      'Speak tips aloud while shooting (snackbar preview)';

  @override
  String get settingsPromptStrength => 'Prompt strength';

  @override
  String get settingsPromptStrengthHint =>
      'Controls how many hints appear on the camera screen';

  @override
  String get promptStrengthLow => 'Low';

  @override
  String get promptStrengthMedium => 'Medium';

  @override
  String get promptStrengthHigh => 'High';

  @override
  String get localeZhTw => 'Traditional Chinese';

  @override
  String get localeZhCn => 'Simplified Chinese';

  @override
  String get localeEn => 'English';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingTitle1 => 'On-device guidance';

  @override
  String get onboardingBody1 =>
      'Analysis runs on your device. No connection required.';

  @override
  String get onboardingTitle2 => 'Live composition aids';

  @override
  String get onboardingBody2 =>
      'Grids, pose outlines, and exposure hints appear in the viewfinder.';

  @override
  String get onboardingTitle3 => 'Shoot review';

  @override
  String get onboardingBody3 =>
      'See your best shot and suggestions when you finish.';

  @override
  String get endSession => 'Finish session';

  @override
  String get sessionSummaryTitle => 'Session summary';

  @override
  String get sessionSummarySubtitle => 'Here\'s how this shoot went';

  @override
  String get sessionSummaryLoading => 'Analyzing your photos...';

  @override
  String get sessionStatPhotos => 'Photos';

  @override
  String get sessionStatDuration => 'Duration';

  @override
  String get sessionStatMode => 'Mode';

  @override
  String get sessionStatAesthetic => 'Avg. aesthetic';

  @override
  String get sessionModeFree => 'Free shoot';

  @override
  String get sessionModeGuided => 'Guided shoot';

  @override
  String get sessionBestShot => 'Best shot';

  @override
  String get sessionFeedbackTitle => 'Tips for next time';

  @override
  String get sessionDone => 'Back to home';

  @override
  String get sessionEndDialogTitle => 'End this session?';

  @override
  String get sessionEndDialogBody =>
      'You have captured photos. View a summary or leave without saving the session.';

  @override
  String get sessionEndDialogCancel => 'Keep shooting';

  @override
  String get sessionEndDialogDiscard => 'Leave';

  @override
  String get sessionEndDialogSummarize => 'View summary';

  @override
  String get sessionTipGuidedPractice =>
      'Great job using guided mode — keep matching the reference frame.';

  @override
  String get sessionTipTryGuided =>
      'Try guided mode with a sample photo for tighter framing.';

  @override
  String get sessionTipStrongComposition =>
      'Composition looks strong — keep this framing style.';

  @override
  String get sessionTipImproveLighting =>
      'Try softer light or adjust exposure for richer tones.';

  @override
  String get sessionTipRefineFraming =>
      'Small framing tweaks (headroom, horizon) can lift the shot.';

  @override
  String get sessionTipTooDark =>
      'Several shots were underexposed — brighten the scene or raise EV.';

  @override
  String get sessionTipTooBright =>
      'Highlights are clipping — lower exposure slightly.';

  @override
  String get sessionTipBalancedExposure =>
      'Exposure balance looks good across this session.';

  @override
  String get sessionTipGreatVolume =>
      'Nice volume of shots — pick the sharpest expression or pose.';

  @override
  String sessionSummaryProgress(int completed, int total) {
    return 'Analyzing $completed / $total';
  }

  @override
  String get sessionStatAnalysisTime => 'Analysis time';

  @override
  String sessionStatAnalysisMs(int ms) {
    return '$ms ms';
  }

  @override
  String get sessionStatBattery => 'Battery used';

  @override
  String sessionStatBatteryDelta(int percent) {
    return '$percent%';
  }

  @override
  String get settingsPerformanceSection => 'Performance';

  @override
  String get settingsAutoLiveSceneAnalysis => 'Auto scene analysis';

  @override
  String get settingsAutoLiveSceneAnalysisSubtitle =>
      'Analyze the scene automatically when the view stabilizes in free shoot mode';

  @override
  String get settingsPowerSave => 'Power save mode';

  @override
  String get settingsPowerSaveSubtitle =>
      'Slower scene checks, skip AR, faster session analysis';

  @override
  String get diagnosticsTitle => 'Performance diagnostics';

  @override
  String get diagnosticsEntrySubtitle =>
      'Timing samples and battery session stats';

  @override
  String get diagnosticsSubtitle =>
      'On-device budgets for MVP targets (ML < 150 ms, 10 min < 7% battery).';

  @override
  String get diagnosticsMlBudget => 'ML quick inference';

  @override
  String get diagnosticsSessionPhotoBudget => 'Session photo quick score';

  @override
  String get diagnosticsSessionTotalBudget => 'Session summary total';

  @override
  String diagnosticsBudgetValue(String avg, String budget, String count) {
    return 'avg $avg ms / $budget ms (over $count)';
  }

  @override
  String get diagnosticsLastBattery => 'Last camera session battery';

  @override
  String diagnosticsBatteryDetail(int delta, String per10, String status) {
    return 'Used $delta% ($per10%/10 min) — $status';
  }

  @override
  String get diagnosticsWithinBudget => 'within MVP budget';

  @override
  String get diagnosticsOverBudget => 'above MVP budget';

  @override
  String get diagnosticsRunBenchmark => 'Run quick-score benchmark';

  @override
  String get diagnosticsRunningBenchmark => 'Running benchmark...';

  @override
  String get diagnosticsClearSamples => 'Clear timing samples';

  @override
  String get liveSceneAnalyze => 'Analyze scene';

  @override
  String get liveSceneAnalyzing => 'Analyzing scene...';

  @override
  String get liveSceneAnalyzingOverlay =>
      'Analyzing scene — hold the camera steady';

  @override
  String get liveSceneAnalyzingHint =>
      'Usually takes 1–3 seconds. Overlays apply when done.';

  @override
  String get liveSceneAutoAnalyzing =>
      'View stabilized — analyzing scene automatically';

  @override
  String get liveSceneAnalysisReady =>
      'Shooting advice applied — adjust framing using the tips';

  @override
  String get liveSceneRetryAction => 'Retry';

  @override
  String get liveSceneAnalyzeFailedHint =>
      'Check lighting and aim at your subject, then try again.';

  @override
  String get liveSceneCameraBusyHint =>
      'Wait until the timer, burst, or capture finishes, then tap Analyze Scene.';

  @override
  String get liveSceneCoachTitle => 'Scene analysis';

  @override
  String get liveSceneCoachHint =>
      'Tap Analyze Scene in the upper-right corner for composition guidance.';

  @override
  String get liveSceneCoachDismiss => 'OK';

  @override
  String get liveSceneAdviceTitle => 'Shooting guidance';

  @override
  String liveSceneMatchedReference(String title) {
    return 'Reference style: $title';
  }

  @override
  String get liveSceneAnalyzeFailed =>
      'Could not analyze the current scene. Try again.';

  @override
  String get liveSceneCameraBusy =>
      'Camera is busy (timer/burst/capture). Try again shortly.';

  @override
  String get liveSceneCameraNotReady => 'Camera is not ready yet.';

  @override
  String get liveSceneReanalyze => 'Analyze again';

  @override
  String liveSceneOverlayApplied(String overlay) {
    return 'Composition overlay: $overlay';
  }

  @override
  String liveSceneMlSummary(String source, String score) {
    return '$source · aesthetic $score';
  }

  @override
  String get exifSectionTitle => 'Camera EXIF';

  @override
  String exifIso(int value) {
    return 'ISO $value';
  }

  @override
  String exifShutter(String value) {
    return 'Shutter $value';
  }

  @override
  String exifAperture(String value) {
    return 'Aperture f/$value';
  }

  @override
  String exifFocalLength(String value) {
    return 'Focal length $value mm';
  }

  @override
  String get exifCameraModel => 'Camera';

  @override
  String get exifNotAvailable =>
      'No EXIF data (common for screenshots or re-saved images)';

  @override
  String get subjectDetectionFailedTitle => 'Person not detected';

  @override
  String get subjectDetectionFailedBody =>
      'No face or body pose found. Use a clearer portrait with the subject centered, then try again.';

  @override
  String get skeletonStudioTitle => 'Skeleton studio';

  @override
  String get skeletonViewOverlay => 'Overlay photo';

  @override
  String get skeletonViewOnly => 'Skeleton only';

  @override
  String get skeletonStrokeWidthLabel => 'Line thickness';

  @override
  String get skeletonExportPng => 'Export PNG to gallery';

  @override
  String get skeletonExporting => 'Exporting…';

  @override
  String get skeletonExportSuccess => 'Skeleton saved to gallery';

  @override
  String get skeletonExportFailed =>
      'Export failed — check gallery permissions and try again';
}
