import 'package:flutter/foundation.dart';
import '../../utils/supabase_config.dart';
import '../models/vote_model.dart';

class VoteDao {
  Future<void> insert(VoteModel vote) async {
    try {
      await SupabaseConfig.client.from('votes').insert(vote.toMap());
      debugPrint(
          '[VoteDao] insert success: report=${vote.reportId}, user=${vote.userId}, type=${vote.voteType.name}');
    } catch (e) {
      debugPrint(
          '[VoteDao] insert FAILED: report=${vote.reportId}, user=${vote.userId}, type=${vote.voteType.name}, error=$e');
      rethrow;
    }
  }

  Future<VoteModel?> getVote(int reportId, String userId) async {
    final response = await SupabaseConfig.client
        .from('votes')
        .select()
        .eq('report_id', reportId)
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return VoteModel.fromMap(response);
  }

  Future<List<VoteModel>> getByReportId(int reportId) async {
    final response = await SupabaseConfig.client
        .from('votes')
        .select()
        .eq('report_id', reportId);
    return (response as List).map((m) => VoteModel.fromMap(m)).toList();
  }

  Future<Map<String, int>> getVoteCounts(int reportId) async {
    final response = await SupabaseConfig.client
        .from('votes')
        .select('vote_type')
        .eq('report_id', reportId);

    int confirm = 0;
    int deny = 0;
    for (final row in response as List) {
      if (row['vote_type'] == 'confirm') {
        confirm++;
      } else if (row['vote_type'] == 'deny') {
        deny++;
      }
    }
    return {'confirm': confirm, 'deny': deny};
  }

  Future<bool> hasVoted(int reportId, String userId) async {
    final response = await SupabaseConfig.client
        .from('votes')
        .select('id')
        .eq('report_id', reportId)
        .eq('user_id', userId);
    return (response as List).isNotEmpty;
  }

  Future<void> delete(int reportId, String userId) async {
    await SupabaseConfig.client
        .from('votes')
        .delete()
        .eq('report_id', reportId)
        .eq('user_id', userId);
  }
}
