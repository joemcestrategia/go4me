import 'package:go4me/core/models/user_profile.dart';

class SocialPost {
  final String id;
  final String profileId;
  final String content;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final UserProfile? author; // Populated by joins
  final int likeCount;
  final bool isLiked;
  final int commentCount;

  SocialPost({
    required this.id,
    required this.profileId,
    required this.content,
    required this.mediaUrls,
    required this.createdAt,
    this.author,
    this.likeCount = 0,
    this.isLiked = false,
    this.commentCount = 0,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays < 7) return 'Há ${diff.inDays}d';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  factory SocialPost.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    final profileMap = map['profiles'] as Map<String, dynamic>?;
    
    // Contagem de likes e comentários via metadados de join ou RPC
    final likes = map['likes'] as List? ?? [];
    final comments = map['comments'] as List? ?? [];
    
    return SocialPost(
      id: map['id'],
      profileId: map['profile_id'],
      content: map['content'] ?? '',
      mediaUrls: List<String>.from(map['media_urls'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
      author: profileMap != null ? UserProfile.fromMap(profileMap) : null,
      likeCount: map['like_count'] ?? likes.length,
      commentCount: map['comment_count'] ?? comments.length,
      isLiked: map['is_liked'] ?? (currentUserId != null && likes.any((l) => l['profile_id'] == currentUserId)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'content': content,
      'media_urls': mediaUrls,
    };
  }
}

class SocialComment {
  final String id;
  final String profileId;
  final String postId;
  final String content;
  final DateTime createdAt;
  final UserProfile? author;

  SocialComment({
    required this.id,
    required this.profileId,
    required this.postId,
    required this.content,
    required this.createdAt,
    this.author,
  });

  factory SocialComment.fromMap(Map<String, dynamic> map) {
    final profileMap = map['profiles'] as Map<String, dynamic>?;
    return SocialComment(
      id: map['id'],
      profileId: map['profile_id'],
      postId: map['post_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      author: profileMap != null ? UserProfile.fromMap(profileMap) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'post_id': postId,
      'content': content,
    };
  }
}
