import 'dart:convert';

// 밥친구 게시글 데이터 모델
class MealPost {
  final String id;
  final String authorId;       // 작성자 세션 ID (자기 글 참가 방지용)
  final String nickname;
  final String location;
  final String time;
  final int maxPeople;
  int currentPeople;
  final String menu;
  final String memo;
  final DateTime createdAt;
  final int authorTrustScore;  // 작성자의 매너 온도 (0~100, 기본 70)

  MealPost({
    required this.id,
    required this.authorId,
    required this.nickname,
    required this.location,
    required this.time,
    required this.maxPeople,
    this.currentPeople = 1,
    required this.menu,
    this.memo = '',
    required this.createdAt,
    this.authorTrustScore = 70,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'nickname': nickname,
      'location': location,
      'time': time,
      'maxPeople': maxPeople,
      'currentPeople': currentPeople,
      'menu': menu,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
      'authorTrustScore': authorTrustScore,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory MealPost.fromMap(Map<String, dynamic> map) {
    return MealPost(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      nickname: map['nickname'] ?? '',
      location: map['location'] ?? '',
      time: map['time'] ?? '',
      maxPeople: map['maxPeople'] ?? 2,
      currentPeople: map['currentPeople'] ?? 1,
      menu: map['menu'] ?? '',
      memo: map['memo'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      authorTrustScore: map['authorTrustScore'] ?? 70,
    );
  }

  factory MealPost.fromJson(String source) =>
      MealPost.fromMap(jsonDecode(source));

  bool get isFull => currentPeople >= maxPeople;
  int get remainingSpots => maxPeople - currentPeople;
}
