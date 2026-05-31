import '../core/models/vote_model.dart';
import '../models/report_model.dart';

abstract class ReportService {
  Future<List<ReportModel>> fetchReports();
  Future<ReportModel> createReport(ReportModel report);

  /// Vote on a report. Returns the new {confirm, deny} counts from DB.
  /// - If same vote type already exists → cancels (deletes the vote)
  /// - If opposite vote type exists → replaces it
  /// - If no vote → inserts new
  Future<Map<String, int>> voteOnReport({
    required String reportId,
    required bool isConfirmation,
    required String userId,
  });

  Future<VoteType?> getUserVote(int reportId, String userId);

  Future<List<ReportModel>> getReports({String? category, String? status});
  Future<ReportModel?> getReportById(int id);
  Future<List<ReportModel>> getMyReports(String userId);
  Future<ReportModel> addReport(ReportModel report);
  Future<void> updateReport(int id, ReportModel report);
  Future<void> deleteReport(int id);
  Future<void> setReportStatus(int id, ReportStatus status);
  Stream<List<ReportModel>> watchReports({String? category, String? status});
}
