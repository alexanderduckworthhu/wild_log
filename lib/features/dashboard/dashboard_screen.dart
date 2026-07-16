import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/layout/wild_space.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/motion/fade_slide_in.dart';
import '../../core/theme/wild_colors.dart';
import '../../domain/activity_type.dart';
import '../../domain/dashboard_stats.dart';
import '../../providers/providers.dart';
import '../shared/wild_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.onQuickLog});

  final ValueChanged<ActivityType> onQuickLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF141C18), WildColors.voidBlack, Color(0xFF0C1210)],
          stops: [0, 0.45, 1],
        ),
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: statsAsync.when(
            loading: () => const WildLoading(key: ValueKey('loading')),
            error: (error, stack) => WildStatusMessage(
              key: const ValueKey('error'),
              icon: Icons.cloud_off_outlined,
              title: AppStrings.summitLoadErrorTitle,
              body: AppStrings.summitLoadErrorBody,
              actionLabel: AppStrings.retry,
              onAction: () => ref.invalidate(sessionsProvider),
            ),
            data: (stats) => CustomScrollView(
              key: const ValueKey('data'),
              slivers: [
                const SliverToBoxAdapter(
                  child: WildHeader(
                    title: AppStrings.summitTitle,
                    subtitle: AppStrings.summitSubtitle,
                  ),
                ),
                SliverPadding(
                  padding: WildSpace.pageInsets,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      FadeSlideIn(child: _StreakRow(stats: stats)),
                      const SizedBox(height: WildSpace.md),
                      FadeSlideIn(
                        delay: const Duration(
                          milliseconds: AppConstants.listStaggerStepMs,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: StatTile(
                                label: AppStrings.sessionsLabel,
                                value: '${stats.totalSessions}',
                              ),
                            ),
                            const SizedBox(width: WildSpace.sm),
                            Expanded(
                              child: StatTile(
                                label: AppStrings.elevationLabel,
                                value: stats.totalElevationM.round().toString(),
                                unit: AppStrings.unitMeters,
                                accent: WildColors.ember,
                              ),
                            ),
                            const SizedBox(width: WildSpace.sm),
                            Expanded(
                              child: StatTile(
                                label: AppStrings.distanceLabel,
                                value: stats.totalDistanceKm.toStringAsFixed(0),
                                unit: AppStrings.unitKilometers,
                                accent: WildColors.ice,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: WildSpace.xl),
                      FadeSlideIn(
                        delay: Duration(
                          milliseconds: AppConstants.listStaggerStepMs * 2 +
                              AppConstants.listStaggerStepMs ~/ 3,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel(AppStrings.quickLog),
                            const SizedBox(height: WildSpace.sm),
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (final t in ActivityType.values.where(
                                    (t) => t != ActivityType.other,
                                  ))
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: WildSpace.xs,
                                      ),
                                      child: ActionChip(
                                        avatar: Icon(
                                          t.icon,
                                          size: 16,
                                          color: t.color,
                                        ),
                                        label: Text(t.label),
                                        onPressed: () => onQuickLog(t),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: WildSpace.xl),
                      FadeSlideIn(
                        delay: Duration(
                          milliseconds: AppConstants.listStaggerStepMs * 3 +
                              AppConstants.listStaggerStepMs ~/ 3,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel(AppStrings.byActivity),
                            const SizedBox(height: WildSpace.sm),
                            FieldPanel(
                              padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                              child: SizedBox(
                                height: 190,
                                child: _TypeBarChart(stats: stats),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (stats.records.isNotEmpty) ...[
                        const SizedBox(height: WildSpace.xl),
                        FadeSlideIn(
                          delay: Duration(
                            milliseconds: AppConstants.listStaggerMaxMs +
                                AppConstants.listStaggerStepMs,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel(AppStrings.personalBests),
                              const SizedBox(height: WildSpace.sm),
                              ...stats.records.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: WildSpace.xs,
                                  ),
                                  child: _RecordRow(record: r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: WildSpace.xl),
                      FadeSlideIn(
                        delay: Duration(
                          milliseconds: AppConstants.listStaggerMaxMs +
                              AppConstants.listStaggerStepMs * 2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel(AppStrings.upNext),
                            const SizedBox(height: WildSpace.sm),
                            _MilestoneCard(milestone: stats.nextMilestone),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return FieldPanel(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: WildColors.lichen.withValues(alpha: 0.5),
              ),
              color: WildColors.lichen.withValues(alpha: 0.08),
            ),
            child: Text(
              '${stats.currentStreakDays}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: WildColors.lichen,
                  ),
            ),
          ),
          const SizedBox(width: WildSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dayStreak,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: WildSpace.xxs),
                Text(
                  stats.currentStreakDays == 0
                      ? AppStrings.coldStreakHint
                      : AppStrings.hotStreakHint(stats.longestStreakDays),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBarChart extends StatelessWidget {
  const _TypeBarChart({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final entries = ActivityType.values
        .where((t) => t != ActivityType.other)
        .map((t) => MapEntry(t, stats.sessionsByType[t] ?? 0))
        .where((e) => e.value > 0)
        .toList();

    if (entries.isEmpty) {
      return Center(
        child: Text(
          AppStrings.chartEmpty,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: (maxY + 1).toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: WildColors.trail,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= entries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    entries[i].key.icon,
                    size: 16,
                    color: entries[i].key.color,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < entries.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value.toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.zero,
                  color: entries[i].key.color,
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 450),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});
  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    return FieldPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: WildSpace.xxs),
                Text(
                  record.sessionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${record.value} ${record.unit}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: WildColors.ember,
                ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.milestone});
  final Milestone milestone;

  @override
  Widget build(BuildContext context) {
    return FieldPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            milestone.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: WildColors.lichen,
                ),
          ),
          const SizedBox(height: WildSpace.xs),
          Text(milestone.detail, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: WildSpace.sm),
          ClipRect(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: milestone.ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: WildColors.trail,
                color: WildColors.lichen,
              ),
            ),
          ),
          const SizedBox(height: WildSpace.xs),
          Text(
            '${milestone.progress} of ${milestone.target}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
