import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/donor/data/feed_provider.dart';
import 'package:go4me/features/social/comments_sheet.dart';
import 'package:go4me/core/models/social_models.dart';
import 'package:go4me/core/providers/follow_provider.dart';
import 'package:go4me/core/services/social_repository.dart';

class MissionarySocialProfile extends ConsumerWidget {
  final String missionaryId;
  final String profileId;
  final String missionaryName;
  final String avatarUrl;
  final String location;

  const MissionarySocialProfile({
    super.key,
    required this.missionaryId,
    required this.profileId,
    required this.missionaryName,
    required this.avatarUrl,
    this.location = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    final followersAsync = ref.watch(followerCountProvider(profileId));
    final followingAsync = ref.watch(followingCountProvider(profileId));
    final isFollowingAsync = ref.watch(isFollowingProvider(profileId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(missionaryName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: feedAsync.when(
        data: (posts) {
          final myPosts = posts.where((p) => p.profileId == profileId).toList();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildProfileHeader(myPosts.length, followersAsync, followingAsync, isFollowingAsync, ref),
              ),
              if (myPosts.isEmpty)
                const SliverFillRemaining(child: Center(child: Text("Nenhuma postagem ainda")))
              else
                SliverPadding(
                  padding: const EdgeInsets.all(2),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildGridItem(context, ref, myPosts[index]),
                      childCount: myPosts.length,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erro: $err")),
      ),
    );
  }

  Widget _buildProfileHeader(int postCount, AsyncValue<int> followers, AsyncValue<int> following, AsyncValue<bool> isFollowing, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 20),
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildStat("$postCount", "posts"),
              followers.when(
                data: (c) => _buildStat("$c", "seguidores"),
                loading: () => _buildStat("-", "seguidores"),
                error: (_, __) => _buildStat("-", "seguidores"),
              ),
              following.when(
                data: (c) => _buildStat("$c", "seguindo"),
                loading: () => _buildStat("-", "seguindo"),
                error: (_, __) => _buildStat("-", "seguindo"),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(missionaryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const Text("🌍 Missionário Go4Me", style: TextStyle(fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: isFollowing.when(
            data: (following) => OutlinedButton(
              onPressed: () async {
                ref.invalidate(isFollowingProvider(profileId));
                await ref.read(socialRepositoryProvider).toggleFollow(profileId);
                ref.invalidate(isFollowingProvider(profileId));
                ref.invalidate(followerCountProvider(profileId));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: following ? Colors.black54 : Colors.white,
                backgroundColor: following ? Colors.grey[200] : AppTheme.accentYellow,
                side: BorderSide(color: following ? Colors.grey[300]! : AppTheme.accentYellow),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(following ? 'Seguindo' : 'Seguir',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ]),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    ]);
  }

  Widget _buildGridItem(BuildContext context, WidgetRef ref, SocialPost post) {
    return GestureDetector(
      onTap: () => _openPostDetail(context, ref, post),
      child: post.mediaUrls.isNotEmpty
          ? Image.network(post.mediaUrls.first, fit: BoxFit.cover)
          : Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(8),
              child: Center(child: Text(post.content, maxLines: 3, style: const TextStyle(fontSize: 10))),
            ),
    );
  }

  void _openPostDetail(BuildContext context, WidgetRef ref, SocialPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostDetailSheet(post: post),
    );
  }
}

class _PostDetailSheet extends ConsumerStatefulWidget {
  final SocialPost post;
  const _PostDetailSheet({required this.post});

  @override
  ConsumerState<_PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends ConsumerState<_PostDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final allPosts = ref.watch(feedProvider);
    final post = allPosts.maybeWhen(
      data: (posts) => posts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post),
      orElse: () => widget.post,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(children: [
          if (post.mediaUrls.isNotEmpty)
            Image.network(post.mediaUrls.first, height: 300, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 15, backgroundImage: NetworkImage(post.author?.avatarUrl ?? '')),
                const SizedBox(width: 10),
                Text(post.author?.fullName ?? 'Missionário', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              Text(post.content),
              const SizedBox(height: 12),
              Row(children: [
                IconButton(
                  onPressed: () => ref.read(feedProvider.notifier).toggleLike(post.id),
                  icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : null),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentsSheet(postId: post.id),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
