import Flutter
import UIKit

final class NativeCameraPreviewHandler: NSObject {
  static let platformViewType = "com.aiphotocoach.app/native_camera_preview"

  private var previews: [Int64: NativeCameraPreviewPlatformView] = [:]

  func register(binaryMessenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
    CameraSessionBridge.startObserving()

    let methodChannel = FlutterMethodChannel(
      name: "com.aiphotocoach.app/native_camera_preview",
      binaryMessenger: binaryMessenger
    )
    methodChannel.setMethodCallHandler(handle)

    registrar.register(
      NativeCameraPreviewPlatformViewFactory(handler: self),
      withId: Self.platformViewType
    )
  }

  func registerPreview(viewId: Int64, view: NativeCameraPreviewPlatformView) {
    previews[viewId] = view
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      result(true)
    case "updateSettings":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "bad_args", message: "args required", details: nil))
        return
      }
      for preview in previews.values {
        preview.update(arguments: args)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}