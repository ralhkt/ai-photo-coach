import Flutter
import UIKit

final class PoseSilhouetteHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var guideContour: [CGPoint] = []
  private var alignmentScore = 0
  private var enabled = false
  private var overlays: [Int64: AnyObject] = [:]

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
      pushOverlayState()
      result(nil)
    case "setGuideContour":
      guard let args = call.arguments as? [String: Any],
            let rawPoints = args["points"] as? [[String: Double]] else {
        result(FlutterError(code: "bad_args", message: "points required", details: nil))
        return
      }
      guideContour = rawPoints.compactMap { dict in
        guard let dx = dict["dx"], let dy = dict["dy"] else {
          return nil
        }
        return CGPoint(x: dx, y: dy)
      }
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

  private func phaseName(for score: Int) -> String {
    if score >= 85 {
      return "matched"
    }
    if score >= 50 {
      return "aligning"
    }
    return "noMatch"
  }

  private func toast(for phase: String) -> String {
    switch phase {
    case "matched":
      return "完美對齊！可以拍了"
    case "aligning":
      return "肢體對齊中…請將身體套入輪廓"
    default:
      return "請站入輪廓中央"
    }
  }

  private func emitAlignmentEvent() {
    let phase = phaseName(for: alignmentScore)
    let payload: [String: Any] = [
      "score": alignmentScore,
      "phase": phase,
      "toast": toast(for: phase),
      "enabled": enabled,
    ]
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(payload)
    }
  }

  private func pushOverlayState() {
    guard enabled, !guideContour.isEmpty else {
      return
    }
    let phase = phaseName(for: alignmentScore)
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      if #available(iOS 15.0, *) {
        for overlay in self.overlays.values {
          (overlay as? PoseSilhouettePlatformView)?.updateContour(
            points: self.guideContour,
            phase: phase,
            exposureBias: 0
          )
        }
      }
    }
  }
}