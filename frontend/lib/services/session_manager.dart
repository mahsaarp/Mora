import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  int? userId;
  String? username;

  Future<bool> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    username = prefs.getString('username');
    return userId != null && username != null;
  }

  Future<void> setUser(int id, String name) async {
    userId = id;
    username = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
    await prefs.setString('username', name);
  }

  Future<void> clear() async {
    userId = null;
    username = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
  }
}