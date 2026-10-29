import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import 'category_chip.dart';
import 'streak_badge.dart';

/// Interactive habit card featuring emoji, streak badge, category chip,
/// completion toggle with subtle scale animation, and options menu.
class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStartFocus;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onStartFocus,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleToggleTap() async {
    await _animController.forward();
    widget.onToggle();
    await _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.habit.isCompletedToday();
    final streak = widget.habit.getCurrentStreak();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isDone
              ? AppTheme.darkSurface.withValues(alpha: 0.85)
              : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isDone
                ? AppTheme.primaryMint.withValues(alpha: 0.4)
                : AppTheme.darkBorder,
            width: isDone ? 1.5 : 1,
          ),
          boxShadow: [
            if (isDone)
              BoxShadow(
                color: AppTheme.primaryMint.withValues(alpha: 0.06),
                blurRadius: 16,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            onTap: _handleToggleTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Emoji Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.habit.category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: widget.habit.category.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Habit Title, Category Chip, and Streak
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? AppTheme.textMuted
                                : AppTheme.textMain,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CategoryChip(
                              category: widget.habit.category,
                              compact: true,
                            ),
                            StreakBadge(
                              streak: streak,
                              compact: true,
                            ),
                            if (widget.habit.reminderTime != null &&
                                widget.habit.reminderTime!.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.alarm_rounded,
                                    size: 11,
                                    color: AppTheme.textSubtle,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.habit.reminderTime!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSubtle,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Satisfying completion toggle button
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: GestureDetector(
                      onTap: _handleToggleTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppTheme.primaryMint
                              : Colors.transparent,
                          border: Border.all(
                            color: isDone
                                ? AppTheme.primaryMint
                                : AppTheme.textMuted.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            if (isDone)
                              BoxShadow(
                                color: AppTheme.primaryMint.withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                size: 22,
                                color: Color(0xFF062A1F),
                              )
                            : null,
                      ),
                    ),
                  ),

                  // More options popup menu
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    color: AppTheme.darkSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      side: const BorderSide(color: AppTheme.darkBorder),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'focus':
                          widget.onStartFocus();
                          break;
                        case 'edit':
                          widget.onEdit();
                          break;
                        case 'delete':
                          widget.onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'focus',
                        child: Row(
                          children: [
                            Icon(Icons.timer_rounded,
                                size: 18, color: AppTheme.accentTeal),
                            SizedBox(width: 10),
                            Text('Focus Mode',
                                style: TextStyle(color: AppTheme.textMain)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 18, color: AppTheme.textMain),
                            SizedBox(width: 10),
                            Text('Edit',
                                style: TextStyle(color: AppTheme.textMain)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppTheme.dangerRed),
                            SizedBox(width: 10),
                            Text('Delete',
                                style: TextStyle(color: AppTheme.dangerRed)),
                          ],
                        ),
                      ),
                    ],
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
