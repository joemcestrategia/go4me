import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go4me/core/models/social_models.dart';
import 'package:go4me/core/services/notification_service.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository(Supabase.instance.client, ref);
});

class SocialRepository {
  final SupabaseClient _supabase;
  final Ref _ref;
  RealtimeChannel? _postSubscription;

  SocialRepository(this._supabase, this._ref);

  /// Inicia a escuta de novas postagens para disparar notificações
  void subscribeToNewPosts() {
    _postSubscription = _supabase
        .channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) async {
            final notificationService = _ref.read(notificationServiceProvider);
            
            // Aqui poderíamos buscar o nome do missionário via payload['new']['profile_id']
            // Para simplificar o teste, notificamos o evento
            await notificationService.showNotification(
              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              title: "Nova Atualização!",
              body: "Um missionário acabou de postar uma novidade no campo.",
            );
          },
        )
        .subscribe();
  }

  void dispose() {
    _postSubscription?.unsubscribe();
  }

  /// Busca as postagens do feed, incluindo detalhes do autor e status de interação
  Future<List<SocialPost>> getFeed({int limit = 20, int offset = 0}) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          profiles(*),
          likes(profile_id),
          comments(count)
        ''')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final currentUserId = _supabase.auth.currentUser?.id;
    
    return (response as List).map((post) {
      // Pequeno ajuste para o formato do Supabase de contagem de comentários
      final Map<String, dynamic> mappedPost = Map.from(post);
      if (post['comments'] is List && post['comments'].isNotEmpty) {
        mappedPost['comment_count'] = post['comments'][0]['count'];
      }
      return SocialPost.fromMap(mappedPost, currentUserId: currentUserId);
    }).toList();
  }

  /// Alterna a curtida em um post
  Future<bool> toggleLike(String postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    // Verifica se já curtiu
    final existingLike = await _supabase
        .from('likes')
        .select()
        .eq('profile_id', userId)
        .eq('post_id', postId)
        .maybeSingle();

    if (existingLike != null) {
      // Remove curtida
      await _supabase
          .from('likes')
          .delete()
          .eq('profile_id', userId)
          .eq('post_id', postId);
      return false; // Agora não está curtido
    } else {
      // Adiciona curtida
      await _supabase
          .from('likes')
          .insert({'profile_id': userId, 'post_id': postId});
      return true; // Agora está curtido
    }
  }

  /// Adiciona um comentário
  Future<SocialComment> addComment(String postId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("Usuário não autenticado");

    final response = await _supabase
        .from('comments')
        .insert({
          'profile_id': userId,
          'post_id': postId,
          'content': content,
        })
        .select('*, profiles(*)')
        .single();

    return SocialComment.fromMap(response);
  }

  /// Busca os comentários de uma postagem específica
  Future<List<SocialComment>> getComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List).map((c) => SocialComment.fromMap(c)).toList();
  }

  /// Faz o upload de imagens para o bucket 'posts'
  Future<List<String>> uploadPostImages(List<dynamic> images) async {
    final List<String> urls = [];
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("Usuário não autenticado");

    for (final image in images) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = kIsWeb ? 'jpg' : image.path.split('.').last;
      final fileName = '${timestamp}_${DateTime.now().microsecondsSinceEpoch}.$ext';
      final path = '$userId/$fileName';

      final bytes = kIsWeb ? image : await image.readAsBytes();
      await _supabase.storage.from('posts').uploadBinary(path, bytes);
      final url = _supabase.storage.from('posts').getPublicUrl(path);
      urls.add(url);
    }
    return urls;
  }

  /// Cria uma nova postagem
  Future<SocialPost> createPost(String content, List<String> imageUrls) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("Usuário não autenticado");

    final response = await _supabase
        .from('posts')
        .insert({
          'profile_id': userId,
          'content': content,
          'media_urls': imageUrls,
        })
        .select('*, profiles(*)')
        .single();

    return SocialPost.fromMap(response);
  }

  /// SEGUIR / DEIXAR DE SEGUIR

  Future<bool> isFollowing(String profileId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('follows')
        .select()
        .eq('follower_id', userId)
        .eq('following_id', profileId)
        .maybeSingle();

    return response != null;
  }

  Future<bool> toggleFollow(String profileId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final existing = await _supabase
        .from('follows')
        .select()
        .eq('follower_id', userId)
        .eq('following_id', profileId)
        .maybeSingle();

    if (existing != null) {
      await _supabase
          .from('follows')
          .delete()
          .eq('follower_id', userId)
          .eq('following_id', profileId);
      return false;
    } else {
      await _supabase
          .from('follows')
          .insert({'follower_id': userId, 'following_id': profileId});
      return true;
    }
  }

  Future<int> getFollowerCount(String profileId) async {
    final response = await _supabase
        .from('follows')
        .select('*')
        .eq('following_id', profileId);

    return (response as List).length;
  }

  Future<int> getFollowingCount(String profileId) async {
    final response = await _supabase
        .from('follows')
        .select('*')
        .eq('follower_id', profileId);

    return (response as List).length;
  }

  /// FEED FILTRADO POR SEGUIDOS

  Future<List<SocialPost>> getFollowingFeed({int limit = 20, int offset = 0}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return await getFeed(limit: limit, offset: offset);

    final followingIds = await _supabase
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId);

    if (followingIds.isEmpty) return [];

    final profileIds = (followingIds as List).map((f) => f['following_id'] as String).toList();

    final response = await _supabase
        .from('posts')
        .select('''
          *,
          profiles(*),
          likes(profile_id),
          comments(count)
        ''')
        .inFilter('profile_id', profileIds)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final currentUserId = _supabase.auth.currentUser?.id;

    return (response as List).map((post) {
      final Map<String, dynamic> mappedPost = Map.from(post);
      if (post['comments'] is List && post['comments'].isNotEmpty) {
        mappedPost['comment_count'] = post['comments'][0]['count'];
      }
      return SocialPost.fromMap(mappedPost, currentUserId: currentUserId);
    }).toList();
  }
}
