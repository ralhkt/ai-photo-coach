import 'dart:typed_data';

import 'captured_photo.dart';

enum ShootSessionMode { free, guided }

class SessionCapture {
  const SessionCapture({
    required this.photo,
    required this.recordedAt,
  });

  final CapturedPhoto photo;
  final DateTime recordedAt;
}

class ShootSession {
  const ShootSession({
    required this.id,
    required this.mode,
    required this.startedAt,
    required this.captures,
  });

  final String id;
  final ShootSessionMode mode;
  final DateTime startedAt;
  final List<SessionCapture> captures;

  Duration get duration {
    if (captures.isEmpty) {
      return DateTime.now().difference(startedAt);
    }
    return captures.last.recordedAt.difference(startedAt);
  }

  ShootSession copyWith({
    List<SessionCapture>? captures,
  }) {
    return ShootSession(
      id: id,
      mode: mode,
      startedAt: startedAt,
      captures: captures ?? this.captures,
    );
  }
}

class SessionPhotoInsight {
  const SessionPhotoInsight({
    required this.index,
    required this.brightness,
    required this.aestheticScore,
    required this.thumbnailBytes,
  });

  final int index;
  final double brightness;
  final double? aestheticScore;
  final Uint8List thumbnailBytes;
}

class SessionSummary {
  const SessionSummary({
    required this.session,
    required this.photoInsights,
    required this.averageAestheticScore,
    required this.bestPhotoIndex,
    required this.feedbackTipKeys,
  });

  final ShootSession session;
  final List<SessionPhotoInsight> photoInsights;
  final double? averageAestheticScore;
  final int? bestPhotoIndex;
  final List<String> feedbackTipKeys;
}