import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  int? userId;
  String? username;
  String? displayName;

  Future<bool> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    username = prefs.getString('username');
    displayName = prefs.getString('displayName') ?? username;
    return userId != null && username != null;
  }

  Future<void> setUser(int id, String name, {String? displayNameValue}) async {
    userId = id;
    username = name;
    displayName = (displayNameValue != null && displayNameValue.trim().isNotEmpty) ? displayNameValue.trim() : name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
    await prefs.setString('username', name);
    await prefs.setString('displayName', displayName ?? name);
  }

  Future<void> clear() async {
    userId = null;
    username = null;
    displayName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('displayName');
  }
}