import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go4me/core/data/supabase_repository.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/models/user_profile.dart';
import 'package:go4me/core/services/joshua_project_service.dart';
import 'package:go4me/core/services/auth_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final repositoryProvider = Provider<SupabaseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRepository(client);
});

final allMissionariesProvider = FutureProvider<List<MissionaryData>>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return await repository.getAllMissionaries();
});

final missionaryBySlugProvider = FutureProvider.family<MissionaryData?, String>((ref, slug) async {
  final repository = ref.watch(repositoryProvider);
  return await repository.getMissionaryBySlug(slug);
});

final currentDonorProvider = FutureProvider<Donor?>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return null;

  try {
    final response = await Supabase.instance.client
        .from('donors')
        .select('*')
        .eq('profile_id', user.id)
        .maybeSingle();

    if (response != null) return Donor.fromJson(response);

    final profile = await ref.read(authRepositoryProvider).getUserProfile(user.id);
    return Donor(
      id: user.id,
      name: profile?.fullName ?? 'Semeador',
      avatarUrl: profile?.avatarUrl ?? '',
      amount: 0,
      timeAgo: '',
      totalDonated: 0,
      supportedMissionsCount: 0,
      livesImpactedCount: 0,
    );
  } catch (e) {
    return null;
  }
});

final currentMissionaryProvider = FutureProvider<MissionaryData?>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return null;

  try {
    final response = await Supabase.instance.client
        .from('missionaries')
        .select('*, projects(*), past_locations(*)')
        .eq('profile_id', user.id)
        .maybeSingle();

    if (response != null) return MissionaryData.fromJson(response);

    final missionaries = await ref.watch(allMissionariesProvider.future);
    if (missionaries.isNotEmpty) return missionaries.first;

    return null;
  } catch (e) {
    return null;
  }
});

final countriesProvider = FutureProvider<List<JoshuaCountry>>((ref) async {
  final service = ref.watch(joshuaProjectServiceProvider);
  return await service.getCountries();
});

final donationsByDonorProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];

  try {
    final response = await Supabase.instance.client
        .from('donations')
        .select('*, missionaries(name, slug, location, profile_image_url)')
        .eq('donor_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).cast<Map<String, dynamic>>();
  } catch (e) {
    return [];
  }
});

final donationsToMissionaryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, missionaryId) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];

  try {
    final response = await Supabase.instance.client
        .from('donations')
        .select('*, donors(name, avatar_url)')
        .eq('missionary_id', missionaryId)
        .order('created_at', ascending: false);

    return (response as List).cast<Map<String, dynamic>>();
  } catch (e) {
    return [];
  }
});
