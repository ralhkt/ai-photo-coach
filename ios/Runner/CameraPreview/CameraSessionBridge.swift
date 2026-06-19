import AVFoundation
import Foundation

/// Shares the Flutter camera plugin's active `AVCaptureSession` with native preview layers.
enum CameraSessionBridge {
  static let sessionReady = Notification.Name("AIPhotoCoachCaptureSessionReady")
  static let sessionClosed = Notification.Name("AIPhotoCoachCaptureSessionClosed")

  private static let lock = NSLock()
  private static weak var _session: AVCaptureSession?

  static var session: AVCaptureSession? {
    lock.lock()
    defer { lock.unlock() }
    return _session
  }

  static func handleSessionReady(_ notification: Notification) {
    lock.lock()
    _session = notification.object as? AVCaptureSession
    lock.unlock()
  }

  static func handleSessionClosed(_ notification: Notification) {
    lock.lock()
    _session = nil
    lock.unlock()
  }

  static func startObserving() {
    NotificationCenter.default.addObserver(
      forName: sessionReady,
      object: nil,
      queue: nil
    ) { notification in
      handleSessionReady(notification)
    }

    NotificationCenter.default.addObserver(
      forName: sessionClosed,
      object: nil,
      queue: nil
    ) { _ in
      handleSessionClosed(Notification(name: sessionClosed))
    }
  }
}