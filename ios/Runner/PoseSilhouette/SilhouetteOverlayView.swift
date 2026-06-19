import UIKit

@available(iOS 15.0, *)
final class SilhouetteOverlayView: UIView {
  private var guideContour: [CGPoint] = []
  private var phase = "noMatch"
  private var exposureBias: Float = 0

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    isOpaque = false
    isUserInteractionEnabled = false
    contentMode = .redraw
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  func update(points: [CGPoint], phase: String, exposureBias: Float) {
    guideContour = points
    self.phase = phase
    self.exposureBias = exposureBias
    setNeedsDisplay()
  }

  override func draw(_ rect: CGRect) {
    guard guideContour.count >= 2 else {
      return
    }

    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }

    let viewport = bounds.size
    let path = UIBezierPath()
    let first = mapPoint(guideContour[0], viewport: viewport)
    path.move(to: first)
    for index in 1..<guideContour.count {
      path.addLine(to: mapPoint(guideContour[index], viewport: viewport))
    }
    path.close()

    let colors = strokeColors(for: phase, exposureBias: exposureBias)
    context.saveGState()
    context.setShadow(
      offset: .zero,
      blur: 8,
      color: colors.glow.withAlphaComponent(0.45).cgColor
    )
    colors.stroke.setStroke()
    path.lineWidth = 1.8
    path.lineJoinStyle = .round
    path.lineCapStyle = .round
    path.stroke()
    context.restoreGState()
  }

  private func mapPoint(_ point: CGPoint, viewport: CGSize) -> CGPoint {
    CGPoint(x: point.x * viewport.width, y: point.y * viewport.height)
  }

  private func strokeColors(for phase: String, exposureBias: Float) -> (stroke: UIColor, glow: UIColor) {
    let lum = CGFloat(min(1.35, max(0.65, 1.0 + exposureBias * 0.12)))
    switch phase {
    case "matched":
      return (
        UIColor(red: 0.19 * lum, green: 0.82 * lum, blue: 0.35, alpha: 0.8),
        UIColor.systemGreen
      )
    case "aligning":
      return (
        UIColor(red: 1.0 * lum, green: 0.84 * lum, blue: 0.04, alpha: 0.8),
        UIColor.systemYellow
      )
    default:
      return (
        UIColor(white: lum, alpha: 0.8),
        UIColor.white
      )
    }
  }
}