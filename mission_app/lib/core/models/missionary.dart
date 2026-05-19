
class Donor {
  final String id;
  final String name;
  final String avatarUrl;
  final double amount;
  final String timeAgo;
  final bool isAnonymous;
  final double totalDonated;
  final int supportedMissionsCount;
  final int livesImpactedCount;

  const Donor({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.amount,
    required this.timeAgo,
    this.isAnonymous = false,
    this.totalDonated = 0.0,
    this.supportedMissionsCount = 0,
    this.livesImpactedCount = 0,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Anônimo',
      avatarUrl: json['avatar_url'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      timeAgo: json['time_ago'] ?? '',
      isAnonymous: json['is_anonymous'] ?? false,
      totalDonated: (json['total_donated'] ?? 0).toDouble(),
      supportedMissionsCount: json['supported_missions_count'] ?? 0,
      livesImpactedCount: json['lives_impacted_count'] ?? 0,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final double goal;
  final double current;
  final String imageUrl;

  double get progress => (current / goal).clamp(0.0, 1.0);
  int get progressPercentage => (progress * 100).toInt();

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.current,
    required this.imageUrl,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      goal: (json['goal'] ?? 0).toDouble(),
      current: (json['current'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class PastLocation {
  final String city;
  final String country;
  final String countryCode;
  final String period;
  final String description;

  const PastLocation({
    required this.city,
    required this.country,
    required this.countryCode,
    required this.period,
    required this.description,
  });

  factory PastLocation.fromJson(Map<String, dynamic> json) {
    return PastLocation(
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
      period: json['period'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class MissionaryData {
  final String id;
  final String name;
  final String slug;
  final String location;
  final double latitude;
  final double longitude;
  final String yearsInField;
  final String livesImpacted;
  final String headline;
  final String fullStory;
  final double currentSupport;
  final double goalSupport;
  final String profileImageUrl;
  final String coverImageUrl;
  final String nationality;
  final String nationalityCode;
  final String countryCode;
  final String category;
  final bool isPublic;

  final List<Donor> recentDonors;
  final List<Project> oneTimeProjects;
  final List<PastLocation> pastLocations;

  double get progress => (currentSupport / goalSupport).clamp(0.0, 1.0);
  int get progressPercentage => (progress * 100).toInt();
  bool get isFullyFunded => progress >= 1.0;

  const MissionaryData({
    required this.id,
    required this.name,
    required this.slug,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.yearsInField,
    required this.livesImpacted,
    required this.headline,
    required this.fullStory,
    required this.currentSupport,
    required this.goalSupport,
    required this.profileImageUrl,
    required this.coverImageUrl,
    this.nationality = '',
    this.nationalityCode = '',
    this.countryCode = '',
    this.category = 'church_planting',
    this.isPublic = true,
    this.recentDonors = const [],
    this.oneTimeProjects = const [],
    this.pastLocations = const [],
  });

  factory MissionaryData.fromJson(Map<String, dynamic> json) {
    return MissionaryData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      yearsInField: json['years_in_field'] ?? '',
      livesImpacted: json['lives_impacted'] ?? '',
      headline: json['headline'] ?? '',
      fullStory: json['full_story'] ?? '',
      currentSupport: (json['current_support'] ?? 0).toDouble(),
      goalSupport: (json['goal_support'] ?? 0).toDouble(),
      profileImageUrl: json['profile_image_url'] ?? '',
      coverImageUrl: json['cover_image_url'] ?? '',
      nationality: json['nationality'] ?? '',
      nationalityCode: json['nationality_code'] ?? '',
      countryCode: json['country_code'] ?? '',
      category: json['category'] ?? 'church_planting',
      isPublic: json['is_public'] ?? true,
      recentDonors: (json['recent_donors'] as List?)?.map((d) => Donor.fromJson(d)).toList() ?? [],
      oneTimeProjects: (json['one_time_projects'] as List?)?.map((p) => Project.fromJson(p)).toList() ?? [],
      pastLocations: (json['past_locations'] as List?)?.map((l) => PastLocation.fromJson(l)).toList() ?? [],
    );
  }
}
