class PrayerRequest {
  final String id;
  final String profileId;
  final String content;
  final bool isPraise;
  final bool isAnswered;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatar;
  final int prayerCount;
  final bool hasPrayed;

  const PrayerRequest({
    required this.id,
    required this.profileId,
    required this.content,
    this.isPraise = false,
    this.isAnswered = false,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.prayerCount = 0,
    this.hasPrayed = false,
  });

  factory PrayerRequest.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    final participants = map['prayer_participants'] as List? ?? [];
    return PrayerRequest(
      id: map['id']?.toString() ?? '',
      profileId: map['profile_id']?.toString() ?? '',
      content: map['content'] ?? '',
      isPraise: map['is_praise'] ?? false,
      isAnswered: map['is_answered'] ?? false,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      authorName: map['profiles']?['full_name'],
      authorAvatar: map['profiles']?['avatar_url'],
      prayerCount: participants.length,
      hasPrayed: participants.any((p) => p['profile_id'] == currentUserId),
    );
  }
}
