import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/animated_background.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userNameAsync = ref.watch(userNameProvider);
    final notificationsAsync = ref.watch(notificationsEnabledProvider);
    final hapticsAsync = ref.watch(hapticsEnabledProvider);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Settings'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Personalization Section
              _buildSectionTitle('Personalization'),
              const SizedBox(height: 12),
              _buildCard(
                child: userNameAsync.when(
                  data: (userName) => _buildNameField(context, ref, userName),
                  loading: () => const SizedBox(
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                  error: (_, __) => _buildNameField(context, ref, null),
                ),
              ),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionTitle('Notifications'),
              const SizedBox(height: 12),
              _buildCard(
                child: notificationsAsync.when(
                  data: (enabled) => _buildToggleTile(
                    title: 'Enable Notifications',
                    subtitle: 'Get reminded about your tasks',
                    value: enabled,
                    onChanged: (value) => _setNotificationsEnabled(ref, value),
                  ),
                  loading: () => const SizedBox(height: 56),
                  error: (_, __) => _buildToggleTile(
                    title: 'Enable Notifications',
                    subtitle: 'Get reminded about your tasks',
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Haptics Section
              _buildSectionTitle('Haptics & Vibration'),
              const SizedBox(height: 12),
              _buildCard(
                child: hapticsAsync.when(
                  data: (enabled) => _buildToggleTile(
                    title: 'Enable Haptics',
                    subtitle: 'Feel feedback when interacting',
                    value: enabled,
                    onChanged: (value) => _setHapticsEnabled(ref, value),
                  ),
                  loading: () => const SizedBox(height: 56),
                  error: (_, __) => _buildToggleTile(
                    title: 'Enable Haptics',
                    subtitle: 'Feel feedback when interacting',
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // About Section
              _buildSectionTitle('About'),
              const SizedBox(height: 12),
              _buildCard(
                child: _buildAboutSection(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: child,
    );
  }

  Widget _buildNameField(BuildContext context, WidgetRef ref, String? userName) {
    final controller = TextEditingController(text: userName ?? '');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter your first name',
              hintStyle: TextStyle(color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        controller.clear();
                        _setUserName(ref, null);
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              _setUserName(ref, value.isEmpty ? null : value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.accent,
      activeTrackColor: AppColors.accent.withOpacity(0.3),
      inactiveThumbColor: AppColors.textDisabled,
      inactiveTrackColor: AppColors.surfaceVariant,
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          // App Name
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Tagline
          Text(
            AppConstants.tagline,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Version
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 16),
          // Contact
          TextButton(
            onPressed: () {
              // Open email app
            },
            child: const Text(
              AppConstants.contactEmail,
              style: TextStyle(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 16),
          // Made with love
          Text(
            'Made with ❤️ by Rizowan',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setUserName(WidgetRef ref, String? name) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setUserName(name);
    ref.invalidate(userNameProvider);
  }

  Future<void> _setNotificationsEnabled(WidgetRef ref, bool enabled) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setNotificationsEnabled(enabled);
    
    if (!enabled) {
      // Cancel all notifications when disabled
      final notificationService = NotificationService();
      await notificationService.cancelAllNotifications();
    }
    
    ref.invalidate(notificationsEnabledProvider);
  }

  Future<void> _setHapticsEnabled(WidgetRef ref, bool enabled) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setHapticsEnabled(enabled);
    ref.invalidate(hapticsEnabledProvider);
  }
}
