import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/services/photo_gallery_saver.dart';
import '../../../models/captured_photo.dart';
import '../../session/presentation/session_flow.dart';
import '../../session/providers/shoot_session_provider.dart';

class PhotoReviewScreen extends ConsumerStatefulWidget {
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
  ConsumerState<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends ConsumerState<PhotoReviewScreen> {
  bool _saving = false;
  bool _saved = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    if (!widget.isFromGallery) {
      _saveToGallery(showErrors: false);
    }
  }

  Future<void> _saveToGallery({bool showErrors = true}) async {
    if (widget.isFromGallery || _saving || _saved) {
      return;
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      await PhotoGallerySaver.saveCapturedPhoto(widget.photo);
      if (!mounted) {
        return;
      }
      setState(() {
        _saved = true;
        _saving = false;
      });
      if (showErrors) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            content: Text(l10n.photoSavedToGallery),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _saveError = AppLocalizations.of(context)!.photoSaveFailed;
      });
      if (showErrors) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            content: Text(_saveError!),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(shootSessionProvider);
    final showEndSession = widget.isSessionCapture &&
        !widget.isFromGallery &&
        (session?.captures.isNotEmpty ?? false);
    final canSave = !widget.isFromGallery;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.memory(widget.photo.bytes, fit: BoxFit.contain),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.isFromGallery
                                  ? l10n.galleryPreview
                                  : l10n.photoPreview,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (canSave && (_saved || _saving)) ...[
                              const SizedBox(height: 2),
                              Text(
                                _saving
                                    ? l10n.savingPhoto
                                    : l10n.photoSavedToGallery,
                                style: TextStyle(
                                  color: _saved
                                      ? const Color(0xFFFFD60A)
                                      : Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (canSave)
                        IconButton(
                          onPressed: _saving || _saved
                              ? null
                              : () => _saveToGallery(),
                          tooltip: l10n.saveToGallery,
                          icon: Icon(
                            _saved
                                ? Icons.check_circle_rounded
                                : Icons.ios_share_rounded,
                            color: _saved
                                ? const Color(0xFFFFD60A)
                                : Colors.white,
                          ),
                        )
                      else
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_saveError != null) ...[
                      Text(
                        _saveError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        if (canSave && !_saved) ...[
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saving ? null : () => _saveToGallery(),
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Icon(Icons.save_alt_rounded),
                              label: Text(
                                _saving ? l10n.savingPhoto : l10n.saveToGallery,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
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