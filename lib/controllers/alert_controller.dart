// MVC - Controller
import 'package:flutter/foundation.dart';
import '../core/database/notification_dao.dart';

/// Représente une alerte / notification affichée à l'utilisateur.
///
/// Chaque alerte peut être liée à un signalement via [reportId].
class AppAlert {
  /// Identifiant unique de l'alerte en base de données.
  final int id;

  /// Titre court affiché dans la liste des alertes.
  final String title;

  /// Description détaillée du contenu de l'alerte.
  final String description;

  /// Date et heure de création de l'alerte.
  final DateTime createdAt;

  /// Indique si l'alerte a déjà été lue par l'utilisateur.
  final bool isRead;

  /// Identifiant du signalement associé, ou `null` si sans lien.
  final int? reportId;

  /// Crée une instance immuable d'[AppAlert].
  const AppAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
    this.reportId,
  });

  /// Retourne une copie de cette alerte avec [isRead] mis à jour.
  AppAlert copyWith({bool? isRead}) => AppAlert(
        id: id,
        title: title,
        description: description,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        reportId: reportId,
      );
}

/// Contrôleur des alertes et notifications utilisateur.
///
/// Gère le chargement, la lecture et la mise à jour des alertes
/// depuis le [NotificationDao]. Notifie les widgets abonnés à chaque
/// changement d'état via [ChangeNotifier].
class AlertProvider extends ChangeNotifier {
  final NotificationDao _notificationDao = NotificationDao();

  /// Liste interne des alertes chargées.
  List<AppAlert> _alerts = [];

  /// Indique si un chargement est en cours.
  bool _isLoading = false;

  /// Retourne une vue non-modifiable de la liste des alertes.
  List<AppAlert> get alerts => List.unmodifiable(_alerts);

  /// Retourne le nombre d'alertes non lues.
  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  /// Retourne `true` si un chargement asynchrone est en cours.
  bool get isLoading => _isLoading;

  /// Charge les alertes de l'utilisateur identifié par [userId].
  ///
  /// Met à jour [alerts] et notifie les listeners. En cas d'erreur,
  /// la liste est réinitialisée à vide.
  Future<void> fetchAlerts({required String userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('[AlertProvider] fetchAlerts: userId=$userId');
      final notifications = await _notificationDao.getByUserId(userId);
      debugPrint('[AlertProvider] fetchAlerts: got ${notifications.length} notifications');
      _alerts = notifications.map((n) => AppAlert(
            id: n.id!,
            title: 'تنبيه',
            description: n.message,
            createdAt: n.createdAt,
            isRead: n.isRead,
            reportId: n.reportId,
          )).toList();
    } catch (e) {
      debugPrint('[AlertProvider] fetchAlerts error: $e');
      _alerts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Marque l'alerte identifiée par [id] comme lue.
  ///
  /// Met à jour l'état local immédiatement et persiste le changement
  /// via [NotificationDao.markAsRead]. Ne fait rien si l'alerte
  /// est introuvable ou déjà lue.
  void markAsRead(int id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1 && !_alerts[index].isRead) {
      _alerts = List.from(_alerts)
        ..[index] = _alerts[index].copyWith(isRead: true);
      _notificationDao.markAsRead(id);
      notifyListeners();
    }
  }

  /// Marque toutes les alertes de l'utilisateur [userId] comme lues.
  ///
  /// Met à jour l'état local et persiste via [NotificationDao.markAllAsRead].
  /// Ne fait rien si toutes les alertes sont déjà lues.
  void markAllAsRead(String userId) {
    if (_alerts.every((a) => a.isRead)) return;
    _alerts = _alerts.map((a) => a.copyWith(isRead: true)).toList();
    _notificationDao.markAllAsRead(userId);
    notifyListeners();
  }

  /// Rafraîchit les alertes pour l'utilisateur [userId].
  ///
  /// Alias de [fetchAlerts] pour une interface plus explicite.
  Future<void> refresh(String userId) async {
    await fetchAlerts(userId: userId);
  }
}
