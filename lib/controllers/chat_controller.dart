import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/database/message_dao.dart';
import '../core/models/message_model.dart';

class ConversationSummary {
  final int reportId;
  final String otherUserId;
  final String otherUsername;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String reportCategory;

  ConversationSummary({
    required this.reportId,
    required this.otherUserId,
    required this.otherUsername,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.reportCategory,
  });
}

class ChatProvider extends ChangeNotifier {
  final MessageDao _dao = MessageDao();

  List<MessageModel> _messages = [];
  List<ConversationSummary> _conversations = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  RealtimeChannel? _channel;

  List<MessageModel> get messages => _messages;
  List<ConversationSummary> get conversations => _conversations;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void subscribe(String userId) {
    _channel = Supabase.instance.client
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (_) {
            _unreadCount++;
            notifyListeners();
          },
        )
        .subscribe();
    refreshUnreadCount(userId);
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  Future<void> refreshUnreadCount(String userId) async {
    _unreadCount = await _dao.getUnreadCount(userId);
    notifyListeners();
  }

  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final all = await _dao.getAllForUser(userId);
      final grouped = <String, List<MessageModel>>{};
      for (final m in all) {
        final otherId = m.senderId == userId ? m.receiverId : m.senderId;
        final key = '${m.reportId}_$otherId';
        grouped.putIfAbsent(key, () => []).add(m);
      }

      final allOtherIds = grouped.keys
          .map((k) => k.split('_').last)
          .toSet()
          .toList();
      final usernames = await _dao.getUsernames(allOtherIds);

      final reportIds = grouped.keys
          .map((k) => int.parse(k.split('_').first))
          .toSet()
          .toList();
      final reportCategories = await _getReportCategories(reportIds);

      final list = <ConversationSummary>[];
      for (final entry in grouped.entries) {
        final parts = entry.key.split('_');
        final reportId = int.parse(parts.first);
        final otherId = parts.last;
        final msgs = entry.value;
        msgs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final latest = msgs.first;
        list.add(ConversationSummary(
          reportId: reportId,
          otherUserId: otherId,
          otherUsername: usernames[otherId] ?? otherId,
          lastMessage: latest.content,
          lastMessageAt: latest.createdAt,
          unreadCount: msgs
              .where((m) => m.receiverId == userId && !m.isRead)
              .length,
          reportCategory: reportCategories[reportId] ?? '',
        ));
      }
      list.sort(
          (a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      _conversations = list;
      _unreadCount =
          all.where((m) => m.receiverId == userId && !m.isRead).length;
    } catch (e) {
      debugPrint('[ChatProvider] loadConversations error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadConversation(
    int reportId,
    String userId,
    String otherUserId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      _messages =
          await _dao.getConversation(reportId, userId, otherUserId);
      final unreadIds = _messages
          .where((m) => m.receiverId == userId && !m.isRead)
          .map((m) => m.id!)
          .toList();
      if (unreadIds.isNotEmpty) {
        await _dao.markAsReadBatch(unreadIds);
      }
      await refreshUnreadCount(userId);
    } catch (e) {
      debugPrint('[ChatProvider] loadConversation error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(
    int reportId,
    String senderId,
    String receiverId,
    String content,
  ) async {
    final msg = MessageModel(
      reportId: reportId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now(),
    );
    await _dao.sendMessage(msg);
    _messages = [..._messages, msg];
    notifyListeners();
  }

  Future<Map<int, String>> _getReportCategories(
      List<int> reportIds) async {
    try {
      final response = await Supabase.instance.client
          .from('reports')
          .select('id, category')
          .filter('id', 'in', '(${reportIds.join(',')})');
      final map = <int, String>{};
      for (final row in response as List) {
        map[row['id'] as int] = row['category'] as String;
      }
      return map;
    } catch (_) {
      return {};
    }
  }
}
