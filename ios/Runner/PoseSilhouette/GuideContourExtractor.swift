import CoreImage
import UIKit
import Vision

enum GuideContourExtractor {
  static var isSupported: Bool {
    if #available(iOS 15.0, *) {
      return true
    }
    return false
  }

  static func extractNormalizedContour(
    from imageData: Data,
    rdpEpsilon: Float = 0.004,
    outputPoints: Int = 56
  ) -> [[String: Double]]? {
    guard #available(iOS 15.0, *) else {
      return nil
    }
    guard let image = UIImage(data: imageData),
          let cgImage = image.cgImage else {
      return nil
    }
    return extractNormalizedContour(
      from: cgImage,
      rdpEpsilon: rdpEpsilon,
      outputPoints: outputPoints
    )
  }

  @available(iOS 15.0, *)
  static func extractNormalizedContour(
    from cgImage: CGImage,
    rdpEpsilon: Float = 0.004,
    outputPoints: Int = 56
  ) -> [[String: Double]]? {
    let request = VNGeneratePersonSegmentationRequest()
    request.qualityLevel = .accurate
    request.outputPixelFormat = kCVPixelFormatType_OneComponent8

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
      try handler.perform([request])
    } catch {
      return nil
    }

    guard let maskBuffer = request.results?.first?.pixelBuffer else {
      return nil
    }

    let maskWidth = CVPixelBufferGetWidth(maskBuffer)
    let maskHeight = CVPixelBufferGetHeight(maskBuffer)
    guard maskWidth > 0, maskHeight > 0 else {
      return nil
    }

    guard let contour = contourFromMask(
      maskBuffer,
      rdpEpsilon: rdpEpsilon,
      outputPoints: outputPoints
    ) else {
      return nil
    }

    let width = CGFloat(maskWidth)
    let height = CGFloat(maskHeight)
    return contour.map { point in
      [
        "dx": Double(point.x / width),
        "dy": Double(point.y / height),
      ]
    }
  }

  @available(iOS 15.0, *)
  static func contourFromMask(
    _ pixelBuffer: CVPixelBuffer,
    rdpEpsilon: Float,
    outputPoints: Int
  ) -> [CGPoint]? {
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else {
      return nil
    }

    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    var floatMask = [Float](repeating: 0, count: width * height)
    let raw = base.assumingMemoryBound(to: UInt8.self)

    for y in 0..<height {
      for x in 0..<width {
        let value = raw[y * bytesPerRow + x]
        floatMask[y * width + x] = Float(value) / 255.0
      }
    }

    let values: [NSValue]? = floatMask.withUnsafeMutableBufferPointer { buffer in
      guard let base = buffer.baseAddress else {
        return nil
      }
      return ContourProcessorBridge.contour(
        fromMask: base,
        width: Int32(width),
        height: Int32(height),
        threshold: 0.5,
        rdpEpsilon: rdpEpsilon,
        outputPoints: Int32(outputPoints)
      )
    }
    guard let values else {
      return nil
    }

    return values.map { $0.cgPointValue }
  }
}