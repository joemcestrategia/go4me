import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/donor/data/feed_provider.dart';
import 'package:go4me/core/models/social_models.dart';

class ExclusiveFeed extends ConsumerWidget {
  const ExclusiveFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);

    return feedAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text("Nenhuma atualização exclusiva no momento."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostCard(post);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Erro ao carregar feed: $err")),
    );
  }

  Widget _buildPostCard(SocialPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.mediaUrls.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                post.mediaUrls.first,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey[200]),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(post.author?.avatarUrl ?? ''),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.author?.fullName ?? 'Missionário',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      post.timeAgo,
                      style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.content,
                  style: GoogleFonts.inter(color: AppTheme.textDark, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
