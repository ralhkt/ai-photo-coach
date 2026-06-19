import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pose_silhouette_provider.dart';
import 'pose_silhouette_platform_service.dart';

/// Dark capsule toast driven by native alignment state machine.
class PoseSilhouetteNativeToast extends ConsumerWidget {
  const PoseSilhouetteNativeToast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supported =
        ref.watch(poseSilhouetteNativeSupportedProvider).valueOrNull ?? false;
    if (!supported) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<PoseSilhouetteAlignmentEvent>(
      stream: ref.read(poseSilhouetteServiceProvider).watchAlignment(),
      builder: (context, snapshot) {
        final event = snapshot.data;
        if (event == null || !event.enabled || event.toast.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 132,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _ToastCapsule(
                key: ValueKey(event.toast),
                message: event.toast,
                phase: event.phase,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToastCapsule extends StatelessWidget {
  const _ToastCapsule({
    super.key,
    required this.message,
    required this.phase,
  });

  final String message;
  final PoseSilhouettePhase phase;

  @override
  Widget build(BuildContext context) {
    final accent = switch (phase) {
      PoseSilhouettePhase.matched => const Color(0xFF30D158),
      PoseSilhouettePhase.aligning => const Color(0xFFFFD60A),
      PoseSilhouettePhase.noMatch => Colors.white70,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}