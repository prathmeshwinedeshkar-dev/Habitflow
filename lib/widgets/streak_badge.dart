import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable badge displaying streak count with subtle fire styling
class StreakBadge extends StatelessWidget {
  final int streak;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.streak,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak > 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: hasStreak
            ? AppTheme.warningAmber.withValues(alpha: 0.12)
            : AppTheme.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color: hasStreak
              ? AppTheme.warningAmber.withValues(alpha: 0.35)
              : AppTheme.darkBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasStreak ? '🔥' : '❄️',
            style: TextStyle(fontSize: compact ? 11 : 13),
          ),
          const SizedBox(width: 4),
          Text(
            streak == 1
                ? '1 day'
                : '$streak ${compact ? "d" : "days"}',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: hasStreak ? AppTheme.warningAmber : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
