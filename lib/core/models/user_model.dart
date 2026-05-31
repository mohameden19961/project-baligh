// MVC - Model

/// Modèle représentant un utilisateur de l'application.
///
/// Contient les informations du profil, le score de réputation
/// et les statistiques de participation (signalements, confirmations).
class UserModel {
  /// Identifiant unique Supabase (UUID), ou `null` avant persistance.
  final String? id;

  /// Nom d'utilisateur choisi à l'inscription.
  final String username;

  /// Adresse e-mail de l'utilisateur.
  final String email;

  /// Date et heure de création du compte.
  final DateTime createdAt;

  /// Score de réputation calculé par le système.
  final int reputationScore;

  /// Nombre total de signalements soumis par l'utilisateur.
  final int reportsCount;

  /// Nombre de signalements confirmés par la communauté.
  final int confirmedCount;

  /// Crée une instance immuable de [UserModel].
  const UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.reputationScore = 0,
    this.reportsCount = 0,
    this.confirmedCount = 0,
  });

  /// Retourne `true` si l'utilisateur est considéré comme fiable
  /// (au moins 10 signalements confirmés).
  bool get isTrusted => confirmedCount >= 10;

  /// Retourne le badge de réputation correspondant au niveau de participation.
  ///
  /// Valeurs possibles : `'موثوق'`, `'مشارك نشط'`, `'مشارك جديد'`, `'عضو جديد'`.
  String get reputationBadge => switch (confirmedCount) {
        >= 10 => 'موثوق',
        >= 5 => 'مشارك نشط',
        >= 1 => 'مشارك جديد',
        _ => 'عضو جديد',
      };

  /// Crée un [UserModel] depuis une [Map] issue de la base de données.
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String?,
        username: map['username'] as String,
        email: map['email'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        reputationScore: (map['reputation_score'] as num?)?.toInt() ?? 0,
        reportsCount: (map['reports_count'] as num?)?.toInt() ?? 0,
        confirmedCount: (map['confirmed_count'] as num?)?.toInt() ?? 0,
      );

  /// Convertit ce modèle en [Map] pour la persistance en base de données.
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'email': email,
        'created_at': createdAt.toIso8601String(),
        'reputation_score': reputationScore,
        'reports_count': reportsCount,
        'confirmed_count': confirmedCount,
      };

  /// Retourne une copie de ce modèle avec les champs fournis mis à jour.
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
