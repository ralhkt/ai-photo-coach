import Flutter
import UIKit

@available(iOS 15.0, *)
final class PoseSilhouettePlatformView: NSObject, FlutterPlatformView {
  private let overlayView = SilhouetteOverlayView(frame: .zero)

  init(frame: CGRect) {
    super.init()
    overlayView.frame = frame
  }

  func view() -> UIView {
    overlayView
  }

  func updateContour(points: [CGPoint], phase: String, exposureBias: Float) {
    overlayView.update(points: points, phase: phase, exposureBias: exposureBias)
  }
}

@available(iOS 15.0, *)
final class PoseSilhouettePlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  private weak var handler: PoseSilhouetteHandler?

  init(handler: PoseSilhouetteHandler) {
    self.handler = handler
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let view = PoseSilhouettePlatformView(frame: frame)
    handler?.registerOverlay(viewId: viewId, view: view)
    return view
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}