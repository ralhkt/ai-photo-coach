import Flutter
import UIKit

final class PoseSilhouetteHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var rawGuideContour: [CGPoint] = []
  private var displayContour: [CGPoint] = []
  private var alignmentScore = 0
  private var enabled = false
  private var renderMode = "silhouette"
  private var skeletonSegments: [[CGPoint]] = []
  private var overlays: [Int64: AnyObject] = [:]
  private let kalmanFilter = KalmanContourFilterBridge()
  private let stateMachine = AlignmentStateMachine()

  func registerChannels(binaryMessenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: "com.aiphotocoach.app/pose_silhouette",
      binaryMessenger: binaryMessenger
    )
    methodChannel.setMethodCallHandler(handle)

    let eventChannel = FlutterEventChannel(
      name: "com.aiphotocoach.app/pose_silhouette_events",
      binaryMessenger: binaryMessenger
    )
    eventChannel.setStreamHandler(self)

    if #available(iOS 15.0, *) {
      registrar.register(
        PoseSilhouettePlatformViewFactory(handler: self),
        withId: "com.aiphotocoach.app/pose_silhouette_view"
      )
    }
  }

  func registerOverlay(viewId: Int64, view: AnyObject) {
    overlays[viewId] = view
    pushOverlayState()
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      result(GuideContourExtractor.isSupported)
    case "setEnabled":
      guard let args = call.arguments as? [String: Any],
            let value = args["enabled"] as? Bool else {
        result(FlutterError(code: "bad_args", message: "enabled required", details: nil))
        return
      }
      enabled = value
      if !enabled {
        stateMachine.reset()
      }
      pushOverlayState()
      result(nil)
    case "setGuideContour":
      guard let args = call.arguments as? [String: Any],
            let rawPoints = args["points"] as? [[String: Double]] else {
        result(FlutterError(code: "bad_args", message: "points required", details: nil))
        return
      }
      rawGuideContour = rawPoints.compactMap { dict in
        guard let dx = dict["dx"], let dy = dict["dy"] else {
          return nil
        }
        return CGPoint(x: dx, y: dy)
      }
      displayContour = smoothContour(rawGuideContour)
      pushOverlayState()
      result(nil)
    case "setAlignmentScore":
      guard let args = call.arguments as? [String: Any],
            let score = args["score"] as? Int else {
        result(FlutterError(code: "bad_args", message: "score required", details: nil))
        return
      }
      alignmentScore = max(0, min(100, score))
      emitAlignmentEvent()
      pushOverlayState()
      result(nil)
    case "setRenderMode":
      guard let args = call.arguments as? [String: Any],
            let mode = args["mode"] as? String else {
        result(FlutterError(code: "bad_args", message: "mode required", details: nil))
        return
      }
      renderMode = mode
      pushOverlayState()
      result(nil)
    case "setSkeletonSegments":
      guard let args = call.arguments as? [String: Any],
            let segments = args["segments"] as? [[[String: Double]]] else {
        result(FlutterError(code: "bad_args", message: "segments required", details: nil))
        return
      }
      skeletonSegments = segments.map { segment in
        segment.compactMap { dict in
          guard let dx = dict["dx"], let dy = dict["dy"] else {
            return nil
          }
          return CGPoint(x: dx, y: dy)
        }
      }.filter { $0.count >= 2 }
      pushOverlayState()
      result(nil)
    case "extractContourFromImage":
      guard let args = call.arguments as? [String: Any],
            let typed = args["bytes"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "bad_args", message: "bytes required", details: nil))
        return
      }
      let points = GuideContourExtractor.extractNormalizedContour(from: typed.data)
      result(points)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    emitAlignmentEvent()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  private func smoothContour(_ points: [CGPoint]) -> [CGPoint] {
    guard points.count >= 2 else {
      return points
    }
    let values = points.map { NSValue(cgPoint: $0) }
    let smoothed = kalmanFilter.smooth(values)
    return smoothed.map { $0.cgPointValue }
  }

  private func emitAlignmentEvent() {
    var payload = stateMachine.update(score: alignmentScore)
    payload["enabled"] = enabled
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(payload)
    }
  }

  private func pushOverlayState() {
    guard enabled else {
      return
    }

    let phase = phaseName(for: alignmentScore)
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      if #available(iOS 15.0, *) {
        for overlay in self.overlays.values {
          (overlay as? PoseSilhouettePlatformView)?.update(
            contour: self.displayContour,
            skeletonSegments: self.skeletonSegments,
            renderMode: self.renderMode,
            phase: phase,
            exposureBias: 0
          )
        }
      }
    }
  }

  private func phaseName(for score: Int) -> String {
    if score >= 85 {
      return "matched"
    }
    if score >= 50 {
      return "aligning"
    }
    return "noMatch"
  }
}