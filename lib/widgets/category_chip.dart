import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

/// Pill-style chip displaying category name, icon, and signature color
class CategoryChip extends StatelessWidget {
  final HabitCategory category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 3 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? catColor.withValues(alpha: 0.2)
              : catColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: isSelected ? catColor : catColor.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: compact ? 12 : 14,
              color: catColor,
            ),
            const SizedBox(width: 4),
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : catColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
