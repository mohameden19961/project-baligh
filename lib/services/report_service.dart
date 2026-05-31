// lib/services/report_service.dart
// ─────────────────────────────────────────────────────────────────
// Service layer — abstract data-access contract for reports.
// Pure Dart, zero Flutter dependencies. Consumed by ReportProvider
// via constructor injection so the real HTTP implementation can be
// swapped in without touching any controller logic.
// ─────────────────────────────────────────────────────────────────

import '../models/report_model.dart';

// ════════════════════════════════════════════════════════════════
// ABSTRACT INTERFACE: ReportService
// ════════════════════════════════════════════════════════════════
abstract class ReportService {
  /// Fetch all reports from the backing store.
  Future<List<ReportModel>> fetchReports();

  /// Persist a new [report]. Returns the server-confirmed copy
  /// (with an assigned id and final status).
  Future<ReportModel> createReport(ReportModel report);

  /// Record a community credibility vote against [reportId].
  /// [isConfirmation] = true → +1 confirmation, false → +1 rejection.
  Future<void> voteOnReport({
    required String reportId,
    required bool isConfirmation,
  });
}

// ════════════════════════════════════════════════════════════════
// CONCRETE IMPLEMENTATION: MockReportService
// Provides realistic in-memory Nouakchott sample data so the UI
// can be developed end-to-end before the real API exists.
// ════════════════════════════════════════════════════════════════
class MockReportService implements ReportService {
  @override
  Future<List<ReportModel>> fetchReports() async {
    // Simulated network round-trip.
    await Future.delayed(const Duration(milliseconds: 900));
    return _buildMockReports();
  }

  @override
  Future<ReportModel> createReport(ReportModel report) async {
    // Simulated network round-trip.
    await Future.delayed(const Duration(milliseconds: 700));
    return report.copyWith(
      id: _generateMockId(),
      status: ReportStatus.pending,
    );
  }

  @override
  Future<void> voteOnReport({
    required String reportId,
    required bool isConfirmation,
  }) async {
    // Simulated network round-trip.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ── PRIVATE HELPERS ───────────────────────────────────────────────

  static String _generateMockId() =>
      'RPT-${DateTime.now().millisecondsSinceEpoch}';

  // ── MOCK DATA FACTORY ─────────────────────────────────────────────
  // Realistic sample data for Nouakchott, Mauritania.
  // Delete this method entirely when the real API is connected.

  static List<ReportModel> _buildMockReports() {
    final now = DateTime.now();

    return [
      ReportModel(
        id: 'RPT-001',
        category: ReportCategory.roads,
        description:
            'حفرة كبيرة في الطريق تسبب حوادث متكررة وتضر بالمركبات.',
        location: const ReportLocation(
          latitude: 18.0735,
          longitude: -15.9582,
          address: 'شارع جمال عبد الناصر، نواكشوط',
        ),
        createdAt: now.subtract(const Duration(hours: 2)),
        status: ReportStatus.inProgress,
        credibilityScore: const CredibilityScore(confirmations: 14, rejections: 1),
        submittedBy: 'user-abc',
      ),
      ReportModel(
        id: 'RPT-002',
        category: ReportCategory.lighting,
        description:
            'عمود الإنارة معطل منذ أسبوعين مما يجعل الشارع مظلماً ليلاً.',
        location: const ReportLocation(
          latitude: 18.0791,
          longitude: -15.9653,
          address: 'حي تيارت، نواكشوط',
        ),
        createdAt: now.subtract(const Duration(days: 3)),
        status: ReportStatus.pending,
        credibilityScore: const CredibilityScore(confirmations: 7, rejections: 0),
        submittedBy: 'user-def',
      ),
      ReportModel(
        id: 'RPT-003',
        category: ReportCategory.waste,
        description:
            'تراكم النفايات في الزاوية الشمالية للسوق يسبب رائحة كريهة.',
        location: const ReportLocation(
          latitude: 18.0862,
          longitude: -15.9721,
          address: 'السوق المركزي، نواكشوط',
        ),
        createdAt: now.subtract(const Duration(days: 1)),
        status: ReportStatus.pending,
        credibilityScore: const CredibilityScore(confirmations: 22, rejections: 3),
        submittedBy: 'user-ghi',
      ),
      ReportModel(
        id: 'RPT-004',
        category: ReportCategory.water,
        description:
            'تسرب مائي من أنبوب رئيسي يهدر المياه ويتلف الرصيف.',
        location: const ReportLocation(
          latitude: 18.0678,
          longitude: -15.9489,
          address: 'حي كيبه، نواكشوط',
        ),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        status: ReportStatus.resolved,
        credibilityScore: const CredibilityScore(confirmations: 31, rejections: 2),
        submittedBy: 'user-jkl',
      ),
      ReportModel(
        id: 'RPT-005',
        category: ReportCategory.parks,
        description:
            'الحديقة العامة بحاجة إلى صيانة عاجلة؛ الأعشاب طويلة ومقاعد الجلوس مكسورة.',
        location: const ReportLocation(
          latitude: 18.0920,
          longitude: -15.9810,
          address: 'حديقة الصداقة، نواكشوط',
        ),
        createdAt: now.subtract(const Duration(hours: 8)),
        status: ReportStatus.pending,
        credibilityScore: const CredibilityScore(confirmations: 5, rejections: 1),
        submittedBy: 'user-mno',
      ),
      ReportModel(
        id: 'RPT-006',
        category: ReportCategory.roads,
        description:
            'الإشارة الضوئية لا تعمل في تقاطع مكتظ بالمركبات.',
        location: const ReportLocation(
          latitude: 18.0740,
          longitude: -15.9600,
          address: 'تقاطع شارع الاستقلال، نواكشوط',
        ),
        createdAt: now.subtract(const Duration(days: 7)),
        status: ReportStatus.rejected,
        credibilityScore: const CredibilityScore(confirmations: 2, rejections: 9),
        submittedBy: 'user-pqr',
      ),
    ];
  }
}
