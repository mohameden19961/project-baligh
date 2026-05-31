// MVC - Controller
import 'package:flutter/foundation.dart';
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
  ///
  /// Analyse le contenu de [e] pour identifier les erreurs connues
  /// (timeout, identifiants invalides, email non confirmé, etc.).
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

  /// Déconnecte l'utilisateur actuel et efface la session locale.
  ///
  /// Après cet appel, [currentUser] est `null` et [isAuthenticated] est `false`.
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
