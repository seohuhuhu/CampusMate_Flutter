import 'dart:convert';

/// 사용자의 식사 취향 모델
/// SharedPreferences에 JSON으로 저장되어 앱 재시작 후에도 유지됩니다.
class UserPreference {
  final String menu;      // 선호 메뉴 (한식, 중식, 일식, 양식, 분식, 아무거나)
  final String location;  // 선호 장소 (학생식당, 제2학생회관, 교직원식당, 스타벅스, 편의점, 기타)
  final String freeTime;  // 공강 시간 HH:mm

  const UserPreference({
    this.menu = '아무거나',
    this.location = '학생식당',
    this.freeTime = '12:00',
  });

  Map<String, dynamic> toMap() => {
    'menu': menu,
    'location': location,
    'freeTime': freeTime,
  };

  String toJson() => jsonEncode(toMap());

  factory UserPreference.fromMap(Map<String, dynamic> map) => UserPreference(
    menu: map['menu'] ?? '아무거나',
    location: map['location'] ?? '학생식당',
    freeTime: map['freeTime'] ?? '12:00',
  );

  factory UserPreference.fromJson(String source) =>
      UserPreference.fromMap(jsonDecode(source));

  UserPreference copyWith({String? menu, String? location, String? freeTime}) =>
      UserPreference(
        menu: menu ?? this.menu,
        location: location ?? this.location,
        freeTime: freeTime ?? this.freeTime,
      );
}
