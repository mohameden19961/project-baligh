// lib/providers/report_provider.dart
// ─────────────────────────────────────────────────────────────────
// Controller layer — manages all report state for the Baligh app.
// Consumes: ReportModel, ReportService (injected at construction).
// Consumed by: HomeView, MapView, MyReportsView, ReportView.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

// ════════════════════════════════════════════════════════════════
// ENUM: ReportProviderStatus
// Fine-grained loading states — avoids boolean flag proliferation.
// ════════════════════════════════════════════════════════════════
enum ReportProviderStatus {
  idle,       // Nothing in flight, list may or may not be populated.
  loading,    // Initial fetch in progress (shows full-screen loader).
  refreshing, // Silent background refresh (list is already visible).
  submitting, // A new report is being sent to the backend.
  updating,   // A credibility vote is being processed.
  success,    // Last operation completed successfully (transient).
  error,      // Last operation failed (errorMessage is set).
}

// ════════════════════════════════════════════════════════════════
// CLASS: ReportProvider
// ════════════════════════════════════════════════════════════════
class ReportProvider extends ChangeNotifier {
  ReportProvider({ReportService? service})
      : _reportService = service ?? MockReportService();

  // ── Injected service (defaults to MockReportService) ─────────────
  final ReportService _reportService;

  // ── Internal state ───────────────────────────────────────────────
  List<ReportModel> _reports = [];
  ReportProviderStatus _status = ReportProviderStatus.idle;
  String? _errorMessage;

  // ── Filters ──────────────────────────────────────────────────────
  ReportCategory? _activeCategory;
  ReportStatus? _activeStatus;

  // ── Public getters ───────────────────────────────────────────────

  /// Full unfiltered list — used by the Map screen (all pins).
  List<ReportModel> get allReports => List.unmodifiable(_reports);

  /// Filtered list — used by HomeView and MyReportsView.
  List<ReportModel> get filteredReports {
    return _reports.where((r) {
      final matchesCategory =
          _activeCategory == null || r.category == _activeCategory;
      final matchesStatus =
          _activeStatus == null || r.status == _activeStatus;
      return matchesCategory && matchesStatus;
    }).toList();
  }

  /// Pending reports only — for the home screen summary badge.
  List<ReportModel> get pendingReports =>
      _reports.where((r) => r.status == ReportStatus.pending).toList();

  /// Resolved reports — for the stats widget.
  List<ReportModel> get resolvedReports =>
      _reports.where((r) => r.status == ReportStatus.resolved).toList();

  ReportProviderStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ReportCategory? get activeCategory => _activeCategory;
  ReportStatus? get activeStatus => _activeStatus;

  /// True only while the very first fetch is happening.
  bool get isLoading => _status == ReportProviderStatus.loading;

  /// True while a new report is being submitted.
  bool get isSubmitting => _status == ReportProviderStatus.submitting;

  /// True while a credibility vote is being processed.
  bool get isUpdating => _status == ReportProviderStatus.updating;

  /// True when any network operation is in flight.
  bool get isBusy =>
      _status == ReportProviderStatus.loading ||
      _status == ReportProviderStatus.submitting ||
      _status == ReportProviderStatus.updating ||
      _status == ReportProviderStatus.refreshing;

  // ── 1. FETCH ──────────────────────────────────────────────────────

  /// Fetches all reports via [ReportService]. Uses [loading] status on
  /// first call, [refreshing] on subsequent calls so the existing list
  /// stays visible.
  Future<void> fetchReports({bool silent = false}) async {
    _setStatus(
      _reports.isEmpty && !silent
          ? ReportProviderStatus.loading
          : ReportProviderStatus.refreshing,
    );
    _clearError();

    try {
      final data = await _reportService.fetchReports();
      _reports = data;
      _setStatus(ReportProviderStatus.idle);
    } catch (e, stackTrace) {
      debugPrint('[ReportProvider] fetchReports error: $e\n$stackTrace');
      _setError('Failed to load reports. Please try again.');
    }
  }

  // ── 2. ADD A NEW REPORT ───────────────────────────────────────────

  /// Adds [report] optimistically to the local list, then simulates
  /// sending it to the backend. Rolls back on failure.
  ///
  /// Returns `true` on success, `false` on failure (so the View can
  /// show the appropriate snackbar without reading provider state).
  Future<bool> addReport(ReportModel report) async {
    _setStatus(ReportProviderStatus.submitting);
    _clearError();

    // ── Optimistic insert ─────────────────────────────────────────
    // Prepend so the new report appears at the top of the list immediately.
    _reports = [report, ..._reports];
    notifyListeners();

    try {
      final synced = await _reportService.createReport(report);

      // Replace the optimistic entry with the server-confirmed one.
      _replaceReport(report, synced);
      _setStatus(ReportProviderStatus.success);

      // Reset to idle after a brief window so the UI can react to success.
      await Future.delayed(const Duration(milliseconds: 300));
      _setStatus(ReportProviderStatus.idle);

      return true;
    } catch (e, stackTrace) {
      debugPrint('[ReportProvider] addReport error: $e\n$stackTrace');

      // ── Rollback optimistic insert on failure ──────────────────
      _reports = _reports.where((r) => r != report).toList();
      _setError('Failed to submit report. Please try again.');

      return false;
    }
  }

  // ── 3. UPDATE CREDIBILITY SCORE ───────────────────────────────────

  /// Records a [confirmation] or rejection vote for [reportId].
  ///
  /// Also optimistic: the badge updates instantly while the API call
  /// runs in the background. Rolls back silently if the call fails.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> updateCredibility({
    required String reportId,
    required bool isConfirmation,
  }) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) {
      debugPrint('[ReportProvider] updateCredibility: id $reportId not found');
      return false;
    }

    _setStatus(ReportProviderStatus.updating);
    _clearError();

    final original = _reports[index];

    // ── Optimistic update ─────────────────────────────────────────
    final optimistic = original.copyWith(
      credibilityScore: isConfirmation
          ? original.credibilityScore.copyWithConfirmation()
          : original.credibilityScore.copyWithRejection(),
    );
    _reports = List.from(_reports)..[index] = optimistic;
    notifyListeners();

    try {
      // ── MOCK: simulated network delay ──────────────────────────
      await Future.delayed(const Duration(milliseconds: 500));

      // Real call will look like:
      // await _reportService.voteOnReport(
      //   reportId: reportId,
      //   isConfirmation: isConfirmation,
      // );
      // ── END MOCK ───────────────────────────────────────────────

      _setStatus(ReportProviderStatus.idle);
      return true;
    } catch (e, stackTrace) {
      debugPrint('[ReportProvider] updateCredibility error: $e\n$stackTrace');

      // ── Rollback to original score on failure ──────────────────
      _reports = List.from(_reports)..[index] = original;
      _setError('Failed to record your vote. Please try again.');

      return false;
    }
  }

  // ── FILTERS ───────────────────────────────────────────────────────

  /// Set or clear the active category filter.
  void filterByCategory(ReportCategory? category) {
    if (_activeCategory == category) return;
    _activeCategory = category;
    notifyListeners();
  }

  /// Set or clear the active status filter.
  void filterByStatus(ReportStatus? status) {
    if (_activeStatus == status) return;
    _activeStatus = status;
    notifyListeners();
  }

  /// Reset all filters to show every report.
  void clearFilters() {
    if (_activeCategory == null && _activeStatus == null) return;
    _activeCategory = null;
    _activeStatus = null;
    notifyListeners();
  }

  // ── SINGLE REPORT LOOKUP ──────────────────────────────────────────

  /// Returns the report matching [id], or null if not found.
  /// Used by the detail screen to avoid passing the whole object
  /// through Navigator arguments.
  ReportModel? getById(String id) {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── PRIVATE HELPERS ───────────────────────────────────────────────

  void _setStatus(ReportProviderStatus s) {
    _status = s;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = ReportProviderStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Swap [old] with [updated] in the list, preserving order.
  void _replaceReport(ReportModel old, ReportModel updated) {
    final index = _reports.indexOf(old);
    if (index != -1) {
      _reports = List.from(_reports)..[index] = updated;
    }
  }
}
