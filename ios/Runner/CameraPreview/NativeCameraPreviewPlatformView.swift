import Flutter
import UIKit

final class NativeCameraPreviewPlatformView: NSObject, FlutterPlatformView {
  private let previewView: NativeCameraPreviewView

  init(frame: CGRect, arguments: [String: Any]?) {
    previewView = NativeCameraPreviewView(frame: frame)
    super.init()
    apply(arguments)
  }

  func view() -> UIView {
    previewView
  }

  func update(arguments: [String: Any]?) {
    apply(arguments)
  }

  private func apply(_ arguments: [String: Any]?) {
    let mirrorFront = arguments?["mirrorFront"] as? Bool ?? true
    let lensDirection = arguments?["lensDirection"] as? String ?? "back"
    previewView.updateSettings(
      mirrorFront: mirrorFront,
      isFrontCamera: lensDirection == "front"
    )
  }
}

final class NativeCameraPreviewPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  private weak var handler: NativeCameraPreviewHandler?

  init(handler: NativeCameraPreviewHandler) {
    self.handler = handler
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let params = args as? [String: Any]
    let view = NativeCameraPreviewPlatformView(frame: frame, arguments: params)
    handler?.registerPreview(viewId: viewId, view: view)
    return view
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}