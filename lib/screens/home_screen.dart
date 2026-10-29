import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_ring.dart';
import 'add_edit_habit_screen.dart';
import 'focus_mode_screen.dart';

/// The primary Home dashboard displaying daily greeting, date,
/// progress ring, habit counters, category filter pills, and habit cards.
class HomeScreen extends StatelessWidget {
  final HabitProvider provider;

  const HomeScreen({super.key, required this.provider});

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _openAddHabit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditHabitScreen(provider: provider),
      ),
    );
  }

  void _openEditHabit(BuildContext context, Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditHabitScreen(
          existingHabit: habit,
          provider: provider,
        ),
      ),
    );
  }

  void _openFocusMode(BuildContext context, Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FocusModeScreen(
          initialHabit: habit,
          provider: provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryMint),
        ),
      );
    }

    final todayFormatted = DateFormat('EEEE, MMM d').format(DateTime.now());
    final habits = provider.habits;
    final total = provider.totalHabitsCount;
    final completed = provider.completedTodayCount;
    final rate = provider.todayCompletionRate;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Greeting and Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getTimeGreeting()}, ${provider.userName}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayFormatted,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Quick Focus Mode Button
                    if (provider.allHabits.isNotEmpty)
                      IconButton.filledTonal(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FocusModeScreen(provider: provider),
                            ),
                          );
                        },
                        icon: const Icon(Icons.timer_rounded, size: 20),
                        tooltip: 'Focus Mode',
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.darkSurfaceVariant,
                          foregroundColor: AppTheme.accentTeal,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Daily Progress Summary Card
            if (total > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.darkSurface,
                          AppTheme.darkSurfaceVariant.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      children: [
                        ProgressRing(
                          progress: rate,
                          size: 74,
                          strokeWidth: 8,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$completed of $total completed',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                provider.motivationalMessage,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primaryMint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Category Filter Tab Row
            if (provider.allHabits.isNotEmpty)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // All Filter Pill
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: provider.selectedCategoryFilter == null,
                          selectedColor: AppTheme.primaryMint.withValues(alpha: 0.2),
                          backgroundColor: AppTheme.darkSurfaceVariant,
                          side: BorderSide(
                            color: provider.selectedCategoryFilter == null
                                ? AppTheme.primaryMint
                                : AppTheme.darkBorder,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: provider.selectedCategoryFilter == null
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: provider.selectedCategoryFilter == null
                                ? AppTheme.primaryMint
                                : AppTheme.textMuted,
                          ),
                          onSelected: (_) => provider.setCategoryFilter(null),
                        ),
                      ),
                      ...HabitCategory.values.map((category) {
                        final isSelected =
                            provider.selectedCategoryFilter == category;
                        final color = category.color;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(category.icon,
                                    size: 13,
                                    color: isSelected ? Colors.white : color),
                                const SizedBox(width: 4),
                                Text(category.displayName),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: color.withValues(alpha: 0.25),
                            backgroundColor: AppTheme.darkSurfaceVariant,
                            side: BorderSide(
                              color: isSelected ? color : AppTheme.darkBorder,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.textMuted,
                            ),
                            onSelected: (_) =>
                                provider.setCategoryFilter(category),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

            // Habit List or Empty State
            if (provider.allHabits.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  onAddHabit: () => _openAddHabit(context),
                ),
              )
            else if (habits.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 12),
                        const Text(
                          'No habits in this category.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => provider.setCategoryFilter(null),
                          child: const Text('Show all habits'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 96),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = habits[index];
                      return HabitCard(
                        key: ValueKey(habit.id),
                        habit: habit,
                        onToggle: () async {
                          final wasCompleted = habit.isCompletedToday();
                          await provider.toggleHabitCompletion(habit.id);
                          if (!wasCompleted && context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Great work on "${habit.title}"! 🔥',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        onEdit: () => _openEditHabit(context, habit),
                        onDelete: () => provider.deleteHabit(habit.id),
                        onStartFocus: () => _openFocusMode(context, habit),
                      );
                    },
                    childCount: habits.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddHabit(context),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'New Habit',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
