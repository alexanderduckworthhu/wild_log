import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/wild_space.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/wild_colors.dart';
import '../../domain/activity_type.dart';
import '../../providers/providers.dart';
import '../dashboard/dashboard_screen.dart';
import '../logbook/logbook_screen.dart';
import '../map/map_screen.dart';
import '../session/session_form_screen.dart';
import '../shared/wild_widgets.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _tabs = [
    _TabSpec(AppStrings.tabSummit, Icons.insights_outlined),
    _TabSpec(AppStrings.tabLog, Icons.menu_book_outlined),
    _TabSpec(AppStrings.tabMap, Icons.map_outlined),
  ];

  /// Opens the log form; returns after a successful save snackbar.
  Future<void> _openLog(BuildContext context, {ActivityType? type}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SessionFormScreen(initialType: type),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loggedSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(seedProvider);
    final index = ref.watch(shellTabProvider);

    return seed.when(
      loading: () => const Scaffold(
        body: WildLoading(message: AppStrings.warmingFieldKit),
      ),
      error: (error, stack) => Scaffold(
        body: WildStatusMessage(
          icon: Icons.hiking_outlined,
          title: AppStrings.shellLoadErrorTitle,
          body: AppStrings.shellLoadErrorBody,
          actionLabel: AppStrings.retry,
          onAction: () => ref.invalidate(seedProvider),
        ),
      ),
      data: (_) => Scaffold(
        body: IndexedStack(
          index: index,
          children: [
            DashboardScreen(
              onQuickLog: (type) => _openLog(context, type: type),
            ),
            const LogbookScreen(),
            const MapScreen(),
          ],
        ),
        floatingActionButton: Semantics(
          button: true,
          label: AppStrings.logADay,
          child: FloatingActionButton.extended(
            onPressed: () => _openLog(context),
            icon: const Icon(Icons.add),
            label: Text(
              AppStrings.logADay,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WildColors.voidBlack,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: WildColors.trail)),
            color: WildColors.charcoal,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: WildSpace.xs,
                vertical: WildSpace.xs,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: _NavItem(
                        label: _tabs[i].label,
                        icon: _tabs[i].icon,
                        selected: index == i,
                        onTap: () =>
                            ref.read(shellTabProvider.notifier).state = i,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? WildColors.sage : WildColors.mist;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        focusColor: WildColors.sage.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: WildSpace.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.05 : 1,
                duration: const Duration(milliseconds: 180),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: WildSpace.xxs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: WildSpace.xxs),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 2,
                width: selected ? 28 : 0,
                color: WildColors.sage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
