// lib/models/report_model.dart
// ─────────────────────────────────────────────────────────────────
// Model layer — pure Dart, zero Flutter/UI dependencies.
// Represents a single citizen report submitted through Baligh.
// ─────────────────────────────────────────────────────────────────

// ════════════════════════════════════════════════════════════════
// ENUM: ReportCategory
// Mirrors the localization keys: categoryRoads, categoryLighting…
// ════════════════════════════════════════════════════════════════
enum ReportCategory {
  roads,
  lighting,
  waste,
  water,
  parks,
  other;

  /// Serialize to a stable JSON string (safe for API + SharedPrefs).
  String toJson() => name; // e.g. "roads"

  /// Deserialize from a JSON string. Falls back to [other] on unknown values.
  static ReportCategory fromJson(String value) {
    return ReportCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportCategory.other,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ENUM: ReportStatus
// Mirrors the localization keys: statusPending, statusInProgress…
// ════════════════════════════════════════════════════════════════
enum ReportStatus {
  pending,
  inProgress,
  resolved,
  rejected;

  String toJson() => name; // e.g. "inProgress"

  static ReportStatus fromJson(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// CLASS: ReportLocation
// A lightweight value object that pairs latitude and longitude.
// Kept separate so the Map feature can consume it directly.
// ════════════════════════════════════════════════════════════════
class ReportLocation {
  final double latitude;
  final double longitude;

  /// Optional human-readable address resolved by the geocoding service.
  final String? address;

  const ReportLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  // ── Serialization ──────────────────────────────────────────────
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

  // ── Equality & Debug ───────────────────────────────────────────
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

// ════════════════════════════════════════════════════════════════
// CLASS: CredibilityScore
// Tracks community confirmations and rejections of a report.
// The net score drives the report's trustworthiness indicator in the UI.
// ════════════════════════════════════════════════════════════════
class CredibilityScore {
  /// Number of users who confirmed they see the same problem.
  final int confirmations;

  /// Number of users who flagged the report as inaccurate or resolved.
  final int rejections;

  const CredibilityScore({
    this.confirmations = 0,
    this.rejections = 0,
  });

  // ── Computed properties ────────────────────────────────────────

  /// Net score: positive means the community trusts this report.
  int get netScore => confirmations - rejections;

  /// Total votes cast on this report.
  int get totalVotes => confirmations + rejections;

  /// Confidence ratio from 0.0 → 1.0 (NaN-safe).
  /// Returns 0.0 when no votes exist yet.
  double get confidenceRatio =>
      totalVotes == 0 ? 0.0 : confirmations / totalVotes;

  /// A quick qualitative label for the UI badge.
  CredibilityLevel get level {
    if (totalVotes == 0) return CredibilityLevel.unverified;
    if (confidenceRatio >= 0.75) return CredibilityLevel.high;
    if (confidenceRatio >= 0.40) return CredibilityLevel.medium;
    return CredibilityLevel.low;
  }

  // ── Serialization ──────────────────────────────────────────────
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

  /// Returns a copy with one more confirmation.
  CredibilityScore copyWithConfirmation() =>
      CredibilityScore(confirmations: confirmations + 1, rejections: rejections);

  /// Returns a copy with one more rejection.
  CredibilityScore copyWithRejection() =>
      CredibilityScore(confirmations: confirmations, rejections: rejections + 1);

  // ── Equality & Debug ───────────────────────────────────────────
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

// ════════════════════════════════════════════════════════════════
// ENUM: CredibilityLevel
// Used by the UI to choose badge colors without embedding logic there.
// ════════════════════════════════════════════════════════════════
enum CredibilityLevel {
  unverified, // No votes yet
  low,        // Community doubts this report
  medium,     // Mixed signals
  high,       // Community strongly confirms this report
}

// ════════════════════════════════════════════════════════════════
// CLASS: ReportModel  ←  The main model
// ════════════════════════════════════════════════════════════════
class ReportModel {
  /// Unique identifier assigned by the backend (null until synced).
  final String? id;

  /// Category of the civic problem being reported.
  final ReportCategory category;

  /// Free-text description provided by the citizen.
  final String description;

  /// Geographic coordinates and optional address of the problem.
  final ReportLocation location;

  /// UTC timestamp of when the report was first submitted.
  final DateTime createdAt;

  /// UTC timestamp of the last status update (null if never updated).
  final DateTime? updatedAt;

  /// Current processing status assigned by the municipality.
  final ReportStatus status;

  /// Community-driven credibility tracking (confirmations / rejections).
  final CredibilityScore credibilityScore;

  /// URL of the photo attached to the report (null if no photo was added).
  final String? photoUrl;

  /// Device-local path to the photo before it has been uploaded.
  /// Only present on freshly created, not-yet-synced reports.
  final String? localPhotoPath;

  /// Identifier of the submitting user (anonymous UUID or authenticated ID).
  final String? submittedBy;

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
    this.submittedBy,
  });

  // ── Computed helpers ────────────────────────────────────────────

  /// Whether this report exists on the server yet.
  bool get isSynced => id != null;

  /// Whether the report is still open (not resolved or rejected).
  bool get isOpen =>
      status == ReportStatus.pending || status == ReportStatus.inProgress;

  /// Whether a photo is available (either uploaded or local).
  bool get hasPhoto => photoUrl != null || localPhotoPath != null;

  /// The best available photo source for display.
  String? get displayPhotoSource => photoUrl ?? localPhotoPath;

  // ── Serialization ───────────────────────────────────────────────

  /// Construct a [ReportModel] from a raw JSON map (API response).
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String?,
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
          : const CredibilityScore(),
      photoUrl: json['photoUrl'] as String?,
      localPhotoPath: json['localPhotoPath'] as String?,
      submittedBy: json['submittedBy'] as String?,
    );
  }

  /// Convert this model to a JSON map for API submission.
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
        if (submittedBy != null) 'submittedBy': submittedBy,
      };

  // ── Immutable update pattern (copyWith) ─────────────────────────
  // Allows providers to produce new state without mutating existing objects.

  ReportModel copyWith({
    String? id,
    ReportCategory? category,
    String? description,
    ReportLocation? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReportStatus? status,
    CredibilityScore? credibilityScore,
    String? photoUrl,
    String? localPhotoPath,
    String? submittedBy,
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
      submittedBy: submittedBy ?? this.submittedBy,
    );
  }

  // ── Equality & Debug ────────────────────────────────────────────
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
        'location: $location, '
        'credibility: $credibilityScore'
        ')';
  }
}
