class NotificationModel {
  final int? id;
  final String userId;
  final int? reportId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    this.id,
    required this.userId,
    this.reportId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] as int?,
        userId: map['user_id'] as String,
        reportId: (map['report_id'] as num?)?.toInt(),
        message: map['message'] as String,
        isRead: (map['is_read'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        if (reportId != null) 'report_id': reportId,
        'message': message,
        'is_read': isRead ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        userId: userId,
        reportId: reportId,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
