import AVFoundation
import UIKit

/// GPU-backed preview matching the native iOS Camera app sharpness.
final class NativeCameraPreviewView: UIView {
  private var sessionReadyObserver: NSObjectProtocol?
  private var sessionClosedObserver: NSObjectProtocol?
  private var mirrorFront = true
  private var isFrontCamera = false

  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }

  private var previewLayer: AVCaptureVideoPreviewLayer {
    layer as! AVCaptureVideoPreviewLayer
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .black
    previewLayer.videoGravity = .resizeAspectFill
    attachSessionIfAvailable()
    sessionReadyObserver = NotificationCenter.default.addObserver(
      forName: CameraSessionBridge.sessionReady,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.attachSessionIfAvailable()
    }
    sessionClosedObserver = NotificationCenter.default.addObserver(
      forName: CameraSessionBridge.sessionClosed,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.detachSession()
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    if let sessionReadyObserver {
      NotificationCenter.default.removeObserver(sessionReadyObserver)
    }
    if let sessionClosedObserver {
      NotificationCenter.default.removeObserver(sessionClosedObserver)
    }
  }

  func updateSettings(mirrorFront: Bool, isFrontCamera: Bool) {
    self.mirrorFront = mirrorFront
    self.isFrontCamera = isFrontCamera
    applyMirroring()
  }

  private func attachSessionIfAvailable() {
    guard let session = CameraSessionBridge.session else {
      return
    }

    if previewLayer.session !== session {
      previewLayer.session = session
    }
    applyMirroring()
  }

  private func detachSession() {
    previewLayer.session = nil
  }

  private func applyMirroring() {
    guard let connection = previewLayer.connection else {
      return
    }

    if connection.isVideoOrientationSupported {
      connection.videoOrientation = .portrait
    }

    guard connection.isVideoMirroringSupported else {
      return
    }

    connection.automaticallyAdjustsVideoMirroring = false
    connection.isVideoMirrored = isFrontCamera && mirrorFront
  }
}