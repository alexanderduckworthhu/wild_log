import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/layout/wild_space.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/wild_colors.dart';
import '../../domain/activity_type.dart';

class WildHeader extends StatelessWidget {
  const WildHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WildSpace.lg,
        WildSpace.md,
        WildSpace.lg,
        WildSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: WildSpace.xs),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}

class ActivityBadge extends StatelessWidget {
  const ActivityBadge({super.key, required this.type, this.compact = false});

  final ActivityType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: type.label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? WildSpace.xs : 10,
          vertical: compact ? WildSpace.xxs : 6,
        ),
        decoration: BoxDecoration(
          color: type.color.withValues(alpha: 0.15),
          border: Border.all(color: type.color.withValues(alpha: 0.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: compact ? 14 : 16, color: type.color),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: type.color,
                    fontSize: compact ? 10 : 12,
                    letterSpacing: 1.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultyPips extends StatelessWidget {
  const DifficultyPips({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.difficultySemantics(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(AppConstants.maxDifficulty, (index) {
            final filled = index < value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: filled ? WildColors.sandstone : WildColors.trail,
                border: Border.all(
                  color: filled ? WildColors.sandstone : WildColors.mist,
                  width: 0.5,
                ),
              ),
            );
          }),
          const SizedBox(width: WildSpace.xs),
          Text(
            '$value/${AppConstants.maxDifficulty}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class FieldPanel extends StatelessWidget {
  const FieldPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(WildSpace.md),
    this.onTap,
    this.semanticsLabel,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: WildColors.ridge.withValues(alpha: 0.85),
        border: Border.all(color: WildColors.trail),
      ),
      child: child,
    );
    if (onTap == null) {
      return semanticsLabel == null
          ? panel
          : Semantics(label: semanticsLabel, child: panel);
    }
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          focusColor: WildColors.sage.withValues(alpha: 0.12),
          hoverColor: WildColors.sage.withValues(alpha: 0.08),
          child: panel,
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.accent = WildColors.sage,
  });

  final String label;
  final String value;
  final String? unit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: unit == null ? '$label $value' : '$label $value $unit',
      child: FieldPanel(
        padding: const EdgeInsets.all(WildSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: WildSpace.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: accent,
                          height: 1,
                          fontSize: 22,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WildPrimaryButton extends StatelessWidget {
  const WildPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: WildColors.sage,
          foregroundColor: WildColors.voidBlack,
          disabledBackgroundColor: WildColors.sageDim,
          shape: const RoundedRectangleBorder(),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: WildColors.voidBlack,
                letterSpacing: 1.4,
                fontSize: 15,
              ),
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: WildColors.voidBlack,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: WildSpace.xs),
                  ],
                  Text(label.toUpperCase()),
                ],
              ),
      ),
    );
  }
}

class WildSecondaryButton extends StatelessWidget {
  const WildSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: WildColors.mist,
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: WildColors.mist,
              letterSpacing: 1.2,
            ),
      ),
      child: Text(label.toUpperCase()),
    );
  }
}

class WildStatusMessage extends StatelessWidget {
  const WildStatusMessage({
    super.key,
    required this.title,
    this.body,
    this.icon = Icons.info_outline,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? body;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WildSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: WildColors.sage, size: 28),
            const SizedBox(height: WildSpace.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (body != null) ...[
              const SizedBox(height: WildSpace.xs),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: WildSpace.md),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: WildColors.sage,
                  side: const BorderSide(color: WildColors.sage),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(actionLabel!.toUpperCase()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WildLoading extends StatelessWidget {
  const WildLoading({
    super.key,
    this.message = AppStrings.pullingFieldNotes,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: false,
      child: MergeSemantics(
        child: WildStatusMessage(
          icon: Icons.hourglass_empty_outlined,
          title: message,
        ),
      ),
    );
  }
}

/// Applies a visible focus ring for keyboard / switch-control users.
class WildFocus extends StatelessWidget {
  const WildFocus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasFocus ? WildColors.sage : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Light haptic on primary commit actions (iOS / Android where available).
Future<void> wildCommitFeedback() async {
  await HapticFeedback.lightImpact();
}
