import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  dark,
  light;

  static AppThemeMode fromStorage(String? value) => switch (value) {
        'light' => AppThemeMode.light,
        _ => AppThemeMode.dark,
      };

  String get storageValue => name;
}

class SettingsStorageService {
  static const _themeKey = 'app_theme_mode';

  Future<AppThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return AppThemeMode.fromStorage(prefs.getString(_themeKey));
  }

  Future<void> saveThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.storageValue);
  }
}
