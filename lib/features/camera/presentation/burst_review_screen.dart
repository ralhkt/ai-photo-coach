import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/services/photo_gallery_saver.dart';
import '../../../models/captured_photo.dart';

class BurstReviewScreen extends StatefulWidget {
  const BurstReviewScreen({super.key, required this.photos});

  final List<CapturedPhoto> photos;

  @override
  State<BurstReviewScreen> createState() => _BurstReviewScreenState();
}

class _BurstReviewScreenState extends State<BurstReviewScreen> {
  late final PageController _controller;
  int _index = 0;
  bool _saving = false;
  final Set<int> _savedIndexes = {};

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentPhoto() async {
    if (_saving || _savedIndexes.contains(_index)) {
      return;
    }

    setState(() => _saving = true);
    try {
      await PhotoGallerySaver.saveCapturedPhoto(widget.photos[_index]);
      if (!mounted) {
        return;
      }
      setState(() {
        _savedIndexes.add(_index);
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(AppLocalizations.of(context)!.photoSavedToGallery),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(AppLocalizations.of(context)!.photoSaveFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentSaved = _savedIndexes.contains(_index);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.memory(
                    widget.photos[index].bytes,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
                        l10n.burstReviewTitle(_index + 1, widget.photos.length),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving || currentSaved ? null : _saveCurrentPhoto,
                      icon: Icon(
                        currentSaved
                            ? Icons.check_circle_rounded
                            : Icons.ios_share_rounded,
                        color: currentSaved
                            ? const Color(0xFFFFD60A)
                            : Colors.white,
                      ),
                    ),
                  ],
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!currentSaved)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _saveCurrentPhoto,
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
                      ),
                    SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.photos.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final selected = index == _index;
                      return GestureDetector(
                        onTap: () {
                          _controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          width: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFFFFD60A)
                                  : Colors.white24,
                              width: selected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.memory(
                            widget.photos[index].bytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    ),
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