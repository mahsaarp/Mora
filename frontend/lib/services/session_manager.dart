class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  int? userId;
  String? username;

  void setUser(int id, String name) {
    userId = id;
    username = name;
  }

  void clear() {
    userId = null;
    username = null;
  }
}