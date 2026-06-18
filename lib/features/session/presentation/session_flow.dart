import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/performance/battery_session_tracker.dart';
import '../providers/shoot_session_provider.dart';
import 'session_summary_screen.dart';

Future<void> endShootSession(BuildContext context, WidgetRef ref) async {
  final session = ref.read(shootSessionProvider.notifier).endSession();
  if (session == null || session.captures.isEmpty || !context.mounted) {
    return;
  }

  final batteryReport = await ref.read(batterySessionTrackerProvider).end();
  if (batteryReport != null &&
      batteryReport.startPercent >= 0 &&
      batteryReport.endPercent >= 0) {
    ref.read(lastBatteryReportProvider.notifier).state = batteryReport;
  }

  Navigator.of(context).popUntil((route) => route.isFirst);
  if (!context.mounted) {
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SessionSummaryScreen(
        session: session,
        batteryDeltaPercent: batteryReport?.deltaPercent,
      ),
    ),
  );
}

Future<bool> confirmEndSessionOnClose(
  BuildContext context,
  WidgetRef ref,
) async {
  final session = ref.read(shootSessionProvider);
  if (session == null || session.captures.isEmpty) {
    ref.read(shootSessionProvider.notifier).discardSession();
    return true;
  }

  final l10n = AppLocalizations.of(context)!;
  final action = await showDialog<_CloseAction>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.sessionEndDialogTitle),
        content: Text(l10n.sessionEndDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _CloseAction.cancel),
            child: Text(l10n.sessionEndDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _CloseAction.discard),
            child: Text(l10n.sessionEndDialogDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _CloseAction.summarize),
            child: Text(l10n.sessionEndDialogSummarize),
          ),
        ],
      );
    },
  );

  if (!context.mounted) {
    return false;
  }

  switch (action) {
    case _CloseAction.summarize:
      await endShootSession(context, ref);
      return false;
    case _CloseAction.discard:
      ref.read(shootSessionProvider.notifier).discardSession();
      return true;
    case _CloseAction.cancel:
    case null:
      return false;
  }
}

enum _CloseAction { cancel, discard, summarize }