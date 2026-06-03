// MVC - Controller
import 'package:flutter/foundation.dart';
import 'package:gotrue/gotrue.dart' show AuthException;
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';

/// Contrôleur d'authentification gérant la session utilisateur.
///
/// Hérite de [ChangeNotifier] pour notifier les widgets abonnés
/// lors de tout changement d'état (connexion, déconnexion, chargement).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  /// Utilisateur actuellement connecté, ou `null` si non authentifié.
  UserModel? _currentUser;

  /// Indique si une opération asynchrone est en cours.
  bool _isLoading = false;

  /// Message d'erreur de la dernière opération échouée.
  String? _errorMessage;

  /// Retourne l'utilisateur connecté, ou `null`.
  UserModel? get currentUser => _currentUser;

  /// Retourne `true` si un utilisateur est actuellement authentifié.
  bool get isAuthenticated => _currentUser != null;

  /// Retourne `true` si une opération asynchrone est en cours.
  bool get isLoading => _isLoading;

  /// Retourne le message d'erreur de la dernière opération, ou `null`.
  String? get errorMessage => _errorMessage;

  /// Retourne l'identifiant unique de l'utilisateur connecté, ou `null`.
  String? get currentUserId => _currentUser?.id;

  /// Tente de restaurer la session depuis les données persistées.
  ///
  /// Appelé au démarrage de l'application. Ne lève pas d'exception :
  /// en cas d'échec, [currentUser] reste `null`.
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

  /// Inscrit un nouvel utilisateur avec [username], [email] et [password].
  ///
  /// Retourne `true` si l'inscription réussit et que [currentUser] est défini.
  /// Retourne `false` et renseigne [errorMessage] en cas d'échec.
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

  /// Connecte un utilisateur existant avec [email] et [password].
  ///
  /// Retourne `true` si la connexion réussit et que [currentUser] est défini.
  /// Retourne `false` et renseigne [errorMessage] en cas d'échec.
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

  /// Traduit une exception en message d'erreur lisible par l'utilisateur.
  String _extractErrorMessage(Object e) {
    final msg = e.toString();
    debugPrint('[AuthProvider] _extractErrorMessage: $msg');

    // Direct AuthException message extraction
    if (e is AuthException) {
      final m = e.message;
      if (m.contains('token verification') || m.contains('Invalid ID token') ||
          m.contains('id_token') || m.contains('idToken') ||
          m.contains('aud') || m.contains('audience')) {
        return 'رمز التحقق من Google غير صالح. تأكد من تفعيل Google OAuth في لوحة Supabase.';
      }
      if (m.contains('provider') || m.contains('oauth')) {
        return 'مزود Google OAuth غير مفعل في Supabase. قم بتفعيله من الإعدادات.';
      }
      if (m.contains('network') || m.contains('connect') ||
          m.contains('fetch') || m.contains('timeout')) {
        return 'تعذر الاتصال بـ Supabase. تحقق من اتصالك بالإنترنت.';
      }
      if (m.contains('فشل')) return m;
      return 'حدث خطأ في تسجيل الدخول: $m';
    }

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
    if (msg.contains('PlatformException') || msg.contains('google_sign_in')) {
      return 'تعذر الاتصال بـ Google. تحقق من Google Play Services على جهازك.';
    }
    if (msg.contains('Assertion failed') || msg.contains('ClientID not set')) {
      return 'خطأ في إعداد Google Sign-In للمتصفح. قم بتعريف clientId في الكود.';
    }
    if (msg.contains('فشل')) {
      return msg;
    }
    return 'حدث خطأ غير متوقع. حاول مجدداً.';
  }

  /// Connecte l'utilisateur avec Google Sign-In.
  ///
  /// Retourne `true` si la connexion réussit et que [currentUser] est défini.
  /// Retourne `false` et renseigne [errorMessage] en cas d'échec ou d'annulation.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'تم إلغاء تسجيل الدخول';
    } catch (e) {
      debugPrint('AuthProvider.signInWithGoogle error: $e');
      _errorMessage = _extractErrorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Déconnecte l'utilisateur actuel et efface la session locale.
  ///
  /// Après cet appel, [currentUser] est `null` et [isAuthenticated] est `false`.
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
