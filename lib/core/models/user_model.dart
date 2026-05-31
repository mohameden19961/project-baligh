class UserModel {
  final String? id;
  final String username;
  final String email;
  final DateTime createdAt;
  final int reputationScore;
  final int reportsCount;
  final int confirmedCount;

  const UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.reputationScore = 0,
    this.reportsCount = 0,
    this.confirmedCount = 0,
  });

  bool get isTrusted => confirmedCount >= 10;

  String get reputationBadge => switch (confirmedCount) {
        >= 10 => 'موثوق',
        >= 5 => 'مشارك نشط',
        >= 1 => 'مشارك جديد',
        _ => 'عضو جديد',
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String?,
        username: map['username'] as String,
        email: map['email'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        reputationScore: (map['reputation_score'] as num?)?.toInt() ?? 0,
        reportsCount: (map['reports_count'] as num?)?.toInt() ?? 0,
        confirmedCount: (map['confirmed_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'email': email,
        'created_at': createdAt.toIso8601String(),
        'reputation_score': reputationScore,
        'reports_count': reportsCount,
        'confirmed_count': confirmedCount,
      };

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    int? reputationScore,
    int? reportsCount,
    int? confirmedCount,
  }) =>
      UserModel(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        createdAt: createdAt ?? this.createdAt,
        reputationScore: reputationScore ?? this.reputationScore,
        reportsCount: reportsCount ?? this.reportsCount,
        confirmedCount: confirmedCount ?? this.confirmedCount,
      );
}
