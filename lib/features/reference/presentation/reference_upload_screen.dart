import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../models/scene_type.dart';
import '../providers/reference_providers.dart';
import 'analysis_result_screen.dart';

class ReferenceUploadScreen extends ConsumerStatefulWidget {
  const ReferenceUploadScreen({super.key});

  @override
  ConsumerState<ReferenceUploadScreen> createState() =>
      _ReferenceUploadScreenState();
}

class _ReferenceUploadScreenState extends ConsumerState<ReferenceUploadScreen> {
  final _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) {
      return;
    }

    setState(() => _isPicking = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        imageQuality: 92,
      );

      if (!mounted || file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      final sceneType = ref.read(selectedSceneTypeProvider);
      await ref.read(referenceAnalysisProvider.notifier).analyze(
            bytes,
            userSceneType: sceneType,
          );

      if (!mounted) {
        return;
      }

      final analysis = ref.read(referenceAnalysisProvider);
      if (analysis.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.analysisFailed)),
        );
        return;
      }

      if (analysis.hasValue && analysis.value != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AnalysisResultScreen(),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysisState = ref.watch(referenceAnalysisProvider);
    final selectedScene = ref.watch(selectedSceneTypeProvider);
    final isAnalyzing = analysisState.isLoading || _isPicking;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadReferenceTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.uploadReferenceSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.selectSceneType,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SceneType.values.map((scene) {
                  final isSelected = selectedScene == scene;
                  return ChoiceChip(
                    label: Text(sceneTypeChoiceLabel(l10n, scene)),
                    selected: isSelected,
                    onSelected: isAnalyzing
                        ? null
                        : (_) {
                            ref.read(selectedSceneTypeProvider.notifier).state =
                                scene;
                          },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectSceneTypeHint,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Center(
                    child: isAnalyzing
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(l10n.analyzingImage),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_search_rounded,
                                size: 72,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.uploadPrompt,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: isAnalyzing
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.pickFromGallery),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed:
                    isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.pickFromCamera),
              ),
            ],
          ),
        ),
      ),
    );
  }
}