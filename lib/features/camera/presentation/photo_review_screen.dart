import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../models/captured_photo.dart';
import '../../session/presentation/session_flow.dart';
import '../../session/providers/shoot_session_provider.dart';

class PhotoReviewScreen extends ConsumerWidget {
  const PhotoReviewScreen({
    super.key,
    required this.photo,
    this.isFromGallery = false,
    this.isSessionCapture = false,
  });

  final CapturedPhoto photo;
  final bool isFromGallery;
  final bool isSessionCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(shootSessionProvider);
    final showEndSession = isSessionCapture &&
        !isFromGallery &&
        (session?.captures.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.memory(photo.bytes, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          isFromGallery ? l10n.galleryPreview : l10n.photoPreview,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(l10n.keepShooting),
                      ),
                    ),
                    if (showEndSession) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => endShootSession(context, ref),
                          child: Text(l10n.endSession),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}