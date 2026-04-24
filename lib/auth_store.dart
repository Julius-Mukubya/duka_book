import 'package:flutter/foundation.dart';

class _User {
  final String name;
  final String email;
  final String password;
  _User({required this.name, required this.email, required this.password});
}

class AuthStore extends ChangeNotifier {
  AuthStore._();
  static final instance = AuthStore._();

  // Demo credentials — admin@dukabook.com / duka1234
  final List<_User> _users = [
    _User(name: 'Admin', email: 'admin@dukabook.com', password: 'duka1234'),
  ];
  _User? _current;

  bool get isSignedIn => _current != null;
  String get currentName => _current?.name ?? '';

  /// Returns an error string, or null on success.
  String? signIn(String email, String password) {
    if (email.isEmpty || password.isEmpty) return 'Please fill in all fields.';
    final user = _users.where(
      (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
    ).firstOrNull;
    if (user == null) return 'Invalid email or password.';
    _current = user;
    notifyListeners();
    return null;
  }

  void signOut() {
    _current = null;
    notifyListeners();
  }
}
