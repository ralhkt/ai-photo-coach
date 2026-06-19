import 'package:flutter/material.dart';

import '../theme/app_design_tokens.dart';
import '../theme/app_theme.dart';

/// Capsule step progress — quiet, no numbered circles.
class AppFlowStrip extends StatelessWidget {
  const AppFlowStrip({
    super.key,
    required this.steps,
    required this.activeIndex,
  });

  final List<String> steps;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: AppDesignTokens.hairline,
                    color: i <= activeIndex
                        ? AppDesignTokens.accentCoach.withValues(alpha: 0.5)
                        : AppDesignTokens.separator,
                  ),
                ),
              _CapsuleDot(
                active: i == activeIndex,
                completed: i < activeIndex,
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: AppDesignTokens.hairline,
                    color: i < activeIndex
                        ? AppDesignTokens.accentCoach.withValues(alpha: 0.5)
                        : AppDesignTokens.separator,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: AppDesignTokens.spaceSm),
        Text(
          steps[activeIndex.clamp(0, steps.length - 1)],
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppDesignTokens.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CapsuleDot extends StatelessWidget {
  const _CapsuleDot({required this.active, required this.completed});

  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDesignTokens.motionMedium,
      curve: AppDesignTokens.motionEaseOut,
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed || active
            ? AppDesignTokens.accentCoach
            : AppDesignTokens.fillSecondary,
      ),
    );
  }
}

/// iOS Settings–style inset grouped list.
class AppGroupedSection extends StatelessWidget {
  const AppGroupedSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });

  final String? header;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppDesignTokens.spaceLg,
              bottom: AppDesignTokens.spaceSm,
            ),
            child: Text(
              header!.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 0.6,
                color: AppDesignTokens.textTertiary,
              ),
            ),
          ),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppDesignTokens.fillTertiary,
            borderRadius: AppDesignTokens.cardRadius,
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(
                    height: AppDesignTokens.hairline,
                    indent: 52,
                  ),
              ],
            ],
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: AppDesignTokens.spaceSm),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignTokens.spaceLg,
            ),
            child: Text(
              footer!,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}

/// Single row inside [AppGroupedSection].
class AppGroupedRow extends StatelessWidget {
  const AppGroupedRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.tertiary = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool tertiary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDesignTokens.cardRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignTokens.spaceLg,
            vertical: AppDesignTokens.spaceLg,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 22,
                  color: tertiary
                      ? AppDesignTokens.textQuaternary
                      : AppDesignTokens.textSecondary,
                ),
                const SizedBox(width: AppDesignTokens.spaceMd),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tertiary
                          ? theme.textTheme.bodyLarge?.copyWith(
                              color: AppDesignTokens.textSecondary,
                            )
                          : theme.textTheme.titleSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tertiary
                              ? AppDesignTokens.textTertiary
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showChevron && onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppDesignTokens.textQuaternary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Primary hero card — yellow reserved for the embedded CTA button only.
class AppHeroCard extends StatelessWidget {
  const AppHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onPressed,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onPressed;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppDesignTokens.fillTertiary,
        borderRadius: AppDesignTokens.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (badge != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spaceSm,
                    vertical: AppDesignTokens.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.accentCoach.withValues(alpha: 0.18),
                    borderRadius:
                        BorderRadius.circular(AppDesignTokens.radiusPill),
                  ),
                  child: Text(
                    badge!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppDesignTokens.accentCoach,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            if (badge != null) const SizedBox(height: AppDesignTokens.spaceMd),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDesignTokens.spaceXs),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppDesignTokens.textSecondary,
              ),
            ),
            const SizedBox(height: AppDesignTokens.spaceLg),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// @deprecated Use [AppGroupedRow] — kept for gradual migration.
class AppActionCard extends StatelessWidget {
  const AppActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return AppGroupedRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spaceSm,
                vertical: AppDesignTokens.spaceXs,
              ),
              decoration: BoxDecoration(
                color: emphasized
                    ? AppTheme.accent.withValues(alpha: 0.18)
                    : AppDesignTokens.fillQuaternary,
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: emphasized ? AppTheme.accent : AppDesignTokens.textTertiary,
                ),
              ),
            )
          : null,
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppDesignTokens.spaceXs),
          Text(subtitle!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class AppSummaryCard extends StatelessWidget {
  const AppSummaryCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.chips = const [],
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: AppDesignTokens.fillTertiary,
        borderRadius: AppDesignTokens.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: AppDesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.spaceXs),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: AppDesignTokens.spaceMd),
            Wrap(
              spacing: AppDesignTokens.spaceSm,
              runSpacing: AppDesignTokens.spaceSm,
              children: chips
                  .map(
                    (chip) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spaceMd,
                        vertical: AppDesignTokens.spaceXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.fillQuaternary,
                        borderRadius: AppDesignTokens.chipRadius,
                      ),
                      child: Text(
                        chip,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppDesignTokens.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class AppStickyCtaBar extends StatelessWidget {
  const AppStickyCtaBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
          ],
          stops: const [0.55, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDesignTokens.screenPadding,
            AppDesignTokens.spaceMd,
            AppDesignTokens.screenPadding,
            AppDesignTokens.spaceLg,
          ),
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          ),
        ),
      ),
    );
  }
}

class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppGroupedRow(
      icon: icon,
      title: title,
      subtitle: value,
      showChevron: false,
    );
  }
}

/// Segmented scene picker — iOS capsule style.
class AppSegmentedPicker<T> extends StatelessWidget {
  const AppSegmentedPicker({
    super.key,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> items;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppDesignTokens.fillQuaternary,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(3),
        child: Row(
          children: items.map((item) {
            final isSelected = item == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: GestureDetector(
                onTap: () => onSelected(item),
                child: AnimatedContainer(
                  duration: AppDesignTokens.motionFast,
                  curve: AppDesignTokens.motionEaseOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppDesignTokens.fillPrimary
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppDesignTokens.radiusPill),
                  ),
                  child: Text(
                    labelBuilder(item),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppDesignTokens.textPrimary
                          : AppDesignTokens.textTertiary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}