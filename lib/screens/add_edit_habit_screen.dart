import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confirmation_dialog.dart';

/// Screen for creating a new habit or updating an existing one.
/// Implements live validation, duplicate name checking, emoji selection,
/// category chips, daily target selection, and reminder time picker.
class AddEditHabitScreen extends StatefulWidget {
  final Habit? existingHabit;
  final HabitProvider provider;

  const AddEditHabitScreen({
    super.key,
    this.existingHabit,
    required this.provider,
  });

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;

  late String _selectedEmoji;
  late HabitCategory _selectedCategory;
  late int _targetPerDay;
  TimeOfDay? _reminderTime;

  String? _validationError;
  bool _isSaveEnabled = false;

  final List<String> _presetEmojis = [
    '💧', '📚', '🏃', '🧘', '💻', '🎯',
    '🍎', '💤', '🏋️', '✍️', '🌿', '💊',
    '🚴', '🎨', '🧠', '☀️', '🥗', '📝',
  ];

  final List<int> _targetOptions = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    final habit = widget.existingHabit;
    _titleController = TextEditingController(text: habit?.title ?? '');
    _selectedEmoji = habit?.emoji ?? '⚡';
    _selectedCategory = habit?.category ?? HabitCategory.productivity;
    _targetPerDay = habit?.targetPerDay ?? 1;

    if (habit?.reminderTime != null && habit!.reminderTime!.isNotEmpty) {
      _parseReminderTime(habit.reminderTime!);
    }

    _titleController.addListener(_validateInput);
    // Initial validation check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateInput();
    });
  }

  void _parseReminderTime(String formatted) {
    try {
      final parts = formatted.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
        hour += 12;
      } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _titleController.text.trim();
    String? error;

    if (text.isEmpty) {
      error = 'Habit name is required';
    } else if (text.length < 2) {
      error = 'Must be at least 2 characters';
    } else if (text.length > 40) {
      error = 'Maximum 40 characters allowed';
    } else if (widget.provider.isTitleDuplicate(text, widget.existingHabit?.id)) {
      error = 'A habit with this name already exists';
    }

    setState(() {
      _validationError = error;
      _isSaveEnabled = (error == null && text.isNotEmpty);
    });
  }

  Future<void> _pickReminderTime() async {
    final initial = _reminderTime ?? const TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryMint,
              surface: AppTheme.darkSurface,
              onSurface: AppTheme.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _handleSave() async {
    if (!_isSaveEnabled) return;

    final habitTitle = _titleController.text.trim();
    final reminder = _formatTimeOfDay(_reminderTime);

    if (widget.existingHabit != null) {
      final updated = widget.existingHabit!.copyWith(
        title: habitTitle,
        emoji: _selectedEmoji,
        category: _selectedCategory,
        targetPerDay: _targetPerDay,
        reminderTime: reminder,
      );
      await widget.provider.updateHabit(updated);
    } else {
      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: habitTitle,
        emoji: _selectedEmoji,
        category: _selectedCategory,
        targetPerDay: _targetPerDay,
        reminderTime: reminder,
      );
      await widget.provider.addHabit(newHabit);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDelete() async {
    if (widget.existingHabit == null) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Habit?',
      message: 'Are you sure you want to delete "${widget.existingHabit!.title}"? Streak history will be permanently removed.',
      confirmLabel: 'Delete',
      isDangerous: true,
    );

    if (confirmed == true && mounted) {
      await widget.provider.deleteHabit(widget.existingHabit!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingHabit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Tiny Habit'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
              tooltip: 'Delete Habit',
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Habit Title
                const Text(
                  'Habit Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  maxLength: 40,
                  autofocus: !isEditing,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Read 20 pages, Hydrate, Deep work',
                    errorText: _validationError,
                    counterStyle: const TextStyle(color: AppTheme.textSubtle),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        widthFactor: 1,
                        child: Text(_selectedEmoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section: Emoji Picker Preset
                const Text(
                  'Choose Emoji Icon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _presetEmojis.map((emoji) {
                    final isSelected = _selectedEmoji == emoji;
                    return InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryMint.withValues(alpha: 0.2)
                              : AppTheme.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryMint
                                : AppTheme.darkBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Section: Category Selection
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HabitCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    final color = category.color;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, size: 14, color: isSelected ? Colors.white : color),
                          const SizedBox(width: 6),
                          Text(category.displayName),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: color.withValues(alpha: 0.28),
                      backgroundColor: AppTheme.darkSurfaceVariant,
                      side: BorderSide(
                        color: isSelected ? color : AppTheme.darkBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Section: Daily Target
                const Text(
                  'Daily Target',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _targetOptions.map((target) {
                    final isSelected = _targetPerDay == target;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          onTap: () {
                            setState(() {
                              _targetPerDay = target;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.accentTeal.withValues(alpha: 0.18)
                                  : AppTheme.darkSurfaceVariant,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.accentTeal
                                    : AppTheme.darkBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                target == 1 ? '1 time' : '$target times',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Section: Reminder Time
                const Text(
                  'Daily Reminder (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  onTap: _pickReminderTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.alarm_rounded, color: AppTheme.accentTeal, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _reminderTime != null
                                  ? _formatTimeOfDay(_reminderTime)!
                                  : 'No reminder set',
                              style: TextStyle(
                                fontSize: 14,
                                color: _reminderTime != null
                                    ? AppTheme.textMain
                                    : AppTheme.textMuted,
                                fontWeight: _reminderTime != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        if (_reminderTime != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textMuted),
                            onPressed: () {
                              setState(() {
                                _reminderTime = null;
                              });
                            },
                          )
                        else
                          const Text(
                            'Set Time',
                            style: TextStyle(
                              color: AppTheme.primaryMint,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMint,
                      disabledBackgroundColor: AppTheme.darkBorder,
                      foregroundColor: const Color(0xFF062A1F),
                      disabledForegroundColor: AppTheme.textSubtle,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      elevation: _isSaveEnabled ? 4 : 0,
                    ),
                    onPressed: _isSaveEnabled ? _handleSave : null,
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Habit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
