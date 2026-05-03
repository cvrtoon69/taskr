import 'package:flutter/services.dart';
import 'settings_service.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  final SettingsService _settings = SettingsService();

  Future<bool> _isEnabled() async {
    return await _settings.getHapticsEnabled();
  }

  // OEM-safe haptic feedback using HapticFeedback constants only
  Future<void> lightImpact() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selectionClick() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.selectionClick();
  }

  // For task completion - CONFIRM equivalent
  Future<void> confirm() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.mediumImpact();
  }

  // For FAB press - KEYBOARD_TAP equivalent
  Future<void> keyboardTap() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.lightImpact();
  }

  // For long press
  Future<void> longPress() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.heavyImpact();
  }

  // For success actions
  Future<void> success() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  // For error actions
  Future<void> error() async {
    if (!await _isEnabled()) return;
    await HapticFeedback.heavyImpact();
  }
}
