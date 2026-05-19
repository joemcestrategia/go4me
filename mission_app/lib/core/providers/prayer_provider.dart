import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go4me/core/models/prayer_request.dart';

class PrayerRepository {
  final SupabaseClient _client;

  PrayerRepository(this._client);

  Future<List<PrayerRequest>> getPrayerRequests({int limit = 30}) async {
    final response = await _client
        .from('prayer_requests')
        .select('*, profiles(full_name, avatar_url), prayer_participants(profile_id)')
        .order('created_at', ascending: false)
        .limit(limit);

    final currentUserId = _client.auth.currentUser?.id;

    return (response as List)
        .map((m) => PrayerRequest.fromMap(m, currentUserId: currentUserId))
        .toList();
  }

  Future<void> createPrayerRequest(String content, {bool isPraise = false}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Não autenticado');

    await _client.from('prayer_requests').insert({
      'profile_id': userId,
      'content': content,
      'is_praise': isPraise,
    });
  }

  Future<bool> togglePrayer(String prayerId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final existing = await _client
        .from('prayer_participants')
        .select()
        .eq('prayer_id', prayerId)
        .eq('profile_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('prayer_participants')
          .delete()
          .eq('prayer_id', prayerId)
          .eq('profile_id', userId);
      return false;
    } else {
      await _client.from('prayer_participants').insert({
        'prayer_id': prayerId,
        'profile_id': userId,
      });
      return true;
    }
  }

  Future<void> markAsAnswered(String prayerId) async {
    await _client
        .from('prayer_requests')
        .update({'is_answered': true})
        .eq('id', prayerId);
  }
}

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository(Supabase.instance.client);
});

final prayerRequestsProvider = FutureProvider<List<PrayerRequest>>((ref) async {
  final repo = ref.watch(prayerRepositoryProvider);
  return repo.getPrayerRequests();
});
