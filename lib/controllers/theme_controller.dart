import 'package:flutter/material.dart';
import 'package:hello_flutter/services/settings_storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._settingsStorage);

  final SettingsStorageService _settingsStorage;

  AppThemeMode _mode = AppThemeMode.dark;

  AppThemeMode get mode => _mode;
  ThemeMode get themeMode =>
      _mode == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark;

  Future<void> load() async {
    _mode = await _settingsStorage.loadThemeMode();
    notifyListeners();
  }

  Future<void> setDarkTheme() async {
    await _setMode(AppThemeMode.dark);
  }

  Future<void> setLightTheme() async {
    await _setMode(AppThemeMode.light);
  }

  Future<void> _setMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await _settingsStorage.saveThemeMode(mode);
  }
}
