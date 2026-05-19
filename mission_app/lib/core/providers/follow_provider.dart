import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/core/services/social_repository.dart';

final isFollowingProvider = FutureProvider.family<bool, String>((ref, profileId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return await repository.isFollowing(profileId);
});

final followerCountProvider = FutureProvider.family<int, String>((ref, profileId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return await repository.getFollowerCount(profileId);
});

final followingCountProvider = FutureProvider.family<int, String>((ref, profileId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return await repository.getFollowingCount(profileId);
});

final followingFeedProvider = StateNotifierProvider<FollowingFeedNotifier, AsyncValue<List<dynamic>>>((ref) {
  final repository = ref.watch(socialRepositoryProvider);
  return FollowingFeedNotifier(repository);
});

class FollowingFeedNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final SocialRepository _repository;

  FollowingFeedNotifier(this._repository) : super(const AsyncValue.loading()) {
    getFeed();
  }

  Future<void> getFeed() async {
    try {
      state = const AsyncValue.loading();
      final posts = await _repository.getFollowingFeed();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => getFeed();
}
