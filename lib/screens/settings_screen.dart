import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confirmation_dialog.dart';

/// Settings and preferences screen including theme switch, user name editing,
/// offline data export, data reset, and privacy transparency note.
class SettingsScreen extends StatelessWidget {
  final HabitProvider provider;

  const SettingsScreen({super.key, required this.provider});

  Future<void> _editUserName(BuildContext context) async {
    final controller = TextEditingController(text: provider.userName);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Name / Nickname'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLength: 24,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter name for greetings',
              counterStyle: TextStyle(color: AppTheme.textSubtle),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await provider.setUserName(result);
    }
  }

  Future<void> _exportData(BuildContext context) async {
    final jsonText = await provider.exportDataAsJson();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.code_rounded, color: AppTheme.primaryMint),
            SizedBox(width: 8),
            Text('Export Habits JSON'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonText,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppTheme.textMain,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy to Clipboard'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonText));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Habit data copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Reset All Habits?',
      message:
          'This will permanently delete all your habits, completed dates, streaks, and preferences. This action cannot be undone.',
      confirmLabel: 'Reset Everything',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      await provider.resetAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset.'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Preference Section Header
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppTheme.textSubtle,
                ),
              ),
            ),

            // Dark Mode Switch Tile
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMain,
                      ),
                    ),
                    subtitle: const Text(
                      'Deep dark palette (#0B0F14)',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    secondary: const Icon(
                      Icons.dark_mode_rounded,
                      color: AppTheme.primaryMint,
                    ),
                    activeTrackColor: AppTheme.primaryMint,
                    activeThumbColor: Colors.white,
                    value: provider.isDarkMode,
                    onChanged: (val) => provider.toggleTheme(val),
                  ),
                  const Divider(height: 1, color: AppTheme.darkBorder),
                  ListTile(
                    title: const Text(
                      'Your Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMain,
                      ),
                    ),
                    subtitle: Text(
                      provider.userName,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textMuted),
                    ),
                    leading: const Icon(
                      Icons.badge_rounded,
                      color: AppTheme.accentTeal,
                    ),
                    trailing: const Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () => _editUserName(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data & Backup Header
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'DATA & BACKUP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppTheme.textSubtle,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Export Habits as JSON',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMain,
                      ),
                    ),
                    subtitle: const Text(
                      'View and copy your offline habit records',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    leading: const Icon(
                      Icons.file_download_outlined,
                      color: AppTheme.secondaryViolet,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () => _exportData(context),
                  ),
                  const Divider(height: 1, color: AppTheme.darkBorder),
                  ListTile(
                    title: const Text(
                      'Reset All Data',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dangerRed,
                      ),
                    ),
                    subtitle: const Text(
                      'Permanently clear all habits and streaks',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    leading: const Icon(
                      Icons.delete_forever_rounded,
                      color: AppTheme.dangerRed,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () => _resetAllData(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'PRIVACY & ETHICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppTheme.textSubtle,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: AppTheme.primaryMint,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'HabitFlow does not collect, share, or transmit your personal data. Your habits, streaks, and preferences are stored only on your device. You can delete all data anytime from Settings.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About HabitFlow
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryMint.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Center(
                      child: Text('🌱', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'HabitFlow',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Version 1.0.0 • Offline-First Daily Habit Tracker',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSubtle,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
