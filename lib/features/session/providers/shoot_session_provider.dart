import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/captured_photo.dart';
import '../../../models/shoot_session.dart';

final shootSessionProvider =
    NotifierProvider<ShootSessionNotifier, ShootSession?>(
  ShootSessionNotifier.new,
);

class ShootSessionNotifier extends Notifier<ShootSession?> {
  @override
  ShootSession? build() => null;

  void startSession(ShootSessionMode mode) {
    state = ShootSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mode: mode,
      startedAt: DateTime.now(),
      captures: const [],
    );
  }

  void recordCapture(CapturedPhoto photo) {
    final session = state;
    if (session == null) {
      return;
    }

    state = session.copyWith(
      captures: [
        ...session.captures,
        SessionCapture(photo: photo, recordedAt: DateTime.now()),
      ],
    );
  }

  ShootSession? endSession() {
    final session = state;
    state = null;
    return session;
  }

  void discardSession() {
    state = null;
  }

  bool get hasCaptures => (state?.captures.isNotEmpty ?? false);
}