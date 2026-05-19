import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go4me/core/providers/follow_provider.dart';
import 'package:go4me/core/services/social_repository.dart';

class MissionaryHero extends ConsumerWidget {
  final MissionaryData missionary;
  final bool isDesktop;

  const MissionaryHero({
    super.key,
    required this.missionary,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double heroHeight = isDesktop ? 500 : 400;

    return Container(
      height: heroHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        image: DecorationImage(
          image: NetworkImage(missionary.coverImageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: _FollowButton(missionary: missionary),
          ),
          Positioned(
            bottom: isDesktop ? 60 : 40,
            left: isDesktop ? 40 : 20,
            right: isDesktop ? 40 : 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: isDesktop ? 60 : 40,
                      backgroundColor: AppTheme.accentYellow,
                      child: CircleAvatar(
                        radius: isDesktop ? 56 : 38,
                        backgroundImage: NetworkImage(missionary.profileImageUrl),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            missionary.name.toUpperCase(),
                            style: GoogleFonts.lora(
                              color: Colors.white,
                              fontSize: isDesktop ? 42 : 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(FontAwesomeIcons.locationDot, color: AppTheme.accentYellow, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                missionary.location,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: isDesktop ? 20 : 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  missionary.headline,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends ConsumerWidget {
  final MissionaryData missionary;
  const _FollowButton({required this.missionary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync = ref.watch(isFollowingProvider(missionary.id));

    return isFollowingAsync.when(
      data: (isFollowing) => GestureDetector(
        onTap: () async {
          ref.invalidate(isFollowingProvider(missionary.id));
          await ref.read(socialRepositoryProvider).toggleFollow(missionary.id);
          ref.invalidate(isFollowingProvider(missionary.id));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white.withValues(alpha: 0.2) : AppTheme.accentYellow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isFollowing ? Colors.white.withValues(alpha: 0.5) : Colors.transparent, width: 1.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isFollowing ? Icons.check : Icons.add, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(isFollowing ? 'Seguindo' : 'Seguir',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: isFollowing ? Colors.white : AppTheme.textPrimaryClaro)),
          ]),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
