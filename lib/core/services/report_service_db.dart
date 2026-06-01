import '../database/report_dao.dart';
import '../database/vote_dao.dart';
import 'report_service.dart';
import '../models/report_model.dart';
import '../models/vote_model.dart';
import 'notification_service.dart';
import '../../utils/supabase_config.dart';

class ReportServiceDb extends ReportService {
  final ReportDao _reportDao = ReportDao();
  final VoteDao _voteDao = VoteDao();
  final NotificationService _notificationService = NotificationService();

  @override
  Future<List<ReportModel>> fetchReports() => getReports();

  @override
  Future<List<ReportModel>> getReports({String? category, String? status}) {
    return _reportDao.getAll(category: category, status: status);
  }

  @override
  Future<ReportModel?> getReportById(int id) {
    return _reportDao.getById(id);
  }

  @override
  Future<List<ReportModel>> getMyReports(String userId) {
    return _reportDao.getByUserId(userId);
  }

  @override
  Future<ReportModel> createReport(ReportModel report) => addReport(report);

  @override
  Future<ReportModel> addReport(ReportModel report) async {
    if (report.userId == null) return report;
    final id = await _reportDao.insert(report);
    final saved = report.copyWith(id: id);
    await _notificationService.createAlertForNearbyUsers(saved);
    return saved;
  }

  @override
  Future<Map<String, int>> voteOnReport({
    required String reportId,
    required bool isConfirmation,
    required String userId,
  }) async {
    final id = int.tryParse(reportId);
    if (id == null) return {'confirm': 0, 'deny': 0};

    final newVoteType = isConfirmation ? VoteType.confirm : VoteType.deny;
    final existingVote = await _voteDao.getVote(id, userId);

    if (existingVote != null) {
      if (existingVote.voteType == newVoteType) {
        // Same vote → cancel (delete the vote, toggle off)
        await _voteDao.delete(id, userId);
      } else {
        // Opposite vote → replace (delete old, insert new)
        await _voteDao.delete(id, userId);
        final vote = VoteModel(
          reportId: id,
          userId: userId,
          voteType: newVoteType,
          createdAt: DateTime.now(),
        );
        await _voteDao.insert(vote);
      }
    } else {
      // No existing vote → insert new
      final vote = VoteModel(
        reportId: id,
        userId: userId,
        voteType: newVoteType,
        createdAt: DateTime.now(),
      );
      await _voteDao.insert(vote);
    }

    final counts = await _voteDao.getVoteCounts(id);
    await SupabaseConfig.client.rpc('update_vote_counts', params: {
      'p_report_id': id,
      'p_confirm_count': counts['confirm']!,
      'p_deny_count': counts['deny']!,
    });
    return counts;
  }

  @override
  Future<VoteType?> getUserVote(int reportId, String userId) async {
    final vote = await _voteDao.getVote(reportId, userId);
    return vote?.voteType;
  }

  @override
  Future<void> updateReport(int id, ReportModel report) {
    return _reportDao.update(report.copyWith(id: id));
  }

  @override
  Future<void> deleteReport(int id) {
    return _reportDao.delete(id);
  }

  @override
  Future<void> setReportStatus(int id, ReportStatus status) async {
    final report = await _reportDao.getById(id);
    if (report != null) {
      await _reportDao.update(report.copyWith(status: status));
    }
  }

  @override
  Stream<List<ReportModel>> watchReports({String? category, String? status}) {
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      return await getReports(category: category, status: status);
    }).asyncExpand((future) => Stream.fromFuture(future));
  }
}
