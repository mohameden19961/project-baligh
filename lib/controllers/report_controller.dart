// MVC - Controller
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/models/vote_model.dart';
import '../core/models/report_model.dart';
import '../core/services/report_service.dart';
import '../core/services/report_service_db.dart';
import '../utils/supabase_config.dart';

/// Représente les différents états possibles du [ReportProvider].
enum ReportProviderStatus {
  /// Aucune opération en cours, état de repos.
  idle,

  /// Chargement initial de la liste des signalements.
  loading,

  /// Rechargement silencieux en arrière-plan.
  refreshing,

  /// Envoi d'un nouveau signalement en cours.
  submitting,

  /// Mise à jour d'un signalement existant en cours.
  updating,

  /// Dernière opération terminée avec succès.
  success,

  /// Une erreur s'est produite lors de la dernière opération.
  error,
}

/// Contrôleur des signalements citoyens.
///
/// Gère le cycle de vie complet des [ReportModel] : chargement,
/// ajout, modification, suppression et vote de crédibilité.
/// S'abonne aux changements Supabase Realtime pour mettre à jour
/// l'UI automatiquement quand l'admin modifie un statut.
/// Notifie les widgets abonnés via [ChangeNotifier] à chaque
/// changement d'état ou de données.
class ReportProvider extends ChangeNotifier {
  final ReportService _reportService;

  /// Abonnement Realtime Supabase sur la table `reports`.
  RealtimeChannel? _realtimeChannel;

  /// Liste interne de tous les signalements chargés.
  List<ReportModel> _reports = [];

  /// Cache des votes de l'utilisateur courant, indexé par [ReportModel.id].
  final Map<int, VoteType?> _userVotes = {};

  /// État courant du contrôleur.
  ReportProviderStatus _status = ReportProviderStatus.idle;

  /// Message d'erreur de la dernière opération échouée, ou `null`.
  String? _errorMessage;

  /// Filtre de catégorie actif, ou `null` si aucun filtre.
  ReportCategory? _activeCategory;

  /// Filtre de statut actif, ou `null` si aucun filtre.
  ReportStatus? _activeStatus;

  /// Crée un [ReportProvider] avec un [service] optionnel.
  ///
  /// Si [service] n'est pas fourni, [ReportServiceDb] est utilisé par défaut.
  ReportProvider({ReportService? service})
      : _reportService = service ?? ReportServiceDb() as ReportService;

  /// Retourne une vue non-modifiable de tous les signalements chargés.
  List<ReportModel> get allReports => List.unmodifiable(_reports);

  /// Retourne les signalements filtrés selon [activeCategory] et [activeStatus].
  List<ReportModel> get filteredReports {
    return _reports.where((r) {
      final matchesCategory =
          _activeCategory == null || r.category == _activeCategory;
      final matchesStatus =
          _activeStatus == null || r.status == _activeStatus;
      return matchesCategory && matchesStatus;
    }).toList();
  }

  /// Retourne uniquement les signalements en attente de validation.
  List<ReportModel> get pendingReports =>
      _reports.where((r) => r.status == ReportStatus.pending).toList();

  /// Retourne uniquement les signalements validés par la communauté.
  List<ReportModel> get validatedReports =>
      _reports.where((r) => r.status == ReportStatus.validated).toList();

  /// Retourne l'état courant du contrôleur.
  ReportProviderStatus get status => _status;

  /// Retourne le message d'erreur de la dernière opération, ou `null`.
  String? get errorMessage => _errorMessage;

  /// Retourne le filtre de catégorie actif, ou `null`.
  ReportCategory? get activeCategory => _activeCategory;

  /// Retourne le filtre de statut actif, ou `null`.
  ReportStatus? get activeStatus => _activeStatus;

  /// Retourne `true` si un chargement initial est en cours.
  bool get isLoading => _status == ReportProviderStatus.loading;

  /// Retourne `true` si un envoi de signalement est en cours.
  bool get isSubmitting => _status == ReportProviderStatus.submitting;

  /// Retourne `true` si une mise à jour est en cours.
  bool get isUpdating => _status == ReportProviderStatus.updating;

  /// Retourne `true` si une opération bloquante est en cours
  /// (chargement, envoi, mise à jour ou rafraîchissement).
  bool get isBusy =>
      _status == ReportProviderStatus.loading ||
      _status == ReportProviderStatus.submitting ||
      _status == ReportProviderStatus.updating ||
      _status == ReportProviderStatus.refreshing;

  // ── Realtime ────────────────────────────────────────────────────────────────

  /// Démarre l'abonnement Supabase Realtime sur la table `reports`.
  ///
  /// Réagit aux événements UPDATE (ex: changement de statut depuis le dashboard)
  /// et INSERT (nouveau signalement) en mettant à jour la liste locale et
  /// en notifiant les listeners sans recharger l'ensemble des données.
  /// Idempotent : appeler plusieurs fois n'ouvre pas plusieurs canaux.
  void subscribeToRealtimeUpdates() {
    if (_realtimeChannel != null) return;

    _realtimeChannel = SupabaseConfig.client
        .channel('public:reports')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'reports',
          callback: (payload) {
            debugPrint('[ReportProvider] Realtime UPDATE: ${payload.newRecord}');
            _applyRealtimeUpdate(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'reports',
          callback: (payload) {
            debugPrint('[ReportProvider] Realtime INSERT: ${payload.newRecord}');
            _applyRealtimeInsert(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'reports',
          callback: (payload) {
            final deletedId = payload.oldRecord['id'] as int?;
            debugPrint('[ReportProvider] Realtime DELETE: id=$deletedId');
            if (deletedId != null) _applyRealtimeDelete(deletedId);
          },
        )
        .subscribe();

    debugPrint('[ReportProvider] Subscribed to Supabase Realtime on reports');
  }

  /// Applique un événement UPDATE reçu en temps réel.
  ///
  /// Met à jour uniquement le signalement concerné dans [_reports]
  /// en appliquant le nouveau statut et les compteurs de votes.
  void _applyRealtimeUpdate(Map<String, dynamic> record) {
    final id = record['id'] as int?;
    if (id == null) return;

    final index = _reports.indexWhere((r) => r.id == id);
    if (index == -1) {
      // Signalement inconnu — rafraîchir silencieusement
      fetchReports(silent: true);
      return;
    }

    final existing = _reports[index];
    final newStatus = ReportStatus.fromJson(
      record['status'] as String? ?? 'pending',
    );
    final confirmCount = (record['confirm_count'] as num?)?.toInt() ?? existing.credibilityScore.confirmations;
    final denyCount = (record['deny_count'] as num?)?.toInt() ?? existing.credibilityScore.rejections;

    final updated = existing.copyWith(
      status: newStatus,
      credibilityScore: CredibilityScore(
        confirmations: confirmCount,
        rejections: denyCount,
      ),
    );

    _reports = List.from(_reports)..[index] = updated;
    notifyListeners();
  }

  /// Applique un événement INSERT reçu en temps réel.
  ///
  /// Ajoute le nouveau signalement en tête de liste uniquement s'il
  /// n'est pas déjà présent (évite les doublons avec l'ajout optimiste).
  void _applyRealtimeInsert(Map<String, dynamic> record) {
    final id = record['id'] as int?;
    if (id == null) return;

    // Ne pas ajouter si déjà présent (ajout optimiste)
    if (_reports.any((r) => r.id == id)) return;

    try {
      final report = ReportModel.fromDbMap({
        ...record,
        'photo_url': record['photo_url'],
        'created_at': record['created_at'],
      });
      _reports = [report, ..._reports];
      notifyListeners();
    } catch (e) {
      debugPrint('[ReportProvider] _applyRealtimeInsert parse error: $e');
      fetchReports(silent: true);
    }
  }

  /// Applique un événement DELETE reçu en temps réel.
  void _applyRealtimeDelete(int id) {
    final before = _reports.length;
    _reports = _reports.where((r) => r.id != id).toList();
    if (_reports.length != before) notifyListeners();
  }

  /// Annule l'abonnement Realtime et libère les ressources.
  ///
  /// Doit être appelé dans [dispose] ou quand le contrôleur n'est plus utilisé.
  Future<void> unsubscribeRealtime() async {
    if (_realtimeChannel != null) {
      await SupabaseConfig.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
      debugPrint('[ReportProvider] Unsubscribed from Supabase Realtime');
    }
  }

  @override
  void dispose() {
    unsubscribeRealtime();
    super.dispose();
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  /// Charge ou rafraîchit la liste des signalements depuis le service.
  ///
  /// Si [silent] est `true`, passe en état [ReportProviderStatus.refreshing]
  /// plutôt que [ReportProviderStatus.loading] pour éviter un indicateur
  /// de chargement visible. En cas d'échec, [errorMessage] est renseigné.
  Future<void> fetchReports({bool silent = false}) async {
    _setStatus(
      _reports.isEmpty && !silent
          ? ReportProviderStatus.loading
          : ReportProviderStatus.refreshing,
    );
    _clearError();

    try {
      final data = await _reportService.getReports();
      _reports = data;
      _setStatus(ReportProviderStatus.idle);
    } catch (e, stackTrace) {
      debugPrint('[ReportProvider] fetchReports error: $e\n$stackTrace');
      _setError('Failed to load reports. Please try again.');
    }
  }

  /// Ajoute un nouveau [report] de façon optimiste.
  ///
  /// Le signalement est inséré en tête de liste immédiatement, puis
  /// synchronisé avec le service. En cas d'échec, il est retiré de
  /// la liste et [errorMessage] est renseigné.
  /// Retourne `true` si la synchronisation a réussi, `false` sinon.
  Future<bool> addReport(ReportModel report) async {
    _setStatus(ReportProviderStatus.submitting);
    _clearError();

    _reports = [report, ..._reports];
    notifyListeners();

    try {
      final synced = await _reportService.addReport(report);
      _replaceReport(report, synced);
      _setStatus(ReportProviderStatus.success);
      await Future.delayed(const Duration(milliseconds: 300));
      _setStatus(ReportProviderStatus.idle);
      return true;
    } catch (e, stackTrace) {
      debugPrint('[ReportProvider] addReport error: $e\n$stackTrace');
      _reports = _reports.where((r) => r != report).toList();
      _setError('Failed to submit report. Please try again.');
      return false;
    }
  }

  /// Retourne le vote de l'utilisateur courant pour le signalement [reportId],
  /// ou `null` s'il n'a pas encore voté.
  VoteType? userVoteFor(int reportId) => _userVotes[reportId];

  /// Récupère et met en cache le vote de [userId] pour le signalement [reportId].
  Future<void> fetchUserVote(int reportId, String userId) async {
    final vote = await _reportService.getUserVote(reportId, userId);
    _userVotes[reportId] = vote;
    notifyListeners();
  }

  /// Enregistre le vote de crédibilité de [userId] sur le signalement [reportId].
  ///
  /// Si [isConfirmation] est `true`, c'est un vote de confirmation ; sinon un
  /// vote de réfutation. Met à jour le score de crédibilité de façon optimiste.
  /// Retourne `true` si l'opération a réussi, `false` sinon.
  Future<bool> updateCredibility({
    required int reportId,
    required bool isConfirmation,
    required String userId,
  }) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) {
      debugPrint('[ReportProvider] updateCredibility: id $reportId not found');
      return false;
    }

    _setStatus(ReportProviderStatus.updating);
    _clearError();

    final original = _reports[index];

    try {
      final counts = await _reportService.voteOnReport(
        reportId: reportId.toString(),
        isConfirmation: isConfirmation,
        userId: userId,
      );
      final updated = original.copyWith(
        credibilityScore: CredibilityScore(
          confirmations: counts['confirm']!,
          rejections: counts['deny']!,
        ),
      );
      _reports = List.from(_reports)..[index] = updated;
      _userVotes[reportId] = await _reportService.getUserVote(reportId, userId);
      _setStatus(ReportProviderStatus.idle);
      return true;
    } catch (e, stackTrace) {
      debugPrint('[ReportProvider] updateCredibility error: $e\n$stackTrace');
      _reports = List.from(_reports)..[index] = original;
      _setError('Failed to record your vote. Please try again.');
      return false;
    }
  }

  /// Retourne directement le vote de [userId] pour [reportId] depuis le service.
  Future<VoteType?> getUserVote(int reportId, String userId) {
    return _reportService.getUserVote(reportId, userId);
  }

  /// Applique un filtre par [category] sur [filteredReports].
  ///
  /// Passer `null` supprime le filtre de catégorie.
  void filterByCategory(ReportCategory? category) {
    if (_activeCategory == category) return;
    _activeCategory = category;
    notifyListeners();
  }

  /// Applique un filtre par [status] sur [filteredReports].
  ///
  /// Passer `null` supprime le filtre de statut.
  void filterByStatus(ReportStatus? status) {
    if (_activeStatus == status) return;
    _activeStatus = status;
    notifyListeners();
  }

  /// Supprime tous les filtres actifs (catégorie et statut).
  void clearFilters() {
    if (_activeCategory == null && _activeStatus == null) return;
    _activeCategory = null;
    _activeStatus = null;
    notifyListeners();
  }

  /// Retourne le signalement dont l'identifiant est [id], ou `null` s'il est introuvable.
  ReportModel? getById(int id) {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Supprime le signalement identifié par [id] de façon optimiste.
  ///
  /// Retire immédiatement l'entrée de la liste et tente la suppression
  /// côté service. En cas d'échec, réinsère le signalement à sa position
  /// d'origine et renseigne [errorMessage].
  /// Retourne `true` si la suppression a réussi, `false` sinon.
  Future<bool> deleteReport(int id) async {
    _setStatus(ReportProviderStatus.updating);
    _clearError();
    final originalIndex = _reports.indexWhere((r) => r.id == id);
    if (originalIndex == -1) return false;
    final original = _reports[originalIndex];
    _reports = List.from(_reports)..removeAt(originalIndex);
    notifyListeners();

    try {
      await _reportService.deleteReport(id);
      _setStatus(ReportProviderStatus.idle);
      return true;
    } catch (e, stackTrace) {
      debugPrint('[ReportProvider] deleteReport error: $e\n$stackTrace');
      _reports = List.from(_reports)..insert(originalIndex, original);
      _setError('Failed to delete report.');
      return false;
    }
  }

  /// Modifie le signalement [id] avec les données de [updated] de façon optimiste.
  ///
  /// Applique les changements localement, puis tente la mise à jour côté service.
  /// En cas d'échec, restaure l'état d'origine et renseigne [errorMessage].
  /// Retourne `true` si la mise à jour a réussi, `false` sinon.
  Future<bool> editReport(int id, ReportModel updated) async {
    _setStatus(ReportProviderStatus.updating);
    _clearError();
    final index = _reports.indexWhere((r) => r.id == id);
    if (index == -1) return false;
    final original = _reports[index];
    _reports = List.from(_reports)..[index] = updated;
    notifyListeners();

    try {
      await _reportService.updateReport(id, updated);
      _setStatus(ReportProviderStatus.idle);
      return true;
    } catch (e, stackTrace) {
      debugPrint('[ReportProvider] editReport error: $e\n$stackTrace');
      _reports = List.from(_reports)..[index] = original;
      _setError('Failed to update report.');
      return false;
    }
  }

  // ── Helpers privés ──────────────────────────────────────────────────────────

  /// Met à jour [_status] et notifie les listeners.
  void _setStatus(ReportProviderStatus s) {
    _status = s;
    notifyListeners();
  }

  /// Positionne l'état en erreur avec [message] et notifie les listeners.
  void _setError(String message) {
    _errorMessage = message;
    _status = ReportProviderStatus.error;
    notifyListeners();
  }

  /// Efface le message d'erreur courant sans notifier.
  void _clearError() {
    _errorMessage = null;
  }

  /// Remplace [old] par [updated] dans la liste interne.
  ///
  /// Si [old] n'est pas trouvé, la liste reste inchangée.
  void _replaceReport(ReportModel old, ReportModel updated) {
    final index = _reports.indexOf(old);
    if (index != -1) {
      _reports = List.from(_reports)..[index] = updated;
    }
  }
}
