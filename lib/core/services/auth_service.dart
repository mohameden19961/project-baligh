import 'dart:async';

import '../../utils/supabase_config.dart';
import '../database/user_dao.dart';
import '../models/user_model.dart';

class AuthService {
  final UserDao _userDao = UserDao();

  Future<UserModel?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final existing = await _userDao
          .findByUsername(username)
          .timeout(const Duration(seconds: 10));
      if (existing != null) return null;

      final emailExists = await _userDao
          .findByEmail(email)
          .timeout(const Duration(seconds: 10));
      if (emailExists != null) return null;

      final response = await SupabaseConfig.client.auth
          .signUp(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      final user = response.user;
      if (user == null) return null;

      final newUser = UserModel(
        id: user.id,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );

      await _userDao.insert(newUser).timeout(const Duration(seconds: 10));
      return newUser;
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await SupabaseConfig.client.auth
          .signInWithPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      final user = response.user;
      if (user == null) return null;

      final profile =
          await _userDao.getById(user.id).timeout(const Duration(seconds: 10));
      return profile;
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<void> logout() async {
    await SupabaseConfig.client.auth.signOut();
  }

  Future<UserModel?> tryAutoLogin() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) return null;

      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return null;

      final profile =
          await _userDao.getById(user.id).timeout(const Duration(seconds: 10));
      return profile;
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn => SupabaseConfig.client.auth.currentSession != null;

  String? get currentUserId => SupabaseConfig.client.auth.currentUser?.id;
}
