class LeaderboardModel {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int points;
  final int rank;

  LeaderboardModel({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.points,
    required this.rank,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      points: json['points'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}
