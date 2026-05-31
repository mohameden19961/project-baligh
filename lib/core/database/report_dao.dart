import 'dart:math' as math;
import '../../utils/supabase_config.dart';
import '../../models/report_model.dart';

class ReportDao {
  Future<int> insert(ReportModel report) async {
    final authId = SupabaseConfig.client.auth.currentUser?.id;
    if (authId == null) {
      throw Exception('User must be authenticated to submit a report');
    }
    final map = report.toDbMap();
    map['user_id'] = authId;
    try {
      final response = await SupabaseConfig.client
          .from('reports')
          .insert(map)
          .select('id')
          .single();
      return response['id'] as int;
    } catch (e) {
      print('[ReportDao] insert failed: $e');
      rethrow;
    }
  }

  Future<ReportModel?> getById(int id) async {
    final response = await SupabaseConfig.client
        .from('reports')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return ReportModel.fromDbMap(response);
  }

  Future<List<ReportModel>> getAll({String? category, String? status}) async {
    var query = SupabaseConfig.client.from('reports').select();
    if (category != null) {
      query = query.eq('category', category);
    }
    if (status != null) {
      query = query.eq('status', status);
    }
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((m) => ReportModel.fromDbMap(m)).toList();
  }

  Future<List<ReportModel>> getByUserId(String userId) async {
    final response = await SupabaseConfig.client
        .from('reports')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((m) => ReportModel.fromDbMap(m)).toList();
  }

  Future<void> update(ReportModel report) async {
    final map = report.toDbMap();
    map.remove('user_id');
    map.remove('id');
    await SupabaseConfig.client
        .from('reports')
        .update(map)
        .eq('id', report.id!);
  }

  Future<void> updateConfirmCount(int reportId, int count) async {
    await SupabaseConfig.client
        .from('reports')
        .update({'confirm_count': count})
        .eq('id', reportId);
  }

  Future<void> updateDenyCount(int reportId, int count) async {
    await SupabaseConfig.client
        .from('reports')
        .update({'deny_count': count})
        .eq('id', reportId);
  }

  Future<void> delete(int id) async {
    await SupabaseConfig.client.from('reports').delete().eq('id', id);
  }

  Future<List<ReportModel>> getNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    const latDegreeKm = 111.32;
    const lonDegreeKm = 111.32;

    final latDelta = radiusKm / latDegreeKm;
    final lonDelta = radiusKm / (lonDegreeKm * math.cos(latitude * math.pi / 180.0));

    final response = await SupabaseConfig.client
        .from('reports')
        .select()
        .gte('latitude', latitude - latDelta)
        .lte('latitude', latitude + latDelta)
        .gte('longitude', longitude - lonDelta)
        .lte('longitude', longitude + lonDelta)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (response as List).map((m) => ReportModel.fromDbMap(m)).toList();
  }
}
