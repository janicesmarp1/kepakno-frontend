import 'package:flutter/material.dart';

enum AppLanguage { indonesian, english }

enum AddressMode { manual, currentLocation }

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  ThemeMode _themeMode = ThemeMode.light;
  AppLanguage _language = AppLanguage.indonesian;
  AddressMode _addressMode = AddressMode.manual;
  String _manualAddress = '';
  String _currentLocationAddress = '';

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  AddressMode get addressMode => _addressMode;
  String get manualAddress => _manualAddress;
  String get currentLocationAddress => _currentLocationAddress;

  Locale get locale {
    return _language == AppLanguage.english
        ? const Locale('en')
        : const Locale('id');
  }

  String get address {
    if (_addressMode == AddressMode.currentLocation) {
      return _currentLocationAddress.isEmpty
          ? 'Lokasi HP belum dipilih'
          : _currentLocationAddress;
    }

    return _manualAddress.isEmpty ? 'Alamat belum diisi' : _manualAddress;
  }

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  void setLanguage(AppLanguage value) {
    if (_language == value) return;
    _language = value;
    notifyListeners();
  }

  void setManualAddress(String value) {
    _addressMode = AddressMode.manual;
    _manualAddress = value.trim();
    notifyListeners();
  }

  void setCurrentLocationAddress(String value) {
    _addressMode = AddressMode.currentLocation;
    _currentLocationAddress = value.trim();
    notifyListeners();
  }
}
