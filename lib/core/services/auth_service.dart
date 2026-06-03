import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gotrue/gotrue.dart';

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
          .signUp(
            email: email,
            password: password,
            emailRedirectTo: 'io.supabase.baligh://login-callback',
            data: {'username': username},
          )
          .timeout(const Duration(seconds: 10));

      final user = response.user;
      if (user == null) return null;

      await SupabaseConfig.client.auth.signOut();

      return UserModel(
        id: user.id,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );
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

  Future<UserModel?> signInWithGoogle() async {
    try {
      const googleClientId =
          '1078869680060-as2tp55bufeadgd2tqiraj7lf0g74p4o.apps.googleusercontent.com';
      final googleUser = await GoogleSignIn(
        clientId: googleClientId,
        serverClientId: googleClientId,
      ).signIn();
      if (googleUser == null) {
        debugPrint('[AuthService] Google sign-in cancelled by user');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        debugPrint('[AuthService] Google idToken is null after authentication');
        throw Exception('فشل الحصول على رمز التحقق من Google');
      }

      debugPrint('[AuthService] Google idToken obtained, calling Supabase...');
      final response = await SupabaseConfig.client.auth
          .signInWithIdToken(
            provider: const OAuthProvider('google'),
            idToken: googleAuth.idToken!,
          )
          .timeout(const Duration(seconds: 15));

      final user = response.user;
      if (user == null) {
        debugPrint('[AuthService] Supabase signInWithIdToken returned null user');
        throw Exception('فشل تسجيل الدخول عبر Supabase');
      }

      debugPrint('[AuthService] Supabase user: ${user.id}, fetching profile...');
      var profile =
          await _userDao.getById(user.id).timeout(const Duration(seconds: 10));

      if (profile == null) {
        debugPrint('[AuthService] No profile found, creating new user...');
        final email = user.email ?? '';
        final username = email.split('@').first;
        final newUser = UserModel(
          id: user.id,
          username: username,
          email: email,
          createdAt: DateTime.now(),
        );
        await _userDao.insert(newUser).timeout(const Duration(seconds: 10));
        profile = newUser;
      }

      return profile;
    } on TimeoutException {
      debugPrint('[AuthService] Timeout in signInWithGoogle');
      throw Exception('انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.');
    } catch (e) {
      debugPrint('[AuthService] signInWithGoogle error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await Future.wait([
      SupabaseConfig.client.auth.signOut(),
      GoogleSignIn().signOut(),
    ]);
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
