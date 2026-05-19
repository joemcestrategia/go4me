import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/donor/data/feed_provider.dart';
import 'package:go4me/core/models/social_models.dart';
import 'package:go4me/features/social/create_post_page.dart';
import 'package:go4me/features/social/missionary_social_profile.dart';
import 'package:go4me/features/social/comments_sheet.dart';

class MissionaryFeedTab extends ConsumerWidget {
  const MissionaryFeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Feed",
          style: GoogleFonts.inter(
            color: AppTheme.textPrimaryClaro,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePostPage()),
          );
        },
        backgroundColor: AppTheme.textPrimaryClaro,
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: AppTheme.accentYellow,
            size: 26),
      ),
      body: feedAsync.when(
        data: (posts) => posts.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                color: AppTheme.accentYellow,
                onRefresh: () => ref.read(feedProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return _SocialPostCard(post: posts[index]);
                  },
                ),
              ),
        loading: () => Center(
          child: CircularProgressIndicator(
              color: AppTheme.accentYellow, strokeWidth: 2.5),
        ),
        error: (err, stack) => Center(
          child: Text("Erro ao carregar feed: $err",
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondaryClaro)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.accentYellowLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.photo_camera_outlined,
                size: 34, color: AppTheme.accentYellowDark),
          ),
          const SizedBox(height: 20),
          Text(
            "Nenhuma postagem ainda",
            style: GoogleFonts.inter(
              color: AppTheme.textPrimaryClaro,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Seja o primeiro a compartilhar\numa atualização do campo!",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: AppTheme.textSecondaryClaro, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SocialPostCard extends ConsumerStatefulWidget {
  final SocialPost post;
  const _SocialPostCard({required this.post});

  @override
  ConsumerState<_SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends ConsumerState<_SocialPostCard> {
  int _currentImageIndex = 0;
  bool _showHeart = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(post),
          if (post.mediaUrls.isNotEmpty) _buildImageCarousel(post),
          _buildActionBar(post),

          if (post.likeCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                post.likeCount == 1
                    ? '1 curtida'
                    : '${post.likeCount} curtidas',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.textPrimaryClaro,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondaryClaro,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '${post.author?.fullName ?? 'Missionário'} ',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimaryClaro,
                    ),
                  ),
                  TextSpan(text: post.content),
                ],
              ),
            ),
          ),

          if (post.commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GestureDetector(
                onTap: () => _showComments(post),
                child: Text(
                  post.commentCount == 1
                      ? 'Ver 1 comentário'
                      : 'Ver todos os ${post.commentCount} comentários',
                  style: GoogleFonts.inter(
                    color: AppTheme.textTertiaryClaro,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: Text(
              post.timeAgo,
              style: GoogleFonts.inter(
                  color: AppTheme.textTertiaryClaro, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SocialPost post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _openProfile(post),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: post.author?.avatarUrl != null
                  ? NetworkImage(post.author!.avatarUrl!)
                  : null,
              backgroundColor: AppTheme.accentYellowLight,
              child: post.author?.avatarUrl == null
                  ? const Icon(Icons.person_rounded,
                      color: AppTheme.accentYellowDark)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _openProfile(post),
              child: Text(
                post.author?.fullName ?? 'Missionário',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimaryClaro,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded, size: 22),
            color: AppTheme.textTertiaryClaro,
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(SocialPost post) {
    return GestureDetector(
      onDoubleTap: () {
        ref.read(feedProvider.notifier).toggleLike(post.id);
        setState(() => _showHeart = true);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _showHeart = false);
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 350,
            child: PageView.builder(
              itemCount: post.mediaUrls.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (context, index) {
                return Image.network(
                  post.mediaUrls[index],
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          if (post.mediaUrls.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${post.mediaUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          if (_showHeart)
            const Icon(Icons.favorite, color: Colors.white, size: 80),
        ],
      ),
    );
  }

  Widget _buildActionBar(SocialPost post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                ref.read(feedProvider.notifier).toggleLike(post.id),
            icon: Icon(
              post.isLiked ? Icons.favorite_rounded : Icons.favorite_border,
              color: post.isLiked ? Colors.red : AppTheme.textTertiaryClaro,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () => _showComments(post),
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppTheme.textTertiaryClaro, size: 22),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined,
                color: AppTheme.textTertiaryClaro, size: 22),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border_rounded,
                color: AppTheme.textTertiaryClaro, size: 22),
          ),
        ],
      ),
    );
  }

  void _openProfile(SocialPost post) {
    if (post.author == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MissionarySocialProfile(
          missionaryId: post.profileId,
          profileId: post.profileId,
          missionaryName: post.author!.fullName ?? 'Missionário',
          avatarUrl: post.author!.avatarUrl ?? '',
        ),
      ),
    );
  }

  void _showComments(SocialPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(postId: post.id),
    );
  }
}
