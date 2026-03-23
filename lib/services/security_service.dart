import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();
  
  bool _biometricEnabled = false;
  bool _appPasswordEnabled = false;
  bool _isLocked = false;
  
  bool get biometricEnabled => _biometricEnabled;
  bool get appPasswordEnabled => _appPasswordEnabled;
  bool get isLocked => _isLocked;

  SecurityProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _appPasswordEnabled = prefs.getBool('app_password_enabled') ?? false;
    
    // If app password is enabled, we start locked
    if (_appPasswordEnabled) {
      _isLocked = true;
    }
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = value;
    await prefs.setBool('biometric_enabled', value);
    notifyListeners();
  }

  Future<void> setAppPasswordEnabled(bool value, {String? pin}) async {
    final prefs = await SharedPreferences.getInstance();
    _appPasswordEnabled = value;
    await prefs.setBool('app_password_enabled', value);
    
    if (value && pin != null) {
      await _storage.write(key: 'app_pin', value: pin);
    } else if (!value) {
      await _storage.delete(key: 'app_pin');
    }
    
    notifyListeners();
  }

  Future<bool> authenticateBiometric() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return false;

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        _isLocked = false;
        notifyListeners();
      }
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await _storage.read(key: 'app_pin');
    if (savedPin == pin) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lock() {
    if (_appPasswordEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  void unlock() {
    _isLocked = false;
    notifyListeners();
  }
}
