import '../../utils/supabase_config.dart';
import '../models/message_model.dart';

class MessageDao {
  Future<List<MessageModel>> getConversation(
    int reportId,
    String userId1,
    String userId2,
  ) async {
    final response = await SupabaseConfig.client
        .from('messages')
        .select()
        .eq('report_id', reportId)
        .or(
          'and(sender_id.eq.$userId1,receiver_id.eq.$userId2),'
          'and(sender_id.eq.$userId2,receiver_id.eq.$userId1)',
        )
        .order('created_at', ascending: true);
    return (response as List).map((m) => MessageModel.fromMap(m)).toList();
  }

  Future<void> sendMessage(MessageModel message) async {
    await SupabaseConfig.client.from('messages').insert(message.toMap());
  }

  Future<List<MessageModel>> getAllForUser(String userId) async {
    final response = await SupabaseConfig.client
        .from('messages')
        .select()
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);
    return (response as List).map((m) => MessageModel.fromMap(m)).toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final response = await SupabaseConfig.client
        .from('messages')
        .select('id')
        .eq('receiver_id', userId)
        .eq('is_read', false);
    return (response as List).length;
  }

  Future<void> markAsReadBatch(List<int> messageIds) async {
    if (messageIds.isEmpty) return;
    await SupabaseConfig.client
        .from('messages')
        .update({'is_read': true})
        .filter('id', 'in', '(${messageIds.join(',')})');
  }

  Future<Map<String, String>> getUsernames(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    final quoted = userIds.map((id) => '"$id"').join(',');
    final response = await SupabaseConfig.client
        .from('users')
        .select('id, username')
        .filter('id', 'in', '($quoted)');
    final map = <String, String>{};
    for (final row in response as List) {
      map[row['id'] as String] = row['username'] as String;
    }
    return map;
  }
}
