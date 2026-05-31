// MVC - Model
enum ReportCategory {
  electricity,
  road,
  flood,
  security,
  water,
  health,
  internet,
  market,
  government,
  fire,
  infrastructure,
  fraud;

  String toJson() => name;

  static ReportCategory fromJson(String value) {
    return ReportCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportCategory.other,
    );
  }

  static ReportCategory get other => ReportCategory.infrastructure;
}

enum ReportStatus {
  pending,
  validated,
  falseReport;

  String toJson() => name;

  static ReportStatus fromJson(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

class ReportLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const ReportLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory ReportLocation.fromJson(Map<String, dynamic> json) {
    return ReportLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

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

class CredibilityScore {
  final int confirmations;
  final int rejections;

  const CredibilityScore({
    this.confirmations = 0,
    this.rejections = 0,
  });

  int get netScore => confirmations - rejections;

  int get totalVotes => confirmations + rejections;

  double get confidenceRatio =>
      totalVotes == 0 ? 0.0 : confirmations / totalVotes;

  CredibilityLevel get level {
    if (totalVotes == 0) return CredibilityLevel.unverified;
    if (totalVotes >= 3 && confidenceRatio >= 0.8) return CredibilityLevel.high;
    if (totalVotes >= 3) return CredibilityLevel.medium;
    return CredibilityLevel.low;
  }

  String get label {
    if (totalVotes == 0) return 'غير مؤكد';
    if (totalVotes >= 3 && confidenceRatio >= 0.8) return 'موثوق جداً';
    if (totalVotes >= 3) return 'مؤكد';
    return 'قيد المراجعة';
  }

  factory CredibilityScore.fromJson(Map<String, dynamic> json) {
    return CredibilityScore(
      confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
      rejections: (json['rejections'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'confirmations': confirmations,
        'rejections': rejections,
      };

  CredibilityScore copyWithConfirmation() =>
      CredibilityScore(confirmations: confirmations + 1, rejections: rejections);

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

enum CredibilityLevel {
  unverified,
  low,
  medium,
  high;
}

class ReportModel {
  final int? id;
  final ReportCategory category;
  final String description;
  final ReportLocation location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ReportStatus status;
  final CredibilityScore credibilityScore;
  final String? photoUrl;
  final String? localPhotoPath;
  final String? userId;

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

  bool get isSynced => id != null;

  bool get isOpen =>
      status == ReportStatus.pending || status == ReportStatus.validated;

  bool get hasPhoto => photoUrl != null || localPhotoPath != null;

  String? get displayPhotoSource => photoUrl ?? localPhotoPath;

  int get confirmCount => credibilityScore.confirmations;
  int get denyCount => credibilityScore.rejections;

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
