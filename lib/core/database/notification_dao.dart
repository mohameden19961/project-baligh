import 'package:flutter/foundation.dart';
import '../../utils/supabase_config.dart';
import '../models/notification_model.dart';

class NotificationDao {
  Future<int> insert(NotificationModel notification) async {
    try {
      final id = await SupabaseConfig.client.rpc('create_notification', params: {
        'p_user_id': notification.userId,
        'p_report_id': notification.reportId,
        'p_message': notification.message,
      });
      debugPrint('[NotificationDao] RPC insert success: id=$id for user=${notification.userId}');
      return id as int;
    } catch (e) {
      debugPrint('[NotificationDao] RPC insert FAILED for user=${notification.userId}: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getByUserId(String userId) async {
    debugPrint('[NotificationDao] getByUserId: userId=$userId');
    final response = await SupabaseConfig.client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    debugPrint('[NotificationDao] getByUserId: found ${(response as List).length} rows');
    return (response as List).map((m) => NotificationModel.fromMap(m)).toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final response = await SupabaseConfig.client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', 0);
    return (response as List).length;
  }

  Future<void> markAsRead(int notificationId) async {
    await SupabaseConfig.client
        .from('notifications')
        .update({'is_read': 1})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await SupabaseConfig.client
        .from('notifications')
        .update({'is_read': 1})
        .eq('user_id', userId);
  }

  Future<void> deleteOldNotifications({int olderThanDays = 30}) async {
    final cutoff = DateTime.now()
        .subtract(Duration(days: olderThanDays))
        .toIso8601String();
    await SupabaseConfig.client
        .from('notifications')
        .delete()
        .lt('created_at', cutoff);
  }
}
