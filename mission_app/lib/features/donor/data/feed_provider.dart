import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/core/models/social_models.dart';
import 'package:go4me/core/services/social_repository.dart';

// --- Notifier Reativo para o Feed ---

class FeedNotifier extends StateNotifier<AsyncValue<List<SocialPost>>> {
  final SocialRepository _repository;

  FeedNotifier(this._repository) : super(const AsyncValue.loading()) {
    getFeed();
  }

  /// Busca as postagens do banco de dados real
  Future<void> getFeed() async {
    try {
      state = const AsyncValue.loading();
      final posts = await _repository.getFeed();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Alterna a curtida (Like) de forma persistente
  Future<void> toggleLike(String postId) async {
    final currentPosts = state.value ?? [];
    
    // Atualização otimista na UI
    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          SocialPost(
            id: post.id,
            profileId: post.profileId,
            content: post.content,
            mediaUrls: post.mediaUrls,
            createdAt: post.createdAt,
            author: post.author,
            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
            isLiked: !post.isLiked,
            commentCount: post.commentCount,
          )
        else
          post,
    ]);

    try {
      await _repository.toggleLike(postId);
    } catch (e) {
      // Reverte em caso de erro no backend
      getFeed();
    }
  }

  /// Adiciona uma postagem à lista local após sucesso no backend
  void addPostLocally(SocialPost post) {
    if (state.hasValue) {
      state = AsyncValue.data([post, ...state.value!]);
    }
  }

  /// Recarrega o feed (Pull to Refresh)
  Future<void> refresh() => getFeed();
}

// --- Providers ---

final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<SocialPost>>>((ref) {
  final repository = ref.watch(socialRepositoryProvider);
  return FeedNotifier(repository);
});

final commentsProvider = FutureProvider.family<List<SocialComment>, String>((ref, postId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getComments(postId);
});
