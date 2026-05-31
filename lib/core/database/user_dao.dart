import '../../utils/supabase_config.dart';
import '../models/user_model.dart';

class UserDao {
  Future<void> insert(UserModel user) async {
    await SupabaseConfig.client.from('users').insert(user.toMap());
  }

  Future<UserModel?> getById(String id) async {
    final response = await SupabaseConfig.client
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<UserModel?> findByUsername(String username) async {
    final response = await SupabaseConfig.client
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();
    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<UserModel?> findByEmail(String email) async {
    final response = await SupabaseConfig.client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();
    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<List<UserModel>> getAll() async {
    final response = await SupabaseConfig.client.from('users').select();
    return (response as List).map((m) => UserModel.fromMap(m)).toList();
  }

  Future<void> update(UserModel user) async {
    await SupabaseConfig.client
        .from('users')
        .update(user.toMap())
        .eq('id', user.id!);
  }

  Future<void> delete(String id) async {
    await SupabaseConfig.client.from('users').delete().eq('id', id);
  }
}
