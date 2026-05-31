// MVC - Controller
import 'package:flutter/foundation.dart';
import '../core/models/vote_model.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../core/services/report_service_db.dart';

enum ReportProviderStatus {
  idle,
  loading,
  refreshing,
  submitting,
  updating,
  success,
  error,
}

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService;

  List<ReportModel> _reports = [];
  final Map<int, VoteType?> _userVotes = {};
  ReportProviderStatus _status = ReportProviderStatus.idle;
  String? _errorMessage;
  ReportCategory? _activeCategory;
  ReportStatus? _activeStatus;

  ReportProvider({ReportService? service})
      : _reportService = service ?? ReportServiceDb() as ReportService;

  List<ReportModel> get allReports => List.unmodifiable(_reports);

  List<ReportModel> get filteredReports {
    return _reports.where((r) {
      final matchesCategory =
          _activeCategory == null || r.category == _activeCategory;
      final matchesStatus =
          _activeStatus == null || r.status == _activeStatus;
      return matchesCategory && matchesStatus;
    }).toList();
  }

  List<ReportModel> get pendingReports =>
      _reports.where((r) => r.status == ReportStatus.pending).toList();

  List<ReportModel> get validatedReports =>
      _reports.where((r) => r.status == ReportStatus.validated).toList();

  ReportProviderStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ReportCategory? get activeCategory => _activeCategory;
  ReportStatus? get activeStatus => _activeStatus;

  bool get isLoading => _status == ReportProviderStatus.loading;
  bool get isSubmitting => _status == ReportProviderStatus.submitting;
  bool get isUpdating => _status == ReportProviderStatus.updating;
  bool get isBusy =>
      _status == ReportProviderStatus.loading ||
      _status == ReportProviderStatus.submitting ||
      _status == ReportProviderStatus.updating ||
      _status == ReportProviderStatus.refreshing;

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

  VoteType? userVoteFor(int reportId) => _userVotes[reportId];

  Future<void> fetchUserVote(int reportId, String userId) async {
    final vote = await _reportService.getUserVote(reportId, userId);
    _userVotes[reportId] = vote;
    notifyListeners();
  }

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

  Future<VoteType?> getUserVote(int reportId, String userId) {
    return _reportService.getUserVote(reportId, userId);
  }

  void filterByCategory(ReportCategory? category) {
    if (_activeCategory == category) return;
    _activeCategory = category;
    notifyListeners();
  }

  void filterByStatus(ReportStatus? status) {
    if (_activeStatus == status) return;
    _activeStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    if (_activeCategory == null && _activeStatus == null) return;
    _activeCategory = null;
    _activeStatus = null;
    notifyListeners();
  }

  ReportModel? getById(int id) {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

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

  void _replaceReport(ReportModel old, ReportModel updated) {
    final index = _reports.indexOf(old);
    if (index != -1) {
      _reports = List.from(_reports)..[index] = updated;
    }
  }
}
