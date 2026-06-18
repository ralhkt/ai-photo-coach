import ARKit
import Flutter

final class ArPlatformHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var session: ARSession?
  private var pollTimer: Timer?

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkSupport":
      result(checkSupport())
    case "startSession":
      startSession()
      result(nil)
    case "stopSession":
      stopSession()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  private func checkSupport() -> [String: Any] {
    let supported = ARWorldTrackingConfiguration.isSupported
    return [
      "isSupported": supported,
      "planeState": supported ? "searching" : "unsupported",
      "horizontalPlanes": 0,
    ]
  }

  private func startSession() {
    stopSession()

    guard ARWorldTrackingConfiguration.isSupported else {
      emitStatus(state: "unsupported", planes: 0)
      return
    }

    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = [.horizontal]
    configuration.isLightEstimationEnabled = false

    let newSession = ARSession()
    newSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    session = newSession
    emitStatus(state: "searching", planes: 0)

    pollTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
      self?.updatePlaneStatus()
    }
  }

  private func stopSession() {
    pollTimer?.invalidate()
    pollTimer = nil
    session?.pause()
    session = nil
    emitStatus(state: "searching", planes: 0)
  }

  private func updatePlaneStatus() {
    guard let frame = session?.currentFrame else {
      emitStatus(state: "searching", planes: 0)
      return
    }

    if frame.camera.trackingState != .normal {
      emitStatus(state: "searching", planes: 0)
      return
    }

    let planes = frame.anchors.compactMap { $0 as? ARPlaneAnchor }
      .filter { $0.alignment == .horizontal }
      .count

    emitStatus(state: planes > 0 ? "detected" : "searching", planes: planes)
  }

  private func emitStatus(state: String, planes: Int) {
    let payload: [String: Any] = [
      "isSupported": ARWorldTrackingConfiguration.isSupported,
      "planeState": state,
      "horizontalPlanes": planes,
    ]
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(payload)
    }
  }
}