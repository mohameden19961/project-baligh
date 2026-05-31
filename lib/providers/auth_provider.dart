import 'package:flutter/foundation.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUser?.id;

  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.tryAutoLogin();
    } catch (_) {
      _currentUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        username: username,
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'اسم المستخدم أو البريد الإلكتروني موجود مسبقاً';
    } catch (e) {
      debugPrint('AuthProvider.register error: $e');
      _errorMessage = _extractErrorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } catch (e) {
      debugPrint('AuthProvider.login error: $e');
      _errorMessage = _extractErrorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  String _extractErrorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('TimeoutException') || msg.contains('انتهت المهلة')) {
      return 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.';
    }
    if (msg.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('Email not confirmed')) {
      return 'البريد الإلكتروني غير مؤكد بعد. تحقق من بريدك الوارد.';
    }
    if (msg.contains('User already registered')) {
      return 'هذا البريد الإلكتروني مسجل مسبقاً';
    }
    if (msg.contains('Weak password')) {
      return 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.';
    }
    return 'حدث خطأ غير متوقع. حاول مجدداً.';
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
