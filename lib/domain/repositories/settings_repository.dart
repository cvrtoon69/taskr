abstract class SettingsRepository {
  Future<String?> getUserName();
  Future<void> setUserName(String? name);
  
  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  
  Future<bool> getHapticsEnabled();
  Future<void> setHapticsEnabled(bool enabled);
  
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchComplete();
}
