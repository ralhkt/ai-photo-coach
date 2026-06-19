import UIKit

enum AlignmentPhase: String, Equatable {
  case noMatch
  case aligning
  case matched
}

final class AlignmentStateMachine {
  private(set) var phase: AlignmentPhase = .noMatch
  private var lastAutoCaptureAt = Date.distantPast
  private let autoCaptureCooldown: TimeInterval = 1.5

  func update(score: Int) -> [String: Any] {
    let newPhase = phase(for: score)
    let phaseChanged = newPhase != phase
    phase = newPhase

    if phaseChanged {
      triggerHaptic(for: newPhase)
    }

    var payload: [String: Any] = [
      "score": score,
      "phase": newPhase.rawValue,
      "toast": toast(for: newPhase),
      "phaseChanged": phaseChanged,
    ]

    if newPhase == .matched && phaseChanged {
      let now = Date()
      if now.timeIntervalSince(lastAutoCaptureAt) >= autoCaptureCooldown {
        lastAutoCaptureAt = now
        payload["autoCaptureRequested"] = true
      }
    }

    return payload
  }

  func reset() {
    phase = .noMatch
  }

  private func phase(for score: Int) -> AlignmentPhase {
    if score >= 85 {
      return .matched
    }
    if score >= 50 {
      return .aligning
    }
    return .noMatch
  }

  private func toast(for phase: AlignmentPhase) -> String {
    switch phase {
    case .noMatch:
      return "請站入輪廓中央"
    case .aligning:
      return "肢體對齊中…請將身體套入輪廓"
    case .matched:
      return "完美對齊！可以拍了"
    }
  }

  private func triggerHaptic(for phase: AlignmentPhase) {
    DispatchQueue.main.async {
      switch phase {
      case .noMatch:
        break
      case .aligning:
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
      case .matched:
        UINotificationFeedbackGenerator().notificationOccurred(.success)
      }
    }
  }
}