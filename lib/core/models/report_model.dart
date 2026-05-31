// MVC - Model

/// Catégories de signalement disponibles dans l'application.
///
/// Chaque valeur représente un domaine problématique qu'un citoyen peut signaler.
enum ReportCategory {
  /// Problèmes liés au réseau électrique.
  electricity,

  /// Dégradations ou obstruction de la voirie.
  road,

  /// Inondations ou accumulation d'eau.
  flood,

  /// Incidents liés à la sécurité publique.
  security,

  /// Problèmes d'alimentation en eau potable.
  water,

  /// Problèmes sanitaires ou médicaux.
  health,

  /// Coupures ou dégradations du réseau Internet.
  internet,

  /// Anomalies sur les marchés ou le commerce.
  market,

  /// Dysfonctionnements d'un service gouvernemental.
  government,

  /// Incendies ou risques d'incendie.
  fire,

  /// Dégradations des infrastructures publiques.
  infrastructure,

  /// Fraudes ou arnaques signalées.
  fraud;

  /// Sérialise la valeur en chaîne JSON (nom de l'énumération).
  String toJson() => name;

  /// Désérialise une [value] JSON en [ReportCategory].
  ///
  /// Retourne [ReportCategory.infrastructure] si la valeur est inconnue.
  static ReportCategory fromJson(String value) {
    return ReportCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportCategory.other,
    );
  }

  /// Valeur par défaut utilisée comme catégorie inconnue ou de substitution.
  static ReportCategory get other => ReportCategory.infrastructure;
}

/// Statuts possibles d'un signalement tout au long de son cycle de vie.
enum ReportStatus {
  /// Signalement soumis, en attente de validation communautaire.
  pending,

  /// Signalement validé par un nombre suffisant de votes.
  validated,

  /// Signalement identifié comme faux par la communauté.
  falseReport;

  /// Sérialise la valeur en chaîne JSON (nom de l'énumération).
  String toJson() => name;

  /// Désérialise une [value] JSON en [ReportStatus].
  ///
  /// Retourne [ReportStatus.pending] si la valeur est inconnue.
  static ReportStatus fromJson(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

/// Représente les coordonnées géographiques et l'adresse d'un signalement.
class ReportLocation {
  /// Latitude en degrés décimaux.
  final double latitude;

  /// Longitude en degrés décimaux.
  final double longitude;

  /// Adresse lisible par l'humain, ou `null` si indisponible.
  final String? address;

  /// Crée une instance immuable de [ReportLocation].
  const ReportLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  /// Crée un [ReportLocation] depuis une [Map] JSON.
  factory ReportLocation.fromJson(Map<String, dynamic> json) {
    return ReportLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  /// Convertit ce modèle en [Map] JSON.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportLocation &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'ReportLocation(lat: $latitude, lng: $longitude, address: $address)';
}

/// Représente le score de crédibilité d'un signalement basé sur les votes.
///
/// Chaque utilisateur peut confirmer ou réfuter un signalement, ce qui
/// incrémente [confirmations] ou [rejections].
class CredibilityScore {
  /// Nombre de votes de confirmation.
  final int confirmations;

  /// Nombre de votes de réfutation.
  final int rejections;

  /// Crée un [CredibilityScore] avec des valeurs par défaut à zéro.
  const CredibilityScore({
    this.confirmations = 0,
    this.rejections = 0,
  });

  /// Retourne la différence entre confirmations et réfutations.
  int get netScore => confirmations - rejections;

  /// Retourne le total des votes exprimés.
  int get totalVotes => confirmations + rejections;

  /// Retourne le ratio de confiance (0.0 à 1.0).
  ///
  /// Vaut `0.0` si aucun vote n'a encore été exprimé.
  double get confidenceRatio =>
      totalVotes == 0 ? 0.0 : confirmations / totalVotes;

  /// Retourne le niveau de crédibilité calculé à partir des votes.
  CredibilityLevel get level {
    if (totalVotes == 0) return CredibilityLevel.unverified;
    if (totalVotes >= 3 && confidenceRatio >= 0.8) return CredibilityLevel.high;
    if (totalVotes >= 3) return CredibilityLevel.medium;
    return CredibilityLevel.low;
  }

  /// Retourne un libellé arabe décrivant le niveau de crédibilité.
  String get label {
    if (totalVotes == 0) return 'غير مؤكد';
    if (totalVotes >= 3 && confidenceRatio >= 0.8) return 'موثوق جداً';
    if (totalVotes >= 3) return 'مؤكد';
    return 'قيد المراجعة';
  }

  /// Crée un [CredibilityScore] depuis une [Map] JSON.
  factory CredibilityScore.fromJson(Map<String, dynamic> json) {
    return CredibilityScore(
      confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
      rejections: (json['rejections'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convertit ce score en [Map] JSON.
  Map<String, dynamic> toJson() => {
        'confirmations': confirmations,
        'rejections': rejections,
      };

  /// Retourne une copie avec [confirmations] incrémenté de 1.
  CredibilityScore copyWithConfirmation() =>
      CredibilityScore(confirmations: confirmations + 1, rejections: rejections);

  /// Retourne une copie avec [rejections] incrémenté de 1.
  CredibilityScore copyWithRejection() =>
      CredibilityScore(confirmations: confirmations, rejections: rejections + 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredibilityScore &&
          other.confirmations == confirmations &&
          other.rejections == rejections;

  @override
  int get hashCode => Object.hash(confirmations, rejections);

  @override
  String toString() =>
      'CredibilityScore(+$confirmations / -$rejections | net: $netScore)';
}

/// Niveaux de crédibilité calculés à partir du [CredibilityScore].
enum CredibilityLevel {
  /// Aucun vote exprimé.
  unverified,

  /// Peu de votes ou ratio insuffisant.
  low,

  /// Nombre de votes suffisant mais ratio modéré.
  medium,

  /// Score élevé avec fort taux de confirmation.
  high;
}

/// Modèle principal représentant un signalement citoyen.
///
/// Agrège toutes les informations d'un problème signalé :
/// catégorie, description, localisation, statut, crédibilité et photo.
class ReportModel {
  /// Identifiant unique en base de données, ou `null` avant persistance.
  final int? id;

  /// Catégorie du problème signalé.
  final ReportCategory category;

  /// Description textuelle du signalement rédigée par le citoyen.
  final String description;

  /// Localisation géographique du problème.
  final ReportLocation location;

  /// Date et heure de soumission du signalement.
  final DateTime createdAt;

  /// Date et heure de la dernière mise à jour, ou `null`.
  final DateTime? updatedAt;

  /// Statut courant du signalement dans son cycle de vie.
  final ReportStatus status;

  /// Score de crédibilité basé sur les votes de la communauté.
  final CredibilityScore credibilityScore;

  /// URL de la photo hébergée en ligne, ou `null`.
  final String? photoUrl;

  /// Chemin local vers la photo avant synchronisation, ou `null`.
  final String? localPhotoPath;

  /// Identifiant de l'utilisateur auteur du signalement, ou `null`.
  final String? userId;

  /// Crée une instance immuable de [ReportModel].
  const ReportModel({
    this.id,
    required this.category,
    required this.description,
    required this.location,
    required this.createdAt,
    this.updatedAt,
    this.status = ReportStatus.pending,
    this.credibilityScore = const CredibilityScore(),
    this.photoUrl,
    this.localPhotoPath,
    this.userId,
  });

  /// Retourne `true` si ce signalement a été persisté en base (possède un [id]).
  bool get isSynced => id != null;

  /// Retourne `true` si le signalement est encore ouvert (pending ou validated).
  bool get isOpen =>
      status == ReportStatus.pending || status == ReportStatus.validated;

  /// Retourne `true` si une photo est associée à ce signalement.
  bool get hasPhoto => photoUrl != null || localPhotoPath != null;

  /// Retourne la source de photo à afficher : [photoUrl] en priorité, sinon [localPhotoPath].
  String? get displayPhotoSource => photoUrl ?? localPhotoPath;

  /// Raccourci vers le nombre de confirmations du score de crédibilité.
  int get confirmCount => credibilityScore.confirmations;

  /// Raccourci vers le nombre de réfutations du score de crédibilité.
  int get denyCount => credibilityScore.rejections;

  /// Crée un [ReportModel] depuis une [Map] JSON (format API).
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int?,
      category: ReportCategory.fromJson(json['category'] as String),
      description: json['description'] as String,
      location: ReportLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      status: ReportStatus.fromJson(json['status'] as String? ?? 'pending'),
      credibilityScore: json['credibilityScore'] != null
          ? CredibilityScore.fromJson(
              json['credibilityScore'] as Map<String, dynamic>,
            )
          : CredibilityScore(
              confirmations: (json['confirm_count'] as num?)?.toInt() ?? 0,
              rejections: (json['deny_count'] as num?)?.toInt() ?? 0,
            ),
      photoUrl: json['photoUrl'] as String?,
      localPhotoPath: json['localPhotoPath'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  /// Convertit ce modèle en [Map] JSON (format API).
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'category': category.toJson(),
        'description': description,
        'location': location.toJson(),
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'status': status.toJson(),
        'credibilityScore': credibilityScore.toJson(),
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (localPhotoPath != null) 'localPhotoPath': localPhotoPath,
        if (userId != null) 'user_id': userId,
      };

  /// Convertit ce modèle en [Map] pour la base de données locale SQLite.
  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'user_id': userId ?? '',
        'category': category.toJson(),
        'description': description,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': location.address,
        'photo_url': photoUrl,
        'created_at': createdAt.toIso8601String(),
        'status': status.toJson(),
        'confirm_count': credibilityScore.confirmations,
        'deny_count': credibilityScore.rejections,
      };

  /// Crée un [ReportModel] depuis une [Map] issue de la base de données locale SQLite.
  factory ReportModel.fromDbMap(Map<String, dynamic> map) {
    final confirmCount = (map['confirm_count'] as num?)?.toInt() ?? 0;
    final denyCount = (map['deny_count'] as num?)?.toInt() ?? 0;
    return ReportModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String?,
      category: ReportCategory.fromJson(map['category'] as String? ?? 'infrastructure'),
      description: (map['description'] as String?) ?? '',
      location: ReportLocation(
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
        address: map['address'] as String?,
      ),
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      status: ReportStatus.fromJson(map['status'] as String? ?? 'pending'),
      credibilityScore: CredibilityScore(
        confirmations: confirmCount,
        rejections: denyCount,
      ),
    );
  }

  /// Retourne une copie de ce modèle avec les champs fournis mis à jour.
  ReportModel copyWith({
    int? id,
    ReportCategory? category,
    String? description,
    ReportLocation? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReportStatus? status,
    CredibilityScore? credibilityScore,
    String? photoUrl,
    String? localPhotoPath,
    String? userId,
  }) {
    return ReportModel(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      credibilityScore: credibilityScore ?? this.credibilityScore,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReportModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReportModel('
        'id: $id, '
        'category: ${category.name}, '
        'status: ${status.name}, '
        'credibility: $credibilityScore'
        ')';
  }
}
