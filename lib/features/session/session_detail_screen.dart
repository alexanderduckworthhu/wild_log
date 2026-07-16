import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/layout/wild_space.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/motion/fade_slide_in.dart';
import '../../core/theme/wild_colors.dart';
import '../../providers/providers.dart';
import '../shared/wild_widgets.dart';
import 'session_form_screen.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);

    return sessions.when(
      loading: () => const Scaffold(
        body: WildLoading(message: AppStrings.sessionOpening),
      ),
      error: (error, stack) => Scaffold(
        body: WildStatusMessage(
          title: AppStrings.sessionLoadErrorTitle,
          body: AppStrings.sessionLoadErrorBody,
          actionLabel: AppStrings.retry,
          onAction: () => ref.invalidate(sessionsProvider),
        ),
      ),
      data: (list) {
        final session = list.where((s) => s.id == sessionId).firstOrNull;
        if (session == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const WildStatusMessage(
              title: AppStrings.sessionMissingTitle,
              body: AppStrings.sessionMissingBody,
            ),
          );
        }

        final date =
            DateFormat('EEEE, MMM d yyyy · h:mm a').format(session.startedAt);

        return Scaffold(
          backgroundColor: WildColors.voidBlack,
          appBar: AppBar(
            title: const Text(AppStrings.sessionTitle),
            actions: [
              IconButton(
                tooltip: AppStrings.editTooltip,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final saved = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => SessionFormScreen(existing: session),
                    ),
                  );
                  if (saved == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.updatedSnack)),
                    );
                  }
                },
              ),
              IconButton(
                tooltip: AppStrings.deleteTooltip,
                icon: const Icon(Icons.delete_outline, color: WildColors.danger),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: WildColors.ridge,
                      title: const Text(AppStrings.deleteConfirmTitle),
                      content: const Text(AppStrings.deleteConfirmBody),
                      actions: [
                        WildSecondaryButton(
                          label: AppStrings.keepIt,
                          onPressed: () => Navigator.pop(ctx, false),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            AppStrings.remove,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: WildColors.danger,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    await ref.read(sessionRepositoryProvider).delete(session.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppStrings.removedSnack),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              WildSpace.lg,
              WildSpace.xs,
              WildSpace.lg,
              WildSpace.xxl,
            ),
            children: [
              FadeSlideIn(child: ActivityBadge(type: session.activityType)),
              const SizedBox(height: WildSpace.sm),
              FadeSlideIn(
                delay: const Duration(
                  milliseconds: AppConstants.listStaggerStepMs,
                ),
                child: Text(
                  session.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: WildSpace.xxs),
              FadeSlideIn(
                delay: Duration(
                  milliseconds: AppConstants.listStaggerStepMs * 2,
                ),
                child: Text(date, style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: WildSpace.lg),
              FadeSlideIn(
                delay: Duration(
                  milliseconds: AppConstants.listStaggerStepMs * 2 +
                      AppConstants.listStaggerStepMs ~/ 3,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: AppStrings.durationLabel,
                        value: _formatDuration(session.durationMinutes),
                      ),
                    ),
                    const SizedBox(width: WildSpace.sm),
                    Expanded(
                      child: FieldPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.difficultyLabel.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: WildSpace.sm),
                            Semantics(
                              label: AppStrings.difficultySemantics(
                                session.difficulty,
                              ),
                              child: DifficultyPips(value: session.difficulty),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (session.locationName != null) ...[
                const SizedBox(height: WildSpace.sm),
                FadeSlideIn(
                  delay: Duration(
                    milliseconds: AppConstants.listStaggerStepMs * 3 +
                        AppConstants.listStaggerStepMs ~/ 3,
                  ),
                  child: FieldPanel(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: WildColors.lichen,
                        ),
                        const SizedBox(width: WildSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.locationName!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (session.hasMapPin)
                                Text(
                                  '${session.latitude!.toStringAsFixed(4)}, '
                                  '${session.longitude!.toStringAsFixed(4)}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (session.elevationGainM != null ||
                  session.distanceKm != null) ...[
                const SizedBox(height: WildSpace.sm),
                FadeSlideIn(
                  delay: Duration(
                    milliseconds: AppConstants.listStaggerMaxMs,
                  ),
                  child: Row(
                    children: [
                      if (session.elevationGainM != null)
                        Expanded(
                          child: StatTile(
                            label: AppStrings.elevationLabel,
                            value: session.elevationGainM!.round().toString(),
                            unit: AppStrings.unitMeters,
                            accent: WildColors.ember,
                          ),
                        ),
                      if (session.elevationGainM != null &&
                          session.distanceKm != null)
                        const SizedBox(width: WildSpace.sm),
                      if (session.distanceKm != null)
                        Expanded(
                          child: StatTile(
                            label: AppStrings.distanceLabel,
                            value: session.distanceKm!.toStringAsFixed(1),
                            unit: AppStrings.unitKilometers,
                            accent: WildColors.ice,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (session.details.isNotEmpty) ...[
                const SizedBox(height: WildSpace.lg),
                const SectionLabel(AppStrings.detailsLabel),
                const SizedBox(height: WildSpace.sm),
                FieldPanel(
                  child: Column(
                    children: [
                      for (final e in session.details.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: WildSpace.xs,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _humanize(e.key),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${e.value}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (session.notes != null && session.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: WildSpace.lg),
                const SectionLabel(AppStrings.notesLabel),
                const SizedBox(height: WildSpace.sm),
                FieldPanel(
                  child: Text(
                    session.notes!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String _humanize(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
