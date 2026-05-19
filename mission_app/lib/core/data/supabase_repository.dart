import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go4me/core/models/missionary.dart';

class SupabaseRepository {
  final SupabaseClient _client;

  SupabaseRepository(this._client);

  Future<List<MissionaryData>> getAllMissionaries() async {
    try {
      final response = await _client
          .from('missionaries')
          .select('*, projects(*), past_locations(*)')
          .order('name');

      return (response as List)
          .map((json) => MissionaryData.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MissionaryData?> getMissionaryBySlug(String slug) async {
    try {
      final response = await _client
          .from('missionaries')
          .select('*, projects(*), past_locations(*)')
          .eq('slug', slug)
          .maybeSingle();

      if (response == null) return null;
      return MissionaryData.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<MissionaryData?> getMissionaryById(String id) async {
    try {
      final response = await _client
          .from('missionaries')
          .select('*, projects(*), past_locations(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return MissionaryData.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Donor?> getDonorByProfileId(String profileId) async {
    try {
      final response = await _client
          .from('donors')
          .select('*')
          .eq('profile_id', profileId)
          .maybeSingle();

      if (response == null) return null;
      return Donor.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<Project>> getProjectsByMissionary(String missionaryId) async {
    try {
      final response = await _client
          .from('projects')
          .select('*')
          .eq('missionary_id', missionaryId);

      return (response as List)
          .map((json) => Project.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateMissionaryProfile(String id, Map<String, dynamic> updates) async {
    await _client.from('missionaries').update(updates).eq('id', id);
  }

  Future<void> updateDonorProfile(String id, Map<String, dynamic> updates) async {
    await _client.from('donors').update(updates).eq('id', id);
  }

  Future<List<MissionaryData>> getMissionariesByCountry(String countryCode) async {
    try {
      final response = await _client
          .from('missionaries')
          .select('*, projects(*), past_locations(*)')
          .eq('country_code', countryCode)
          .eq('is_public', true);

      return (response as List)
          .map((json) => MissionaryData.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<MissionaryData>> searchMissionaries(String query) async {
    try {
      final response = await _client
          .from('missionaries')
          .select('*, projects(*), past_locations(*)')
          .or('name.ilike.%$query%,location.ilike.%$query%,nationality.ilike.%$query%')
          .eq('is_public', true)
          .limit(20);

      return (response as List)
          .map((json) => MissionaryData.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
