import 'package:flutter/foundation.dart';
import '../core/database/notification_dao.dart';

class AppAlert {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;
  final int? reportId;

  const AppAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
    this.reportId,
  });

  AppAlert copyWith({bool? isRead}) => AppAlert(
        id: id,
        title: title,
        description: description,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        reportId: reportId,
      );
}

class AlertProvider extends ChangeNotifier {
  final NotificationDao _notificationDao = NotificationDao();
  List<AppAlert> _alerts = [];
  bool _isLoading = false;

  List<AppAlert> get alerts => List.unmodifiable(_alerts);
  int get unreadCount => _alerts.where((a) => !a.isRead).length;
  bool get isLoading => _isLoading;

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

  void markAsRead(int id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1 && !_alerts[index].isRead) {
      _alerts = List.from(_alerts)
        ..[index] = _alerts[index].copyWith(isRead: true);
      _notificationDao.markAsRead(id);
      notifyListeners();
    }
  }

  void markAllAsRead(String userId) {
    if (_alerts.every((a) => a.isRead)) return;
    _alerts = _alerts.map((a) => a.copyWith(isRead: true)).toList();
    _notificationDao.markAllAsRead(userId);
    notifyListeners();
  }

  Future<void> refresh(String userId) async {
    await fetchAlerts(userId: userId);
  }
}
