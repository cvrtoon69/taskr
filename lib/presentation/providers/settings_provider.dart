import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/settings_service.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return SettingsRepositoryImpl(settingsService);
});

final userNameProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.getUserName();
});

final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.getNotificationsEnabled();
});

final hapticsEnabledProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.getHapticsEnabled();
});

final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good morning';
  } else if (hour < 17) {
    return 'Good afternoon';
  } else {
    return 'Good evening';
  }
});
