import '../database/notification_dao.dart';
import '../database/user_dao.dart';
import '../models/notification_model.dart';
import '../../models/report_model.dart';

class NotificationService {
  final NotificationDao _notificationDao = NotificationDao();
  final UserDao _userDao = UserDao();

  Future<void> createAlertForNearbyUsers(ReportModel report) async {
    final users = await _userDao.getAll();
    int count = 0;

    for (final user in users) {
      if (user.id == report.userId) continue;

      try {
        await _notificationDao.insert(
          NotificationModel(
            userId: user.id!,
            reportId: report.id,
            message: _buildAlertMessage(report),
            createdAt: DateTime.now(),
          ),
        );
        count++;
      } catch (e) {
        print('[NotificationService] Failed to create notification for user ${user.id}: $e');
      }
    }

    print('[NotificationService] Created $count notifications for report ${report.id}');
  }

  String _buildAlertMessage(ReportModel report) {
    final categoryNames = {
      'electricity': 'كهرباء',
      'road': 'طرق',
      'flood': 'فيضانات',
      'security': 'أمن',
      'water': 'مياه',
      'health': 'صحة',
      'internet': 'إنترنت',
      'market': 'أسواق',
      'government': 'حكومة',
      'fire': 'حرائق',
      'infrastructure': 'بنية تحتية',
      'fraud': 'احتيال',
    };

    final catName = categoryNames[report.category.name] ?? report.category.name;
    return 'بلاغ جديد: $catName - ${report.description.length > 50 ? '${report.description.substring(0, 50)}...' : report.description}';
  }
}
