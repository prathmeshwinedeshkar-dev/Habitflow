import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/streak_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/progress_ring.dart';
import '../widgets/streak_badge.dart';

/// Analytics and Insights dashboard displaying weekly completion chart,
/// key metrics, habit highlights, category breakdown, and the Tomorrow Simulator.
class InsightsScreen extends StatefulWidget {
  final HabitProvider provider;

  const InsightsScreen({super.key, required this.provider});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  Habit? _simulatorHabit;
  double _simulatorDays = 21.0;

  @override
  void initState() {
    super.initState();
    if (widget.provider.allHabits.isNotEmpty) {
      _simulatorHabit = widget.provider.allHabits.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final habits = provider.allHabits;

    if (habits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insights & Analytics')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📊', style: TextStyle(fontSize: 48)),
                SizedBox(height: 16),
                Text(
                  'No analytics available yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add habits and mark daily progress to unlock your habit trends and insights.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Keep simulator habit updated if deleted
    if (_simulatorHabit == null ||
        !habits.any((h) => h.id == _simulatorHabit!.id)) {
      _simulatorHabit = habits.first;
    }

    final todayRate = provider.todayCompletionRate;
    final totalCompletions = provider.totalCompletionsAllTime;
    final longestStreak = provider.longestStreakAcrossHabits;
    final bestHabit = provider.bestHabit;
    final attentionHabit = provider.habitNeedingAttention;
    final categoryRates = provider.categoryCompletionRates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Insights'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Completion Rate Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    ProgressRing(
                      progress: todayRate,
                      size: 68,
                      strokeWidth: 7,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Completion Rate",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(todayRate * 100).toInt()}% Complete',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${provider.completedTodayCount} of ${provider.totalHabitsCount} habits done today',
                            style: const TextStyle(
                              fontSize: 12,
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
              const SizedBox(height: 14),

              // Summary Stat Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Total Wins',
                      value: '$totalCompletions',
                      subtitle: 'All-time completions',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppTheme.primaryMint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Top Streak',
                      value: '$longestStreak d',
                      subtitle: 'Consecutive days',
                      icon: Icons.local_fire_department_rounded,
                      color: AppTheme.warningAmber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weekly Activity Bar Chart
              _buildWeeklyChartCard(habits),
              const SizedBox(height: 16),

              // Habit Highlights: Best Habit & Habit Needing Attention
              if (bestHabit != null)
                _buildHighlightCard(
                  title: 'Star Habit 🌟',
                  habit: bestHabit,
                  caption:
                      'Leading with ${bestHabit.getCurrentStreak()}-day streak and ${bestHabit.getBestStreak()} best record.',
                  borderColor: AppTheme.primaryMint,
                ),
              if (attentionHabit != null &&
                  attentionHabit.id != bestHabit?.id) ...[
                const SizedBox(height: 12),
                _buildHighlightCard(
                  title: 'Needs a Little Boost 🌱',
                  habit: attentionHabit,
                  caption:
                      'Missed today or below average. One small action restarts momentum!',
                  borderColor: AppTheme.warningAmber,
                ),
              ],
              const SizedBox(height: 20),

              // Category-wise Breakdown
              const Text(
                'Category Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMain,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: categoryRates.isEmpty
                    ? const Text(
                        'No category data available.',
                        style: TextStyle(color: AppTheme.textMuted),
                      )
                    : Column(
                        children: categoryRates.entries.map((entry) {
                          final cat = entry.key;
                          final rate = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(cat.icon,
                                            size: 14, color: cat.color),
                                        const SizedBox(width: 6),
                                        Text(
                                          cat.displayName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textMain,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${(rate * 100).toInt()}% today',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: cat.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: rate,
                                    minHeight: 6,
                                    backgroundColor: AppTheme.darkSurfaceVariant,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(cat.color),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Tomorrow / Habit Impact Simulator
              _buildSimulatorSection(habits),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSubtle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard(List<Habit> habits) {
    final now = DateTime.now();
    final days = <DateTime>[];
    for (int i = 6; i >= 0; i--) {
      days.add(now.subtract(Duration(days: i)));
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last 7 Days Consistency',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMain,
                ),
              ),
              Text(
                'Weekly Trend',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryMint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((day) {
              final isToday = day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;
              final dayName = DateFormat('E').format(day).substring(0, 1);

              // Calculate habits completed on this specific day
              final normDay = DateTime(day.year, day.month, day.day);
              int completedOnDay = 0;
              for (final h in habits) {
                if (h.completionDates.any((d) =>
                    d.year == normDay.year &&
                    d.month == normDay.month &&
                    d.day == normDay.day)) {
                  completedOnDay++;
                }
              }

              final double fraction =
                  habits.isEmpty ? 0.0 : (completedOnDay / habits.length).clamp(0.0, 1.0);
              const double maxBarHeight = 80.0;
              final double barHeight = (fraction * maxBarHeight).clamp(6.0, maxBarHeight);

              return Column(
                children: [
                  Text(
                    '$completedOnDay',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppTheme.primaryMint : AppTheme.textSubtle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 24,
                    height: maxBarHeight,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 14,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppTheme.primaryMint
                            : (fraction > 0
                                ? AppTheme.accentTeal.withValues(alpha: 0.65)
                                : AppTheme.darkSurfaceVariant),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday ? AppTheme.primaryMint : AppTheme.textMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required String title,
    required Habit habit,
    required String caption,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: borderColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: borderColor,
                ),
              ),
              StreakBadge(streak: habit.getCurrentStreak(), compact: true),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(habit.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
              ),
              CategoryChip(category: habit.category, compact: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorSection(List<Habit> habits) {
    if (_simulatorHabit == null) return const SizedBox.shrink();

    final days = _simulatorDays.round();
    final projection = StreakService.projectHabitImpact(_simulatorHabit!, days);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface,
            AppTheme.secondaryViolet.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.secondaryViolet.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded,
                  color: AppTheme.secondaryViolet, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Habit Impact Simulator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'See what happens when you commit daily. Slide to project your future streak growth.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),

          // Habit Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Habit>(
                isExpanded: true,
                dropdownColor: AppTheme.darkSurfaceVariant,
                value: _simulatorHabit,
                items: habits.map((h) {
                  return DropdownMenuItem<Habit>(
                    value: h,
                    child: Text(
                      '${h.emoji}  ${h.title}',
                      style: const TextStyle(
                        color: AppTheme.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _simulatorHabit = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Slider for Days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projection: $days Days',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryViolet,
                ),
              ),
              Text(
                'Stage: ${projection['growthEmoji']} ${projection['growthStage']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
          Slider(
            value: _simulatorDays,
            min: 7,
            max: 90,
            divisions: 83,
            activeColor: AppTheme.secondaryViolet,
            inactiveColor: AppTheme.darkBorder,
            onChanged: (val) {
              setState(() {
                _simulatorDays = val;
              });
            },
          ),

          // Result Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.darkSurfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${projection['projectedStreak']} days',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryMint,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Projected Streak',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSubtle),
                        ),
                      ],
                    ),
                    Container(
                        width: 1, height: 32, color: AppTheme.darkBorder),
                    Column(
                      children: [
                        Text(
                          '+$days reps',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentTeal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Total Actions Added',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSubtle),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  projection['message'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '* Motivational simulation. Real habits take daily consistency.',
            style: TextStyle(fontSize: 10, color: AppTheme.textSubtle),
          ),
        ],
      ),
    );
  }
}
