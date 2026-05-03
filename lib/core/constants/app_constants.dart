class AppConstants {
  AppConstants._();

  static const String appName = 'Taskr';
  static const String tagline = 'Plan. Do. Done.';
  static const String contactEmail = 'rizowan@example.com';
  
  // Storage keys
  static const String prefUserName = 'user_name';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefHapticsEnabled = 'haptics_enabled';
  static const String prefFirstLaunch = 'first_launch';
  
  // Animation durations (milliseconds)
  static const int animMicro = 150;
  static const int animShort = 200;
  static const int animMedium = 300;
  static const int animCard = 350;
  static const int animStagger = 40;
  
  // Notification
  static const String notificationChannelId = 'taskr_reminders';
  static const String notificationChannelName = 'Task Reminders';
  static const String notificationChannelDesc = 'Notifications for task reminders';
}
