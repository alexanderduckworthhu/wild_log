import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/layout/wild_space.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/motion/fade_slide_in.dart';
import '../../core/theme/wild_colors.dart';
import '../../domain/activity_type.dart';
import '../../domain/session.dart';
import '../../providers/providers.dart';
import '../session/session_detail_screen.dart';
import '../shared/wild_widgets.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  ActivityType? _filter;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return ColoredBox(
      color: WildColors.voidBlack,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WildHeader(
              title: AppStrings.logbookTitle,
              subtitle: AppStrings.logbookSubtitle,
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: WildSpace.lg),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: WildSpace.xs),
                    child: FilterChip(
                      label: const Text(AppStrings.filterAll),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                  ),
                  ...ActivityType.values
                      .where((t) => t != ActivityType.other)
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(right: WildSpace.xs),
                          child: FilterChip(
                            avatar: Icon(t.icon, size: 16, color: t.color),
                            label: Text(t.label),
                            selected: _filter == t,
                            onSelected: (_) => setState(() => _filter = t),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: WildSpace.xs),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: sessionsAsync.when(
                  loading: () => const WildLoading(key: ValueKey('loading')),
                  error: (error, stack) => WildStatusMessage(
                    key: const ValueKey('error'),
                    title: AppStrings.logbookLoadErrorTitle,
                    body: AppStrings.logbookLoadErrorBody,
                    actionLabel: AppStrings.retry,
                    onAction: () => ref.invalidate(sessionsProvider),
                  ),
                  data: (sessions) {
                    final filtered = _filter == null
                        ? sessions
                        : sessions
                            .where((s) => s.activityType == _filter)
                            .toList();
                    if (filtered.isEmpty) {
                      return WildStatusMessage(
                        key: ValueKey('empty-$_filter'),
                        icon: Icons.menu_book_outlined,
                        title: _filter == null
                            ? AppStrings.logbookEmptyTitle
                            : AppStrings.logbookEmptyFilterTitle(
                                _filter!.label.toLowerCase(),
                              ),
                        body: AppStrings.logbookEmptyBody,
                      );
                    }
                    return ListView.separated(
                      key: ValueKey('list-${filtered.length}-$_filter'),
                      padding: WildSpace.pageInsets.copyWith(top: WildSpace.xs),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: WildSpace.sm),
                      itemBuilder: (context, i) => FadeSlideIn(
                        delay: Duration(
                          milliseconds: (i * AppConstants.listStaggerStepMs)
                              .clamp(0, AppConstants.listStaggerMaxMs),
                        ),
                        child: _SessionTile(session: filtered[i]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final AdventureSession session;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, yyyy').format(session.startedAt);
    return FieldPanel(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionDetailScreen(sessionId: session.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ActivityBadge(type: session.activityType, compact: true),
              const Spacer(),
              Text(date, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: WildSpace.sm),
          Text(session.title, style: Theme.of(context).textTheme.titleMedium),
          if (session.locationName != null) ...[
            const SizedBox(height: WildSpace.xxs),
            Text(
              session.locationName!,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: WildSpace.sm),
          Row(
            children: [
              DifficultyPips(value: session.difficulty),
              const Spacer(),
              if (session.elevationGainM != null)
                Text(
                  '+${session.elevationGainM!.round()} ${AppStrings.unitMeters}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: WildColors.ember,
                      ),
                ),
              if (session.distanceKm != null) ...[
                const SizedBox(width: WildSpace.sm),
                Text(
                  '${session.distanceKm!.toStringAsFixed(1)} ${AppStrings.unitKilometers}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: WildColors.ice,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
