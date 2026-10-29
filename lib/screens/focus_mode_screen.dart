import 'dart:async';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confirmation_dialog.dart';

/// Full-screen offline Focus Mode with calming breathing circle,
/// customizable interval timer (5, 10, 15, 25, 45 mins), and completion prompt.
class FocusModeScreen extends StatefulWidget {
  final Habit? initialHabit;
  final HabitProvider provider;

  const FocusModeScreen({
    super.key,
    this.initialHabit,
    required this.provider,
  });

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with SingleTickerProviderStateMixin {
  Habit? _selectedHabit;
  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  final List<int> _durationPresets = [5, 10, 15, 25, 45];

  @override
  void initState() {
    super.initState();
    _selectedHabit = widget.initialHabit ??
        (widget.provider.allHabits.isNotEmpty
            ? widget.provider.allHabits.first
            : null);

    _remainingSeconds = _selectedMinutes * 60;

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        _handleTimerCompletion();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _changeDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
    });
  }

  Future<void> _handleTimerCompletion() async {
    if (_selectedHabit == null) return;

    final habitTitle = _selectedHabit!.title;
    final didComplete = await ConfirmationDialog.show(
      context,
      title: 'Session Complete! 🎉',
      message: 'Great focus! Did you complete your habit "$habitTitle"?',
      confirmLabel: 'Yes, Complete it!',
      cancelLabel: 'Not yet',
    );

    if (didComplete == true && mounted) {
      if (!_selectedHabit!.isCompletedToday()) {
        await widget.provider.toggleHabitCompletion(_selectedHabit!.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Awesome job! "$habitTitle" marked completed.'),
            backgroundColor: AppTheme.primaryMint,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  String _formatTime(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final habits = widget.provider.allHabits;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Focus Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Timer',
            onPressed: _resetTimer,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Habit Selector Card
              if (habits.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Habit>(
                      isExpanded: true,
                      dropdownColor: AppTheme.darkSurfaceVariant,
                      value: _selectedHabit,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textMuted),
                      items: habits.map((h) {
                        return DropdownMenuItem<Habit>(
                          value: h,
                          child: Row(
                            children: [
                              Text(h.emoji, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  h.title,
                                  style: const TextStyle(
                                    color: AppTheme.textMain,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _isRunning
                          ? null
                          : (habit) {
                              if (habit != null) {
                                setState(() {
                                  _selectedHabit = habit;
                                });
                              }
                            },
                    ),
                  ),
                ),
              const Spacer(),

              // Calming Breathing Visual with Countdown
              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  final scale = _isRunning ? _breathingAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryMint.withValues(alpha: _isRunning ? 0.22 : 0.12),
                            AppTheme.accentTeal.withValues(alpha: _isRunning ? 0.08 : 0.02),
                            Colors.transparent,
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                        border: Border.all(
                          color: _isRunning
                              ? AppTheme.primaryMint.withValues(alpha: 0.6)
                              : AppTheme.darkBorder,
                          width: 2,
                        ),
                        boxShadow: [
                          if (_isRunning)
                            BoxShadow(
                              color: AppTheme.primaryMint.withValues(alpha: 0.2),
                              blurRadius: 36,
                              spreadRadius: 4,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedHabit?.emoji ?? '🧘',
                              style: const TextStyle(fontSize: 36),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMain,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isRunning ? 'Breathe & Focus' : 'Ready',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryMint,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),

              // Duration selector pills
              Wrap(
                spacing: 8,
                children: _durationPresets.map((mins) {
                  final isSelected = _selectedMinutes == mins;
                  return ChoiceChip(
                    label: Text('${mins}m'),
                    selected: isSelected,
                    selectedColor: AppTheme.accentTeal.withValues(alpha: 0.25),
                    backgroundColor: AppTheme.darkSurfaceVariant,
                    side: BorderSide(
                      color: isSelected ? AppTheme.accentTeal : AppTheme.darkBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                    ),
                    onSelected: _isRunning
                        ? null
                        : (_) => _changeDuration(mins),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Control Action Button (Start / Pause)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? AppTheme.warningAmber : AppTheme.primaryMint,
                    foregroundColor: const Color(0xFF062A1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    elevation: 4,
                  ),
                  icon: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 24,
                  ),
                  label: Text(
                    _isRunning ? 'Pause Focus' : 'Start Focus Session',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
