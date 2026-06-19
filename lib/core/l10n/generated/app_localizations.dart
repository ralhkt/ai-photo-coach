import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Photographer'**
  String get appTitle;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to use this app.'**
  String get cameraPermissionRequired;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @noCameraFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get noCameraFound;

  /// No description provided for @initializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get initializingCamera;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Failed to start camera.'**
  String get cameraError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @overlayRuleOfThirds.
  ///
  /// In en, this message translates to:
  /// **'Rule of Thirds'**
  String get overlayRuleOfThirds;

  /// No description provided for @overlayGoldenRatio.
  ///
  /// In en, this message translates to:
  /// **'Golden Ratio'**
  String get overlayGoldenRatio;

  /// No description provided for @overlayCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get overlayCenter;

  /// No description provided for @overlayDiagonal.
  ///
  /// In en, this message translates to:
  /// **'Diagonal'**
  String get overlayDiagonal;

  /// No description provided for @overlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Composition'**
  String get overlayLabel;

  /// No description provided for @toggleOverlay.
  ///
  /// In en, this message translates to:
  /// **'Toggle overlay'**
  String get toggleOverlay;

  /// No description provided for @cycleOverlay.
  ///
  /// In en, this message translates to:
  /// **'Cycle overlay'**
  String get cycleOverlay;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a reference. Get guidance. Take the shot.'**
  String get homeSubtitle;

  /// No description provided for @homeHeadlineContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue guided shoot'**
  String get homeHeadlineContinue;

  /// No description provided for @homeHeadlineStart.
  ///
  /// In en, this message translates to:
  /// **'Start guided shoot'**
  String get homeHeadlineStart;

  /// No description provided for @homeSectionStartNew.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get homeSectionStartNew;

  /// No description provided for @homeSectionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get homeSectionGetStarted;

  /// No description provided for @homeEnterGuidedCamera.
  ///
  /// In en, this message translates to:
  /// **'Enter guided camera'**
  String get homeEnterGuidedCamera;

  /// No description provided for @poseCoachAligning.
  ///
  /// In en, this message translates to:
  /// **'Align your body to the outline.'**
  String get poseCoachAligning;

  /// No description provided for @poseCoachMatched.
  ///
  /// In en, this message translates to:
  /// **'Pose aligned. Ready to shoot.'**
  String get poseCoachMatched;

  /// No description provided for @poseCoachAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust position to align your face.'**
  String get poseCoachAdjust;

  /// No description provided for @alignmentToastNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Step into the center of the outline'**
  String get alignmentToastNoMatch;

  /// No description provided for @alignmentToastAligning.
  ///
  /// In en, this message translates to:
  /// **'Aligning limbs… fit your body to the outline'**
  String get alignmentToastAligning;

  /// No description provided for @alignmentToastMatched.
  ///
  /// In en, this message translates to:
  /// **'Perfect alignment! Ready to shoot'**
  String get alignmentToastMatched;

  /// No description provided for @openCameraSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip guidance'**
  String get openCameraSkipTitle;

  /// No description provided for @openCameraSkipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free shoot without pose guidance.'**
  String get openCameraSkipSubtitle;

  /// No description provided for @homeWorkflowLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference → Analyze → Shoot'**
  String get homeWorkflowLabel;

  /// No description provided for @homeFlowStepReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get homeFlowStepReference;

  /// No description provided for @homeFlowStepAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get homeFlowStepAnalyze;

  /// No description provided for @homeFlowStepShoot.
  ///
  /// In en, this message translates to:
  /// **'Shoot'**
  String get homeFlowStepShoot;

  /// No description provided for @homeContinueGuided.
  ///
  /// In en, this message translates to:
  /// **'Continue guided shoot'**
  String get homeContinueGuided;

  /// No description provided for @homeContinueGuidedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reference analyzed. Open the camera to continue.'**
  String get homeContinueGuidedSubtitle;

  /// No description provided for @analysisExpandDetails.
  ///
  /// In en, this message translates to:
  /// **'Show full analysis'**
  String get analysisExpandDetails;

  /// No description provided for @analysisCollapseDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get analysisCollapseDetails;

  /// No description provided for @guidedOverlayTools.
  ///
  /// In en, this message translates to:
  /// **'Overlays'**
  String get guidedOverlayTools;

  /// No description provided for @uploadReferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Example Photo'**
  String get uploadReferenceTitle;

  /// No description provided for @uploadReferenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use a built-in sample or choose from your library.'**
  String get uploadReferenceSubtitle;

  /// No description provided for @openCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCameraTitle;

  /// No description provided for @openCameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free shoot with live scene analysis.'**
  String get openCameraSubtitle;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get pickFromGallery;

  /// No description provided for @pickFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Reference Photo'**
  String get pickFromCamera;

  /// No description provided for @uploadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a sample or upload your own photo.'**
  String get uploadPrompt;

  /// No description provided for @referenceSamplesSection.
  ///
  /// In en, this message translates to:
  /// **'Sample photos'**
  String get referenceSamplesSection;

  /// No description provided for @uploadOwnPhotoSection.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo'**
  String get uploadOwnPhotoSection;

  /// No description provided for @referenceSampleCheckinCafe.
  ///
  /// In en, this message translates to:
  /// **'Café selfie'**
  String get referenceSampleCheckinCafe;

  /// No description provided for @referenceSampleCheckinCafeHint.
  ///
  /// In en, this message translates to:
  /// **'Warm pendant lamp, standing pose'**
  String get referenceSampleCheckinCafeHint;

  /// No description provided for @referenceSampleCheckinNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon street'**
  String get referenceSampleCheckinNeon;

  /// No description provided for @referenceSampleCheckinNeonHint.
  ///
  /// In en, this message translates to:
  /// **'Night side light, sign glow'**
  String get referenceSampleCheckinNeonHint;

  /// No description provided for @referenceSampleCheckinPortrait.
  ///
  /// In en, this message translates to:
  /// **'Mirror OOTD'**
  String get referenceSampleCheckinPortrait;

  /// No description provided for @referenceSampleCheckinPortraitHint.
  ///
  /// In en, this message translates to:
  /// **'Full-length mirror, fitting room'**
  String get referenceSampleCheckinPortraitHint;

  /// No description provided for @referenceSampleCheckinBrunch.
  ///
  /// In en, this message translates to:
  /// **'Window seat'**
  String get referenceSampleCheckinBrunch;

  /// No description provided for @referenceSampleCheckinBrunchHint.
  ///
  /// In en, this message translates to:
  /// **'Soft side light, seated pose'**
  String get referenceSampleCheckinBrunchHint;

  /// No description provided for @referenceSampleCheckinTravel.
  ///
  /// In en, this message translates to:
  /// **'Summit view'**
  String get referenceSampleCheckinTravel;

  /// No description provided for @referenceSampleCheckinTravelHint.
  ///
  /// In en, this message translates to:
  /// **'Small figure, hiking back view'**
  String get referenceSampleCheckinTravelHint;

  /// No description provided for @referenceSampleCheckinBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach sunset'**
  String get referenceSampleCheckinBeach;

  /// No description provided for @referenceSampleCheckinBeachHint.
  ///
  /// In en, this message translates to:
  /// **'Back silhouette, rocky shore'**
  String get referenceSampleCheckinBeachHint;

  /// No description provided for @analyzingImage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image...'**
  String get analyzingImage;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Image analysis failed. Please try another photo.'**
  String get analysisFailed;

  /// No description provided for @analysisResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get analysisResultTitle;

  /// No description provided for @detectedScene.
  ///
  /// In en, this message translates to:
  /// **'Detected scene: {scene}'**
  String detectedScene(String scene);

  /// No description provided for @recommendedFrame.
  ///
  /// In en, this message translates to:
  /// **'Recommended frame'**
  String get recommendedFrame;

  /// No description provided for @recommendedComposition.
  ///
  /// In en, this message translates to:
  /// **'Composition'**
  String get recommendedComposition;

  /// No description provided for @framingGuidance.
  ///
  /// In en, this message translates to:
  /// **'Framing'**
  String get framingGuidance;

  /// No description provided for @exposureGuidance.
  ///
  /// In en, this message translates to:
  /// **'Exposure'**
  String get exposureGuidance;

  /// No description provided for @distanceGuidance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceGuidance;

  /// No description provided for @angleGuidance.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get angleGuidance;

  /// No description provided for @chooseFrameTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose post frame'**
  String get chooseFrameTemplate;

  /// No description provided for @startGuidedShoot.
  ///
  /// In en, this message translates to:
  /// **'Start Guided Shoot'**
  String get startGuidedShoot;

  /// No description provided for @guidedShootTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided Shoot'**
  String get guidedShootTitle;

  /// No description provided for @noReferenceLoaded.
  ///
  /// In en, this message translates to:
  /// **'No reference analysis loaded.'**
  String get noReferenceLoaded;

  /// No description provided for @toggleFrame.
  ///
  /// In en, this message translates to:
  /// **'Toggle frame'**
  String get toggleFrame;

  /// No description provided for @cycleFrame.
  ///
  /// In en, this message translates to:
  /// **'Cycle frame'**
  String get cycleFrame;

  /// No description provided for @framePortraitPost.
  ///
  /// In en, this message translates to:
  /// **'Portrait Post (4:5)'**
  String get framePortraitPost;

  /// No description provided for @frameStory.
  ///
  /// In en, this message translates to:
  /// **'Story (9:16)'**
  String get frameStory;

  /// No description provided for @frameSquarePost.
  ///
  /// In en, this message translates to:
  /// **'Square Post (1:1)'**
  String get frameSquarePost;

  /// No description provided for @frameLandscapePost.
  ///
  /// In en, this message translates to:
  /// **'Landscape (16:9)'**
  String get frameLandscapePost;

  /// No description provided for @frameClassicPortrait.
  ///
  /// In en, this message translates to:
  /// **'Classic Portrait (3:4)'**
  String get frameClassicPortrait;

  /// No description provided for @scenePortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get scenePortrait;

  /// No description provided for @sceneLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get sceneLandscape;

  /// No description provided for @sceneSquare.
  ///
  /// In en, this message translates to:
  /// **'Square social post'**
  String get sceneSquare;

  /// No description provided for @sceneLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get sceneLifestyle;

  /// No description provided for @hintFramingLeft.
  ///
  /// In en, this message translates to:
  /// **'Place subject on the left third'**
  String get hintFramingLeft;

  /// No description provided for @hintFramingRight.
  ///
  /// In en, this message translates to:
  /// **'Place subject on the right third'**
  String get hintFramingRight;

  /// No description provided for @hintFramingHigh.
  ///
  /// In en, this message translates to:
  /// **'Keep subject in the upper area of the frame'**
  String get hintFramingHigh;

  /// No description provided for @hintFramingLow.
  ///
  /// In en, this message translates to:
  /// **'Keep subject in the lower area of the frame'**
  String get hintFramingLow;

  /// No description provided for @hintFramingCenter.
  ///
  /// In en, this message translates to:
  /// **'Center the subject in the frame'**
  String get hintFramingCenter;

  /// No description provided for @hintExposureBrighten.
  ///
  /// In en, this message translates to:
  /// **'Increase exposure slightly (+EV)'**
  String get hintExposureBrighten;

  /// No description provided for @hintExposureDarken.
  ///
  /// In en, this message translates to:
  /// **'Decrease exposure slightly (-EV)'**
  String get hintExposureDarken;

  /// No description provided for @hintExposureBalanced.
  ///
  /// In en, this message translates to:
  /// **'Exposure looks balanced'**
  String get hintExposureBalanced;

  /// No description provided for @hintDistanceCloser.
  ///
  /// In en, this message translates to:
  /// **'Move closer to match subject size'**
  String get hintDistanceCloser;

  /// No description provided for @hintDistanceFurther.
  ///
  /// In en, this message translates to:
  /// **'Step back for more headroom'**
  String get hintDistanceFurther;

  /// No description provided for @hintDistanceGood.
  ///
  /// In en, this message translates to:
  /// **'Distance looks good'**
  String get hintDistanceGood;

  /// No description provided for @hintAngleLower.
  ///
  /// In en, this message translates to:
  /// **'Lower angle about 8-12°'**
  String get hintAngleLower;

  /// No description provided for @hintAngleHigher.
  ///
  /// In en, this message translates to:
  /// **'Raise angle about 8-12°'**
  String get hintAngleHigher;

  /// No description provided for @hintAngleLevel.
  ///
  /// In en, this message translates to:
  /// **'Keep camera level'**
  String get hintAngleLevel;

  /// No description provided for @cameraModePhoto.
  ///
  /// In en, this message translates to:
  /// **'PHOTO'**
  String get cameraModePhoto;

  /// No description provided for @cameraModeVideo.
  ///
  /// In en, this message translates to:
  /// **'VIDEO'**
  String get cameraModeVideo;

  /// No description provided for @cameraModeGuided.
  ///
  /// In en, this message translates to:
  /// **'GUIDED'**
  String get cameraModeGuided;

  /// No description provided for @cameraModeVideoComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Video recording is coming soon'**
  String get cameraModeVideoComingSoon;

  /// No description provided for @cameraFormatJpeg.
  ///
  /// In en, this message translates to:
  /// **'JPEG'**
  String get cameraFormatJpeg;

  /// No description provided for @cameraFormatMegapixel.
  ///
  /// In en, this message translates to:
  /// **'24'**
  String get cameraFormatMegapixel;

  /// No description provided for @cameraModeSwitchNeedReference.
  ///
  /// In en, this message translates to:
  /// **'Upload and analyze a reference photo before using guided mode.'**
  String get cameraModeSwitchNeedReference;

  /// No description provided for @cameraModeUploadReference.
  ///
  /// In en, this message translates to:
  /// **'Upload reference'**
  String get cameraModeUploadReference;

  /// No description provided for @cameraModeSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe or tap to switch between Photo and Guided mode'**
  String get cameraModeSwipeHint;

  /// No description provided for @cameraModeCoachGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get cameraModeCoachGotIt;

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture photo.'**
  String get captureFailed;

  /// No description provided for @photoPreview.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoPreview;

  /// No description provided for @galleryPreview.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryPreview;

  /// No description provided for @keepShooting.
  ///
  /// In en, this message translates to:
  /// **'Keep Shooting'**
  String get keepShooting;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Photos'**
  String get saveToGallery;

  /// No description provided for @photoSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to Photos'**
  String get photoSavedToGallery;

  /// No description provided for @photoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save — allow Photos access in Settings and try again'**
  String get photoSaveFailed;

  /// No description provided for @savingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingPhoto;

  /// No description provided for @openGallery.
  ///
  /// In en, this message translates to:
  /// **'Open Gallery'**
  String get openGallery;

  /// No description provided for @hdrLabel.
  ///
  /// In en, this message translates to:
  /// **'HDR'**
  String get hdrLabel;

  /// No description provided for @hdrComingSoon.
  ///
  /// In en, this message translates to:
  /// **'HDR capture is not available yet on this device.'**
  String get hdrComingSoon;

  /// No description provided for @exposureLock.
  ///
  /// In en, this message translates to:
  /// **'AE/AF Lock'**
  String get exposureLock;

  /// No description provided for @timerOff.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerOff;

  /// No description provided for @timer3s.
  ///
  /// In en, this message translates to:
  /// **'3s'**
  String get timer3s;

  /// No description provided for @timer10s.
  ///
  /// In en, this message translates to:
  /// **'10s'**
  String get timer10s;

  /// No description provided for @aeAfLocked.
  ///
  /// In en, this message translates to:
  /// **'AE/AF LOCK'**
  String get aeAfLocked;

  /// No description provided for @burstCapturing.
  ///
  /// In en, this message translates to:
  /// **'Burst · {count}'**
  String burstCapturing(int count);

  /// No description provided for @burstReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Burst {current} of {total}'**
  String burstReviewTitle(int current, int total);

  /// No description provided for @burstHint.
  ///
  /// In en, this message translates to:
  /// **'Hold shutter for burst mode'**
  String get burstHint;

  /// No description provided for @arPlaneDetected.
  ///
  /// In en, this message translates to:
  /// **'Plane ×{count}'**
  String arPlaneDetected(int count);

  /// No description provided for @arPlaneSearching.
  ///
  /// In en, this message translates to:
  /// **'Finding plane'**
  String get arPlaneSearching;

  /// No description provided for @arUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AR unavailable'**
  String get arUnavailable;

  /// No description provided for @arUnsupported.
  ///
  /// In en, this message translates to:
  /// **'AR unsupported'**
  String get arUnsupported;

  /// No description provided for @sceneStable.
  ///
  /// In en, this message translates to:
  /// **'Scene locked'**
  String get sceneStable;

  /// No description provided for @sceneChanged.
  ///
  /// In en, this message translates to:
  /// **'Scene changed'**
  String get sceneChanged;

  /// No description provided for @sceneMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Watching scene'**
  String get sceneMonitoring;

  /// No description provided for @sceneIdle.
  ///
  /// In en, this message translates to:
  /// **'Scene idle'**
  String get sceneIdle;

  /// No description provided for @selectSceneType.
  ///
  /// In en, this message translates to:
  /// **'What is in this photo?'**
  String get selectSceneType;

  /// No description provided for @selectSceneTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Choosing a scene helps the analyzer focus on the right subject and framing.'**
  String get selectSceneTypeHint;

  /// No description provided for @sceneTypeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto detect'**
  String get sceneTypeAuto;

  /// No description provided for @sceneTypePortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get sceneTypePortrait;

  /// No description provided for @sceneTypeLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get sceneTypeLandscape;

  /// No description provided for @sceneTypeLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get sceneTypeLifestyle;

  /// No description provided for @sceneTypeSquare.
  ///
  /// In en, this message translates to:
  /// **'Square post'**
  String get sceneTypeSquare;

  /// No description provided for @sceneTypeGroup.
  ///
  /// In en, this message translates to:
  /// **'Group photo'**
  String get sceneTypeGroup;

  /// No description provided for @sceneTypeProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get sceneTypeProduct;

  /// No description provided for @userSelectedScene.
  ///
  /// In en, this message translates to:
  /// **'Your scene choice'**
  String get userSelectedScene;

  /// No description provided for @analysisDetectedSceneLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected scene'**
  String get analysisDetectedSceneLabel;

  /// No description provided for @subjectShapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Subject frame'**
  String get subjectShapeTitle;

  /// No description provided for @subjectShapeHuman.
  ///
  /// In en, this message translates to:
  /// **'Human silhouette (from reference)'**
  String get subjectShapeHuman;

  /// No description provided for @basicGuidanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera guidance'**
  String get basicGuidanceTitle;

  /// No description provided for @deepAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep analysis'**
  String get deepAnalysisTitle;

  /// No description provided for @deepAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-device lighting, composition and mood breakdown'**
  String get deepAnalysisSubtitle;

  /// No description provided for @insightColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Color tone'**
  String get insightColorTitle;

  /// No description provided for @insightLightingTitle.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get insightLightingTitle;

  /// No description provided for @insightBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Composition balance'**
  String get insightBalanceTitle;

  /// No description provided for @insightMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get insightMoodTitle;

  /// No description provided for @insightDepthTitle.
  ///
  /// In en, this message translates to:
  /// **'Depth of field'**
  String get insightDepthTitle;

  /// No description provided for @insightConfidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get insightConfidenceTitle;

  /// No description provided for @insightConfidenceValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String insightConfidenceValue(int percent);

  /// No description provided for @insightDetailedTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed tips'**
  String get insightDetailedTipsTitle;

  /// No description provided for @aiAgentNote.
  ///
  /// In en, this message translates to:
  /// **'This MVP uses on-device analysis. For richer feedback (pose, styling, story), a cloud vision AI agent can be plugged in later via PhotoAnalysisAgent.'**
  String get aiAgentNote;

  /// No description provided for @aiAgentNoteMl.
  ///
  /// In en, this message translates to:
  /// **'Phase 3 ML Kit runs fully on-device (face, pose, scene labels). No cloud API is used.'**
  String get aiAgentNoteMl;

  /// No description provided for @mlAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'On-device ML'**
  String get mlAnalysisTitle;

  /// No description provided for @mlSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Analysis source'**
  String get mlSourceLabel;

  /// No description provided for @mlFaceCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Face detection'**
  String get mlFaceCountLabel;

  /// No description provided for @mlPerformanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get mlPerformanceLabel;

  /// No description provided for @mlFaceDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} face(s) detected'**
  String mlFaceDetected(int count);

  /// No description provided for @mlPoseDetected.
  ///
  /// In en, this message translates to:
  /// **'Body pose detected'**
  String get mlPoseDetected;

  /// No description provided for @mlInferenceMs.
  ///
  /// In en, this message translates to:
  /// **'Inference {ms} ms'**
  String mlInferenceMs(int ms);

  /// No description provided for @mlAestheticScore.
  ///
  /// In en, this message translates to:
  /// **'Aesthetic score {score}'**
  String mlAestheticScore(String score);

  /// No description provided for @mlAnalysisSourceMlKit.
  ///
  /// In en, this message translates to:
  /// **'ML Kit (on-device)'**
  String get mlAnalysisSourceMlKit;

  /// No description provided for @mlAnalysisSourceGemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini Vision'**
  String get mlAnalysisSourceGemini;

  /// No description provided for @mlAnalysisSourceOpenRouter.
  ///
  /// In en, this message translates to:
  /// **'OpenRouter (Gemini)'**
  String get mlAnalysisSourceOpenRouter;

  /// No description provided for @mlAnalysisSourceFallback.
  ///
  /// In en, this message translates to:
  /// **'Heuristic fallback'**
  String get mlAnalysisSourceFallback;

  /// No description provided for @referenceMatchTip.
  ///
  /// In en, this message translates to:
  /// **'Matched a similar reference style — adjust pose and framing using the overlay.'**
  String get referenceMatchTip;

  /// No description provided for @mlTipFaceDetected.
  ///
  /// In en, this message translates to:
  /// **'ML detected a face — framing aligned to facial bounds'**
  String get mlTipFaceDetected;

  /// No description provided for @mlTipPoseDetected.
  ///
  /// In en, this message translates to:
  /// **'ML detected body pose — head/shoulder/torso guides refined'**
  String get mlTipPoseDetected;

  /// No description provided for @mlTipHighAesthetic.
  ///
  /// In en, this message translates to:
  /// **'ML labels suggest strong visual appeal in this reference'**
  String get mlTipHighAesthetic;

  /// No description provided for @insightColorWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm tones'**
  String get insightColorWarm;

  /// No description provided for @insightColorCool.
  ///
  /// In en, this message translates to:
  /// **'Cool tones'**
  String get insightColorCool;

  /// No description provided for @insightColorNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral tones'**
  String get insightColorNeutral;

  /// No description provided for @insightLightingTop.
  ///
  /// In en, this message translates to:
  /// **'Top-lit scene'**
  String get insightLightingTop;

  /// No description provided for @insightLightingBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom-weighted light'**
  String get insightLightingBottom;

  /// No description provided for @insightLightingBacklit.
  ///
  /// In en, this message translates to:
  /// **'Backlit — add fill light'**
  String get insightLightingBacklit;

  /// No description provided for @insightLightingEven.
  ///
  /// In en, this message translates to:
  /// **'Even lighting'**
  String get insightLightingEven;

  /// No description provided for @insightBalanceCentered.
  ///
  /// In en, this message translates to:
  /// **'Centered composition'**
  String get insightBalanceCentered;

  /// No description provided for @insightBalanceLeft.
  ///
  /// In en, this message translates to:
  /// **'Subject weighted left'**
  String get insightBalanceLeft;

  /// No description provided for @insightBalanceRight.
  ///
  /// In en, this message translates to:
  /// **'Subject weighted right'**
  String get insightBalanceRight;

  /// No description provided for @insightBalanceDynamic.
  ///
  /// In en, this message translates to:
  /// **'Dynamic off-center balance'**
  String get insightBalanceDynamic;

  /// No description provided for @insightMoodDramatic.
  ///
  /// In en, this message translates to:
  /// **'Dramatic mood'**
  String get insightMoodDramatic;

  /// No description provided for @insightMoodBrightWarm.
  ///
  /// In en, this message translates to:
  /// **'Bright & warm'**
  String get insightMoodBrightWarm;

  /// No description provided for @insightMoodSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft & low contrast'**
  String get insightMoodSoft;

  /// No description provided for @insightMoodNatural.
  ///
  /// In en, this message translates to:
  /// **'Natural everyday mood'**
  String get insightMoodNatural;

  /// No description provided for @insightDepthShallow.
  ///
  /// In en, this message translates to:
  /// **'Shallow depth — blurred background likely'**
  String get insightDepthShallow;

  /// No description provided for @insightDepthDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep focus — more background detail'**
  String get insightDepthDeep;

  /// No description provided for @insightDepthModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate depth of field'**
  String get insightDepthModerate;

  /// No description provided for @insightTipPortraitHeadroom.
  ///
  /// In en, this message translates to:
  /// **'Leave headroom above the subject for portrait posts'**
  String get insightTipPortraitHeadroom;

  /// No description provided for @insightTipPortraitCropTight.
  ///
  /// In en, this message translates to:
  /// **'Reference crop is tight — avoid cutting forehead or chin'**
  String get insightTipPortraitCropTight;

  /// No description provided for @insightTipLandscapeHorizon.
  ///
  /// In en, this message translates to:
  /// **'Keep horizon near upper or lower third, not center'**
  String get insightTipLandscapeHorizon;

  /// No description provided for @insightTipLandscapeForeground.
  ///
  /// In en, this message translates to:
  /// **'Include foreground interest for depth'**
  String get insightTipLandscapeForeground;

  /// No description provided for @insightTipProductCleanBg.
  ///
  /// In en, this message translates to:
  /// **'Use a clean background to isolate the product'**
  String get insightTipProductCleanBg;

  /// No description provided for @insightTipRaiseExposure.
  ///
  /// In en, this message translates to:
  /// **'Scene is dark — raise exposure slightly'**
  String get insightTipRaiseExposure;

  /// No description provided for @insightTipLowerExposure.
  ///
  /// In en, this message translates to:
  /// **'Scene is bright — lower exposure to protect highlights'**
  String get insightTipLowerExposure;

  /// No description provided for @insightTipIncreaseContrast.
  ///
  /// In en, this message translates to:
  /// **'Low contrast — add separation between subject and background'**
  String get insightTipIncreaseContrast;

  /// No description provided for @insightTipBacklitFill.
  ///
  /// In en, this message translates to:
  /// **'Backlit subject — use reflector or increase exposure on face'**
  String get insightTipBacklitFill;

  /// No description provided for @insightTipKeepNegativeSpace.
  ///
  /// In en, this message translates to:
  /// **'Preserve negative space on the opposite side of the subject'**
  String get insightTipKeepNegativeSpace;

  /// No description provided for @insightTipWarmSkinTones.
  ///
  /// In en, this message translates to:
  /// **'Cool cast detected — warm white balance for skin'**
  String get insightTipWarmSkinTones;

  /// No description provided for @proMode.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proMode;

  /// No description provided for @aspectRatio4x3.
  ///
  /// In en, this message translates to:
  /// **'4:3'**
  String get aspectRatio4x3;

  /// No description provided for @aspectRatio16x9.
  ///
  /// In en, this message translates to:
  /// **'16:9'**
  String get aspectRatio16x9;

  /// No description provided for @aspectRatio1x1.
  ///
  /// In en, this message translates to:
  /// **'1:1'**
  String get aspectRatio1x1;

  /// No description provided for @aspectRatioFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get aspectRatioFull;

  /// No description provided for @histogram.
  ///
  /// In en, this message translates to:
  /// **'Histogram'**
  String get histogram;

  /// No description provided for @frontMirror.
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get frontMirror;

  /// No description provided for @exposureEvLabel.
  ///
  /// In en, this message translates to:
  /// **'EV {value}'**
  String exposureEvLabel(String value);

  /// No description provided for @bodyPartHead.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get bodyPartHead;

  /// No description provided for @bodyPartShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get bodyPartShoulders;

  /// No description provided for @bodyPartTorso.
  ///
  /// In en, this message translates to:
  /// **'Torso'**
  String get bodyPartTorso;

  /// No description provided for @bodyPartHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get bodyPartHips;

  /// No description provided for @alignmentGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Pose alignment'**
  String get alignmentGuideTitle;

  /// No description provided for @alignmentStepHead.
  ///
  /// In en, this message translates to:
  /// **'1. Place eyes in the yellow head oval'**
  String get alignmentStepHead;

  /// No description provided for @alignmentStepShoulders.
  ///
  /// In en, this message translates to:
  /// **'2. Match shoulder width to cyan frame'**
  String get alignmentStepShoulders;

  /// No description provided for @alignmentStepTorso.
  ///
  /// In en, this message translates to:
  /// **'3. Align torso inside white frame'**
  String get alignmentStepTorso;

  /// No description provided for @alignmentStepHips.
  ///
  /// In en, this message translates to:
  /// **'4. Match hip position to purple frame'**
  String get alignmentStepHips;

  /// No description provided for @toggleGhostOverlay.
  ///
  /// In en, this message translates to:
  /// **'Toggle reference ghost'**
  String get toggleGhostOverlay;

  /// No description provided for @guidedGhostOpacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Ghost opacity'**
  String get guidedGhostOpacityLabel;

  /// No description provided for @guidedGhostOpacityPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String guidedGhostOpacityPercent(int percent);

  /// No description provided for @toggleBodyPartGuides.
  ///
  /// In en, this message translates to:
  /// **'Toggle body-part guides'**
  String get toggleBodyPartGuides;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsGuidanceSection.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get settingsGuidanceSection;

  /// No description provided for @settingsVoiceGuidance.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance'**
  String get settingsVoiceGuidance;

  /// No description provided for @settingsVoiceGuidanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak tips aloud while shooting (snackbar preview)'**
  String get settingsVoiceGuidanceSubtitle;

  /// No description provided for @settingsPromptStrength.
  ///
  /// In en, this message translates to:
  /// **'Prompt strength'**
  String get settingsPromptStrength;

  /// No description provided for @settingsPromptStrengthHint.
  ///
  /// In en, this message translates to:
  /// **'Controls how many hints appear on the camera screen'**
  String get settingsPromptStrengthHint;

  /// No description provided for @promptStrengthLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get promptStrengthLow;

  /// No description provided for @promptStrengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get promptStrengthMedium;

  /// No description provided for @promptStrengthHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get promptStrengthHigh;

  /// No description provided for @localeZhTw.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get localeZhTw;

  /// No description provided for @localeZhCn.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get localeZhCn;

  /// No description provided for @localeEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeEn;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'On-device guidance'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Analysis runs on your device. No connection required.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Live composition aids'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Grids, pose outlines, and exposure hints appear in the viewfinder.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Shoot review'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'See your best shot and suggestions when you finish.'**
  String get onboardingBody3;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'Finish session'**
  String get endSession;

  /// No description provided for @sessionSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get sessionSummaryTitle;

  /// No description provided for @sessionSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how this shoot went'**
  String get sessionSummarySubtitle;

  /// No description provided for @sessionSummaryLoading.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your photos...'**
  String get sessionSummaryLoading;

  /// No description provided for @sessionStatPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get sessionStatPhotos;

  /// No description provided for @sessionStatDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sessionStatDuration;

  /// No description provided for @sessionStatMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get sessionStatMode;

  /// No description provided for @sessionStatAesthetic.
  ///
  /// In en, this message translates to:
  /// **'Avg. aesthetic'**
  String get sessionStatAesthetic;

  /// No description provided for @sessionModeFree.
  ///
  /// In en, this message translates to:
  /// **'Free shoot'**
  String get sessionModeFree;

  /// No description provided for @sessionModeGuided.
  ///
  /// In en, this message translates to:
  /// **'Guided shoot'**
  String get sessionModeGuided;

  /// No description provided for @sessionBestShot.
  ///
  /// In en, this message translates to:
  /// **'Best shot'**
  String get sessionBestShot;

  /// No description provided for @sessionFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for next time'**
  String get sessionFeedbackTitle;

  /// No description provided for @sessionDone.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get sessionDone;

  /// No description provided for @sessionEndDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get sessionEndDialogTitle;

  /// No description provided for @sessionEndDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You have captured photos. View a summary or leave without saving the session.'**
  String get sessionEndDialogBody;

  /// No description provided for @sessionEndDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep shooting'**
  String get sessionEndDialogCancel;

  /// No description provided for @sessionEndDialogDiscard.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get sessionEndDialogDiscard;

  /// No description provided for @sessionEndDialogSummarize.
  ///
  /// In en, this message translates to:
  /// **'View summary'**
  String get sessionEndDialogSummarize;

  /// No description provided for @sessionTipGuidedPractice.
  ///
  /// In en, this message translates to:
  /// **'Great job using guided mode — keep matching the reference frame.'**
  String get sessionTipGuidedPractice;

  /// No description provided for @sessionTipTryGuided.
  ///
  /// In en, this message translates to:
  /// **'Try guided mode with a sample photo for tighter framing.'**
  String get sessionTipTryGuided;

  /// No description provided for @sessionTipStrongComposition.
  ///
  /// In en, this message translates to:
  /// **'Composition looks strong — keep this framing style.'**
  String get sessionTipStrongComposition;

  /// No description provided for @sessionTipImproveLighting.
  ///
  /// In en, this message translates to:
  /// **'Try softer light or adjust exposure for richer tones.'**
  String get sessionTipImproveLighting;

  /// No description provided for @sessionTipRefineFraming.
  ///
  /// In en, this message translates to:
  /// **'Small framing tweaks (headroom, horizon) can lift the shot.'**
  String get sessionTipRefineFraming;

  /// No description provided for @sessionTipTooDark.
  ///
  /// In en, this message translates to:
  /// **'Several shots were underexposed — brighten the scene or raise EV.'**
  String get sessionTipTooDark;

  /// No description provided for @sessionTipTooBright.
  ///
  /// In en, this message translates to:
  /// **'Highlights are clipping — lower exposure slightly.'**
  String get sessionTipTooBright;

  /// No description provided for @sessionTipBalancedExposure.
  ///
  /// In en, this message translates to:
  /// **'Exposure balance looks good across this session.'**
  String get sessionTipBalancedExposure;

  /// No description provided for @sessionTipGreatVolume.
  ///
  /// In en, this message translates to:
  /// **'Nice volume of shots — pick the sharpest expression or pose.'**
  String get sessionTipGreatVolume;

  /// No description provided for @sessionSummaryProgress.
  ///
  /// In en, this message translates to:
  /// **'Analyzing {completed} / {total}'**
  String sessionSummaryProgress(int completed, int total);

  /// No description provided for @sessionStatAnalysisTime.
  ///
  /// In en, this message translates to:
  /// **'Analysis time'**
  String get sessionStatAnalysisTime;

  /// No description provided for @sessionStatAnalysisMs.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String sessionStatAnalysisMs(int ms);

  /// No description provided for @sessionStatBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery used'**
  String get sessionStatBattery;

  /// No description provided for @sessionStatBatteryDelta.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String sessionStatBatteryDelta(int percent);

  /// No description provided for @settingsPerformanceSection.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get settingsPerformanceSection;

  /// No description provided for @settingsAutoLiveSceneAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Auto scene analysis'**
  String get settingsAutoLiveSceneAnalysis;

  /// No description provided for @settingsAutoLiveSceneAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze the scene automatically when the view stabilizes in free shoot mode'**
  String get settingsAutoLiveSceneAnalysisSubtitle;

  /// No description provided for @settingsPowerSave.
  ///
  /// In en, this message translates to:
  /// **'Power save mode'**
  String get settingsPowerSave;

  /// No description provided for @settingsPowerSaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Slower scene checks, skip AR, faster session analysis'**
  String get settingsPowerSaveSubtitle;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Performance diagnostics'**
  String get diagnosticsTitle;

  /// No description provided for @diagnosticsEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Timing samples and battery session stats'**
  String get diagnosticsEntrySubtitle;

  /// No description provided for @diagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-device budgets for MVP targets (ML < 150 ms, 10 min < 7% battery).'**
  String get diagnosticsSubtitle;

  /// No description provided for @diagnosticsMlBudget.
  ///
  /// In en, this message translates to:
  /// **'ML quick inference'**
  String get diagnosticsMlBudget;

  /// No description provided for @diagnosticsSessionPhotoBudget.
  ///
  /// In en, this message translates to:
  /// **'Session photo quick score'**
  String get diagnosticsSessionPhotoBudget;

  /// No description provided for @diagnosticsSessionTotalBudget.
  ///
  /// In en, this message translates to:
  /// **'Session summary total'**
  String get diagnosticsSessionTotalBudget;

  /// No description provided for @diagnosticsBudgetValue.
  ///
  /// In en, this message translates to:
  /// **'avg {avg} ms / {budget} ms (over {count})'**
  String diagnosticsBudgetValue(String avg, String budget, String count);

  /// No description provided for @diagnosticsLastBattery.
  ///
  /// In en, this message translates to:
  /// **'Last camera session battery'**
  String get diagnosticsLastBattery;

  /// No description provided for @diagnosticsBatteryDetail.
  ///
  /// In en, this message translates to:
  /// **'Used {delta}% ({per10}%/10 min) — {status}'**
  String diagnosticsBatteryDetail(int delta, String per10, String status);

  /// No description provided for @diagnosticsWithinBudget.
  ///
  /// In en, this message translates to:
  /// **'within MVP budget'**
  String get diagnosticsWithinBudget;

  /// No description provided for @diagnosticsOverBudget.
  ///
  /// In en, this message translates to:
  /// **'above MVP budget'**
  String get diagnosticsOverBudget;

  /// No description provided for @diagnosticsRunBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Run quick-score benchmark'**
  String get diagnosticsRunBenchmark;

  /// No description provided for @diagnosticsRunningBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Running benchmark...'**
  String get diagnosticsRunningBenchmark;

  /// No description provided for @diagnosticsClearSamples.
  ///
  /// In en, this message translates to:
  /// **'Clear timing samples'**
  String get diagnosticsClearSamples;

  /// No description provided for @liveSceneAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze scene'**
  String get liveSceneAnalyze;

  /// No description provided for @liveSceneAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing scene...'**
  String get liveSceneAnalyzing;

  /// No description provided for @liveSceneAnalyzingOverlay.
  ///
  /// In en, this message translates to:
  /// **'Analyzing scene — hold the camera steady'**
  String get liveSceneAnalyzingOverlay;

  /// No description provided for @liveSceneAnalyzingHint.
  ///
  /// In en, this message translates to:
  /// **'Usually takes 1–3 seconds. Overlays apply when done.'**
  String get liveSceneAnalyzingHint;

  /// No description provided for @liveSceneAutoAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'View stabilized — analyzing scene automatically'**
  String get liveSceneAutoAnalyzing;

  /// No description provided for @liveSceneAnalysisReady.
  ///
  /// In en, this message translates to:
  /// **'Shooting advice applied — adjust framing using the tips'**
  String get liveSceneAnalysisReady;

  /// No description provided for @liveSceneRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get liveSceneRetryAction;

  /// No description provided for @liveSceneAnalyzeFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Check lighting and aim at your subject, then try again.'**
  String get liveSceneAnalyzeFailedHint;

  /// No description provided for @liveSceneCameraBusyHint.
  ///
  /// In en, this message translates to:
  /// **'Wait until the timer, burst, or capture finishes, then tap Analyze Scene.'**
  String get liveSceneCameraBusyHint;

  /// No description provided for @liveSceneCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'Scene analysis'**
  String get liveSceneCoachTitle;

  /// No description provided for @liveSceneCoachHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Analyze Scene in the upper-right corner for composition guidance.'**
  String get liveSceneCoachHint;

  /// No description provided for @liveSceneCoachDismiss.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get liveSceneCoachDismiss;

  /// No description provided for @liveSceneAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Shooting guidance'**
  String get liveSceneAdviceTitle;

  /// No description provided for @liveSceneMatchedReference.
  ///
  /// In en, this message translates to:
  /// **'Reference style: {title}'**
  String liveSceneMatchedReference(String title);

  /// No description provided for @liveSceneAnalyzeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze the current scene. Try again.'**
  String get liveSceneAnalyzeFailed;

  /// No description provided for @liveSceneCameraBusy.
  ///
  /// In en, this message translates to:
  /// **'Camera is busy (timer/burst/capture). Try again shortly.'**
  String get liveSceneCameraBusy;

  /// No description provided for @liveSceneCameraNotReady.
  ///
  /// In en, this message translates to:
  /// **'Camera is not ready yet.'**
  String get liveSceneCameraNotReady;

  /// No description provided for @liveSceneReanalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze again'**
  String get liveSceneReanalyze;

  /// No description provided for @liveSceneOverlayApplied.
  ///
  /// In en, this message translates to:
  /// **'Composition overlay: {overlay}'**
  String liveSceneOverlayApplied(String overlay);

  /// No description provided for @liveSceneMlSummary.
  ///
  /// In en, this message translates to:
  /// **'{source} · aesthetic {score}'**
  String liveSceneMlSummary(String source, String score);

  /// No description provided for @exifSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera EXIF'**
  String get exifSectionTitle;

  /// No description provided for @exifIso.
  ///
  /// In en, this message translates to:
  /// **'ISO {value}'**
  String exifIso(int value);

  /// No description provided for @exifShutter.
  ///
  /// In en, this message translates to:
  /// **'Shutter {value}'**
  String exifShutter(String value);

  /// No description provided for @exifAperture.
  ///
  /// In en, this message translates to:
  /// **'Aperture f/{value}'**
  String exifAperture(String value);

  /// No description provided for @exifFocalLength.
  ///
  /// In en, this message translates to:
  /// **'Focal length {value} mm'**
  String exifFocalLength(String value);

  /// No description provided for @exifCameraModel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get exifCameraModel;

  /// No description provided for @exifNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No EXIF data (common for screenshots or re-saved images)'**
  String get exifNotAvailable;

  /// No description provided for @subjectDetectionFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Person not detected'**
  String get subjectDetectionFailedTitle;

  /// No description provided for @subjectDetectionFailedBody.
  ///
  /// In en, this message translates to:
  /// **'No face or body pose found. Use a clearer portrait with the subject centered, then try again.'**
  String get subjectDetectionFailedBody;

  /// No description provided for @skeletonStudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Skeleton studio'**
  String get skeletonStudioTitle;

  /// No description provided for @skeletonViewOverlay.
  ///
  /// In en, this message translates to:
  /// **'Overlay photo'**
  String get skeletonViewOverlay;

  /// No description provided for @skeletonViewOnly.
  ///
  /// In en, this message translates to:
  /// **'Skeleton only'**
  String get skeletonViewOnly;

  /// No description provided for @skeletonStrokeWidthLabel.
  ///
  /// In en, this message translates to:
  /// **'Line thickness'**
  String get skeletonStrokeWidthLabel;

  /// No description provided for @skeletonExportPng.
  ///
  /// In en, this message translates to:
  /// **'Export PNG to gallery'**
  String get skeletonExportPng;

  /// No description provided for @skeletonExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get skeletonExporting;

  /// No description provided for @skeletonExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Skeleton saved to gallery'**
  String get skeletonExportSuccess;

  /// No description provided for @skeletonExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed — check gallery permissions and try again'**
  String get skeletonExportFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
