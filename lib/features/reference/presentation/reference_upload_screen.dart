import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../models/scene_type.dart';
import '../data/reference_sample_catalog.dart';
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
  String? _activeSampleId;
  bool _isPickingGallery = false;

  Future<void> _runAnalysis(Uint8List bytes, SceneType sceneType) async {
    final l10n = AppLocalizations.of(context)!;
    ref.read(selectedSceneTypeProvider.notifier).state = sceneType;

    await ref.read(referenceAnalysisProvider.notifier).analyze(
          bytes,
          userSceneType: sceneType,
        );

    if (!mounted) {
      return;
    }

    final analysis = ref.read(referenceAnalysisProvider);
    if (analysis.hasError) {
      final detail = analysis.error?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            detail == null || detail.isEmpty
                ? l10n.analysisFailed
                : '${l10n.analysisFailed}\n$detail',
          ),
          action: SnackBarAction(
            label: l10n.retry,
            onPressed: () => _runAnalysis(bytes, sceneType),
          ),
        ),
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
  }

  Future<void> _analyzeSample(ReferenceSample sample) async {
    if (_activeSampleId != null || _isPickingGallery) {
      return;
    }

    setState(() => _activeSampleId = sample.id);

    try {
      final data = await rootBundle.load(sample.assetPath);
      await _runAnalysis(data.buffer.asUint8List(), sample.sceneType);
    } finally {
      if (mounted) {
        setState(() => _activeSampleId = null);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_activeSampleId != null || _isPickingGallery) {
      return;
    }

    setState(() => _isPickingGallery = true);

    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        imageQuality: 92,
      );
      if (!mounted || file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      final sceneType = ref.read(selectedSceneTypeProvider);
      await _runAnalysis(bytes, sceneType);
    } finally {
      if (mounted) {
        setState(() => _isPickingGallery = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysisState = ref.watch(referenceAnalysisProvider);
    final selectedScene = ref.watch(selectedSceneTypeProvider);
    final isAnalyzing = analysisState.isLoading ||
        _activeSampleId != null ||
        _isPickingGallery;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadReferenceTitle)),
      body: SafeArea(
        child: isAnalyzing
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.analyzingImage),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.uploadReferenceSubtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.uploadPrompt,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.referenceSamplesSection,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sample = referenceSampleCatalog[index];
                          return _ReferenceSampleCard(
                            sample: sample,
                            title: referenceSampleTitle(l10n, sample.titleKey),
                            subtitle: referenceSampleSubtitle(
                              l10n,
                              sample.subtitleKey,
                            ),
                            onTap: () => _analyzeSample(sample),
                          );
                        },
                        childCount: referenceSampleCatalog.length,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.uploadOwnPhotoSection,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.selectSceneTypeHint,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: SceneType.values.map((scene) {
                              final isSelected = selectedScene == scene;
                              return ChoiceChip(
                                label: Text(sceneTypeChoiceLabel(l10n, scene)),
                                selected: isSelected,
                                onSelected: (_) {
                                  ref
                                      .read(selectedSceneTypeProvider.notifier)
                                      .state = scene;
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _pickFromGallery,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(l10n.pickFromGallery),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
      ),
    );
  }
}

class _ReferenceSampleCard extends StatelessWidget {
  const _ReferenceSampleCard({
    required this.sample,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final ReferenceSample sample;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(17)),
                  child: Image.asset(
                    sample.assetPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}