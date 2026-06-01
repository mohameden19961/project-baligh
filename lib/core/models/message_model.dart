class MessageModel {
  final int? id;
  final int reportId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const MessageModel({
    this.id,
    required this.reportId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
        id: map['id'] as int?,
        reportId: map['report_id'] as int,
        senderId: map['sender_id'] as String,
        receiverId: map['receiver_id'] as String,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        isRead: (map['is_read'] as bool?) ?? false,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'report_id': reportId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
      };
}
