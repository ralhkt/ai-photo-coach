/// Options for background preview sampling (pose / scene ML).
class PreviewCaptureRequest {
  const PreviewCaptureRequest({
    this.maxSide = 720,
    this.lightweight = false,
  });

  /// Downscale longest edge before returning JPEG bytes.
  final int maxSide;

  /// Skips AF/AE/flash churn — use for high-frequency coaching polls.
  final bool lightweight;

  static const coaching = PreviewCaptureRequest(
    maxSide: 480,
    lightweight: true,
  );

  static const scene = PreviewCaptureRequest(
    maxSide: 640,
    lightweight: true,
  );
}