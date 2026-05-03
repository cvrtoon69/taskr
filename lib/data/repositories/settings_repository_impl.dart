import '../../core/services/settings_service.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsService _settingsService;

  SettingsRepositoryImpl(this._settingsService);

  @override
  Future<String?> getUserName() => _settingsService.getUserName();

  @override
  Future<void> setUserName(String? name) => _settingsService.setUserName(name);

  @override
  Future<bool> getNotificationsEnabled() => _settingsService.getNotificationsEnabled();

  @override
  Future<void> setNotificationsEnabled(bool enabled) => _settingsService.setNotificationsEnabled(enabled);

  @override
  Future<bool> getHapticsEnabled() => _settingsService.getHapticsEnabled();

  @override
  Future<void> setHapticsEnabled(bool enabled) => _settingsService.setHapticsEnabled(enabled);

  @override
  Future<bool> isFirstLaunch() => _settingsService.isFirstLaunch();

  @override
  Future<void> setFirstLaunchComplete() => _settingsService.setFirstLaunchComplete();
}
