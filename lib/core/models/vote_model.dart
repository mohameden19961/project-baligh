enum VoteType { confirm, deny }

class VoteModel {
  final int? id;
  final int reportId;
  final String userId;
  final VoteType voteType;
  final DateTime createdAt;

  const VoteModel({
    this.id,
    required this.reportId,
    required this.userId,
    required this.voteType,
    required this.createdAt,
  });

  factory VoteModel.fromMap(Map<String, dynamic> map) => VoteModel(
        id: map['id'] as int?,
        reportId: (map['report_id'] as num).toInt(),
        userId: map['user_id'] as String,
        voteType:
            map['vote_type'] == 'confirm' ? VoteType.confirm : VoteType.deny,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'report_id': reportId,
        'user_id': userId,
        'vote_type': voteType.name,
        'created_at': createdAt.toIso8601String(),
      };
}
