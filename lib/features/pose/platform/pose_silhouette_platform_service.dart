import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum PoseSilhouettePhase {
  noMatch,
  aligning,
  matched,
}

class PoseSilhouetteAlignmentEvent {
  const PoseSilhouetteAlignmentEvent({
    required this.score,
    required this.phase,
    required this.toast,
    required this.enabled,
    this.phaseChanged = false,
    this.autoCaptureRequested = false,
  });

  final int score;
  final PoseSilhouettePhase phase;
  final String toast;
  final bool enabled;
  final bool phaseChanged;
  final bool autoCaptureRequested;

  factory PoseSilhouetteAlignmentEvent.fromJson(Map<dynamic, dynamic> map) {
    final phaseName = map['phase'] as String? ?? 'noMatch';
    final phase = PoseSilhouettePhase.values.firstWhere(
      (value) => value.name == phaseName,
      orElse: () => PoseSilhouettePhase.noMatch,
    );
    return PoseSilhouetteAlignmentEvent(
      score: map['score'] as int? ?? 0,
      phase: phase,
      toast: map['toast'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? false,
      phaseChanged: map['phaseChanged'] as bool? ?? false,
      autoCaptureRequested: map['autoCaptureRequested'] as bool? ?? false,
    );
  }
}

/// Native iOS Metal silhouette overlay (PR-2). Android falls back to Flutter painter.
class PoseSilhouettePlatformService {
  PoseSilhouettePlatformService({
    @visibleForTesting MethodChannel? methodChannel,
    @visibleForTesting EventChannel? eventChannel,
  })  : _channel = methodChannel ??
            const MethodChannel('com.aiphotocoach.app/pose_silhouette'),
        _eventChannel = eventChannel ??
            const EventChannel('com.aiphotocoach.app/pose_silhouette_events');

  static const platformViewType = 'com.aiphotocoach.app/pose_silhouette_view';

  final MethodChannel _channel;
  final EventChannel _eventChannel;
  Stream<PoseSilhouetteAlignmentEvent>? _alignmentStream;
  bool? _cachedSupported;

  Future<bool> isSupported() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }
    if (_cachedSupported != null) {
      return _cachedSupported!;
    }
    try {
      final supported = await _channel.invokeMethod<bool>('isSupported');
      _cachedSupported = supported ?? false;
      return _cachedSupported!;
    } on PlatformException catch (error) {
      debugPrint('PoseSilhouette isSupported failed: ${error.message}');
      _cachedSupported = false;
      return false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setEnabled', {'enabled': enabled});
    } on PlatformException catch (error) {
      debugPrint('PoseSilhouette setEnabled failed: ${error.message}');
    }
  }

  Future<void> setGuideContour(List<Offset> points) async {
    if (points.length < 4) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('setGuideContour', {
        'points': [
          for (final point in points)
            {'dx': point.dx, 'dy': point.dy},
        ],
      });
    } on PlatformException catch (error) {
      debugPrint('PoseSilhouette setGuideContour failed: ${error.message}');
    }
  }

  Future<void> setRenderMode(String mode) async {
    try {
      await _channel.invokeMethod<void>('setRenderMode', {'mode': mode});
    } on PlatformException catch (error) {
      debugPrint('PoseSilhouette setRenderMode failed: ${error.message}');
    }
  }

  Future<void> setSkeletonSegments(List<List<Offset>> segments) async {
    try {
      await _channel.invokeMethod<void>('setSkeletonSegments', {
        'segments': [
          for (final segment in segments)
            [
              for (final point in segment)
                {'dx': point.dx, 'dy': point.dy},
            ],
        ],
      });
    } on PlatformException catch (error) {
      debugPrint('PoseSilhouette setSkeletonSegments failed: ${error.message}');
    }
  }

  Future<void> setAlignmentScore(int score) async {
    try {
      await _channel.invokeMethod<void>('setAlignmentScore', {
        'score': score.clamp(0, 100),
      });
    } on PlatformException catch (error) {
      debugPrint('PoseSilhouette setAlignmentScore failed: ${error.message}');
    }
  }

  Future<List<Offset>?> extractContourFromImage(Uint8List bytes) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'extractContourFromImage',
        {'bytes': bytes},
      );
      if (result == null || result.isEmpty) {
        return null;
      }
      return [
        for (final item in result)
          if (item is Map)
            Offset(
              (item['dx'] as num?)?.toDouble() ?? 0,
              (item['dy'] as num?)?.toDouble() ?? 0,
            ),
      ];
    } on PlatformException catch (error) {
      debugPrint('PoseSilhouette extractContour failed: ${error.message}');
      return null;
    }
  }

  Stream<PoseSilhouetteAlignmentEvent> watchAlignment() {
    _alignmentStream ??= _eventChannel
        .receiveBroadcastStream()
        .map(
          (event) => PoseSilhouetteAlignmentEvent.fromJson(
            event as Map<dynamic, dynamic>,
          ),
        )
        .handleError((Object error) {
      debugPrint('PoseSilhouette event stream error: $error');
    }).cast<PoseSilhouetteAlignmentEvent>();
    return _alignmentStream!;
  }
}