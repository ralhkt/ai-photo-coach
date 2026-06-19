import AVFoundation
import CoreImage
import Flutter
import UIKit

/// Taps the shared [AVCaptureSession] for throttled BGRA frames — no [takePicture].
final class PreviewFrameSamplerHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  static let shared = PreviewFrameSamplerHandler()

  private let queue = DispatchQueue(label: "com.aiphotocoach.preview-sampler", qos: .utility)
  private let ciContext = CIContext(options: [.useSoftwareRenderer: false])
  private var videoOutput: AVCaptureVideoDataOutput?
  private weak var attachedSession: AVCaptureSession?
  private var latestJpeg: Data?
  private var lastSampleTime: CFAbsoluteTime = 0
  private let minSampleInterval: CFAbsoluteTime = 5.0
  private let maxJpegSide: CGFloat = 360

  private var sessionReadyObserver: NSObjectProtocol?
  private var sessionClosedObserver: NSObjectProtocol?

  func register(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.aiphotocoach.app/preview_frame_sampler",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }
      switch call.method {
      case "attach":
        self.attachToSharedSession()
        result(nil)
      case "detach":
        self.detach()
        result(nil)
      case "latestJpeg":
        if let jpeg = self.latestJpeg {
          result(FlutterStandardTypedData(bytes: jpeg))
        } else {
          result(nil)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    sessionReadyObserver = NotificationCenter.default.addObserver(
      forName: CameraSessionBridge.sessionReady,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.attachToSharedSession()
    }

    sessionClosedObserver = NotificationCenter.default.addObserver(
      forName: CameraSessionBridge.sessionClosed,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.detach()
    }
  }

  private func attachToSharedSession() {
    guard let session = CameraSessionBridge.session else {
      return
    }
    if attachedSession === session, videoOutput != nil {
      return
    }

    detach()

    let output = AVCaptureVideoDataOutput()
    output.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
    ]
    output.alwaysDiscardsLateVideoFrames = true
    output.setSampleBufferDelegate(self, queue: queue)

    session.beginConfiguration()
    defer { session.commitConfiguration() }

    guard session.canAddOutput(output) else {
      return
    }

    session.addOutput(output)
    videoOutput = output
    attachedSession = session
  }

  func detach() {
    latestJpeg = nil
    lastSampleTime = 0

    guard let session = attachedSession, let output = videoOutput else {
      videoOutput = nil
      attachedSession = nil
      return
    }

    session.beginConfiguration()
    session.removeOutput(output)
    session.commitConfiguration()

    videoOutput = nil
    attachedSession = nil
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    let now = CFAbsoluteTimeGetCurrent()
    guard now - lastSampleTime >= minSampleInterval else {
      return
    }
    lastSampleTime = now

    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      return
    }

    var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let extent = ciImage.extent
    let longest = max(extent.width, extent.height)
    if longest > maxJpegSide {
      let scale = maxJpegSide / longest
      ciImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let jpeg = ciContext.jpegRepresentation(
      of: ciImage,
      colorSpace: colorSpace,
      options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.72]
    ) else {
      return
    }

    latestJpeg = jpeg
  }
}