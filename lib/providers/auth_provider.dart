import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  UserModel? _user;
  String?    _token;
  bool       _loading = false;
  String?    _error;

  UserModel? get user    => _user;
  String?    get token   => _token;
  bool       get loading => _loading;
  String?    get error   => _error;
  bool       get isLoggedIn => _token != null;

  // ── Restore session on app start ─────────────────────────────
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken != null) {
      _token = savedToken;
      _api.setToken(savedToken);
      notifyListeners();
    }
  }

  // ── Login ────────────────────────────────────────────────────
  Future<bool> login(String identifier, String password) async {
    _setLoading(true);
    try {
      final res  = await _api.login(identifier, password);
      final data = res['data'] as Map<String, dynamic>;
      await _saveSession(data);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Register ─────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    String? email,
    String? mobile,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final res  = await _api.register(
          name: name, email: email, mobile: mobile, password: password);
      final data = res['data'] as Map<String, dynamic>;
      await _saveSession(data);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _user  = null;
    _api.setToken(null);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  ApiService get apiService => _api;

  // ── Helpers ──────────────────────────────────────────────────
  Future<void> _saveSession(Map<String, dynamic> data) async {
    _token = data['token'] as String;
    _user  = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    _api.setToken(_token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token!);
    notifyListeners();
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
