import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // User name
  Future<String?> getUserName() async {
    final prefs = await _getPrefs;
    return prefs.getString(AppConstants.prefUserName);
  }

  Future<void> setUserName(String? name) async {
    final prefs = await _getPrefs;
    if (name == null || name.isEmpty) {
      await prefs.remove(AppConstants.prefUserName);
    } else {
      await prefs.setString(AppConstants.prefUserName, name);
    }
  }

  // Notifications enabled
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _getPrefs;
    return prefs.getBool(AppConstants.prefNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _getPrefs;
    await prefs.setBool(AppConstants.prefNotificationsEnabled, enabled);
  }

  // Haptics enabled
  Future<bool> getHapticsEnabled() async {
    final prefs = await _getPrefs;
    return prefs.getBool(AppConstants.prefHapticsEnabled) ?? true;
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final prefs = await _getPrefs;
    await prefs.setBool(AppConstants.prefHapticsEnabled, enabled);
  }

  // First launch
  Future<bool> isFirstLaunch() async {
    final prefs = await _getPrefs;
    return prefs.getBool(AppConstants.prefFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await _getPrefs;
    await prefs.setBool(AppConstants.prefFirstLaunch, false);
  }
}
