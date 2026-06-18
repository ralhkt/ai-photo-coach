import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/session_tip_text.dart';
import '../../../models/shoot_session.dart';
import '../services/session_summary_builder.dart';

class SessionSummaryScreen extends ConsumerStatefulWidget {
  const SessionSummaryScreen({
    super.key,
    required this.session,
    this.batteryDeltaPercent,
  });

  final ShootSession session;
  final int? batteryDeltaPercent;

  @override
  ConsumerState<SessionSummaryScreen> createState() =>
      _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen> {
  SessionSummary? _summary;
  Object? _error;
  int _progressCompleted = 0;
  int _progressTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await ref.read(sessionSummaryBuilderProvider).build(
            widget.session,
            batteryDeltaPercent: widget.batteryDeltaPercent,
            onProgress: (completed, total) {
              if (!mounted) {
                return;
              }
              setState(() {
                _progressCompleted = completed;
                _progressTotal = total;
              });
            },
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = summary;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionSummaryTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error.toString()),
          ),
        ),
      );
    }

    if (_summary == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionSummaryTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.sessionSummaryLoading),
              if (_progressTotal > 0) ...[
                const SizedBox(height: 8),
                Text(l10n.sessionSummaryProgress(_progressCompleted, _progressTotal)),
              ],
            ],
          ),
        ),
      );
    }

    final summary = _summary!;
    final bestIndex = summary.bestPhotoIndex;
    final bestInsight = bestIndex == null
        ? null
        : summary.photoInsights.firstWhere(
            (item) => item.index == bestIndex,
            orElse: () => summary.photoInsights.first,
          );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionSummaryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.sessionSummarySubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.sessionStatPhotos,
                  value: '${summary.session.captures.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: l10n.sessionStatDuration,
                  value: _formatDuration(summary.session.duration),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            label: l10n.sessionStatMode,
            value: summary.session.mode == ShootSessionMode.guided
                ? l10n.sessionModeGuided
                : l10n.sessionModeFree,
            fullWidth: true,
          ),
          if (summary.averageAestheticScore != null) ...[
            const SizedBox(height: 12),
            _StatCard(
              label: l10n.sessionStatAesthetic,
              value: summary.averageAestheticScore!.toStringAsFixed(2),
              fullWidth: true,
            ),
          ],
          if (summary.analysisDurationMs > 0) ...[
            const SizedBox(height: 12),
            _StatCard(
              label: l10n.sessionStatAnalysisTime,
              value: l10n.sessionStatAnalysisMs(summary.analysisDurationMs),
              fullWidth: true,
            ),
          ],
          if (summary.batteryDeltaPercent != null &&
              summary.batteryDeltaPercent! >= 0) ...[
            const SizedBox(height: 12),
            _StatCard(
              label: l10n.sessionStatBattery,
              value: l10n.sessionStatBatteryDelta(summary.batteryDeltaPercent!),
              fullWidth: true,
            ),
          ],
          if (bestInsight != null) ...[
            const SizedBox(height: 24),
            Text(
              l10n.sessionBestShot,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.memory(
                  bestInsight.thumbnailBytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            l10n.sessionFeedbackTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...summary.feedbackTipKeys.map(
            (key) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(sessionTipLabel(l10n, key)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(l10n.sessionDone),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54)),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (fullWidth) {
      return card;
    }
    return card;
  }
}