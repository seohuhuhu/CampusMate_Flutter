import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/meal_post.dart';
import 'model/user_preference.dart';
import 'add_meal_post_screen.dart';

// 탭마다 고유한 in-memory 세션 ID
final String _mySessionId =
    'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

// 신뢰도 점수 SharedPreferences 키
const String _trustScoresKey = 'trust_scores';

class MealBuddyListScreen extends StatefulWidget {
  const MealBuddyListScreen({Key? key}) : super(key: key);

  @override
  State<MealBuddyListScreen> createState() => _MealBuddyListScreenState();
}

class _MealBuddyListScreenState extends State<MealBuddyListScreen> {
  static const String _storageKey = 'meal_posts';
  static const String _prefKey = 'my_meal_preference';
  static const Color _teal = Color(0xFF54D3C2);

  List<MealPost> _posts = [];
  bool _isLoading = true;

  // AI 매칭 관련
  UserPreference? _myPref;   // null = 취향 미설정
  bool _sortByAI = false;    // false = 최신순, true = AI 추천순

  // 매너 온도 (신뢰도 점수)
  int _myTrustScore = 70;    // 기본 70점에서 시작

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadPosts(), _loadPreference(), _loadTrustScore()]);
  }

  // ─── 샘플 게시글 (첫 실행 시 기본 데이터) ─────────────
  static List<MealPost> _samplePosts() {
    final now = DateTime.now();
    return [
      MealPost(
        id: 'sample_001',
        authorId: 'sample_user_1',
        nickname: '배고픈 새내기',
        location: '학생식당',
        time: '12:00',
        maxPeople: 3,
        currentPeople: 1,
        menu: '한식',
        memo: '조용히 먹을 분 환영해요 😊',
        createdAt: now.subtract(const Duration(minutes: 5)),
        authorTrustScore: 72,
      ),
      MealPost(
        id: 'sample_002',
        authorId: 'sample_user_2',
        nickname: '점심러버',
        location: '제2학생회관',
        time: '12:30',
        maxPeople: 2,
        currentPeople: 1,
        menu: '분식',
        memo: '빠르게 먹고 도서관 갈 분!',
        createdAt: now.subtract(const Duration(minutes: 12)),
        authorTrustScore: 88,
      ),
      MealPost(
        id: 'sample_003',
        authorId: 'sample_user_3',
        nickname: '스타벅스러',
        location: '스타벅스',
        time: '13:00',
        maxPeople: 2,
        currentPeople: 1,
        menu: '양식',
        memo: '카페에서 간단히 브런치 🥐',
        createdAt: now.subtract(const Duration(minutes: 20)),
        authorTrustScore: 65,
      ),
      MealPost(
        id: 'sample_004',
        authorId: 'sample_user_4',
        nickname: '라멘킹',
        location: '교직원식당',
        time: '11:30',
        maxPeople: 4,
        currentPeople: 2,
        menu: '일식',
        memo: '11시 반에 일찍 먹고 공강 즐겨요',
        createdAt: now.subtract(const Duration(minutes: 35)),
        authorTrustScore: 95,
      ),
      MealPost(
        id: 'sample_005',
        authorId: 'sample_user_5',
        nickname: '마라탕순이',
        location: '편의점',
        time: '13:30',
        maxPeople: 2,
        currentPeople: 1,
        menu: '중식',
        memo: '편의점 중화 도시락 같이 먹어요 🍜',
        createdAt: now.subtract(const Duration(minutes: 48)),
        authorTrustScore: 58,
      ),
      MealPost(
        id: 'sample_006',
        authorId: 'sample_user_6',
        nickname: '아무거나 ok',
        location: '학생식당',
        time: '12:00',
        maxPeople: 5,
        currentPeople: 2,
        menu: '아무거나',
        memo: '메뉴 상관없어요! 같이 먹을 분~',
        createdAt: now.subtract(const Duration(hours: 1)),
        authorTrustScore: 81,
      ),
      MealPost(
        id: 'sample_007',
        authorId: 'sample_user_7',
        nickname: '헬시라이프',
        location: '교직원식당',
        time: '12:00',
        maxPeople: 3,
        currentPeople: 1,
        menu: '한식',
        memo: '건강한 한 끼 같이해요 🥗',
        createdAt: now.subtract(const Duration(hours: 2)),
        authorTrustScore: 77,
      ),
    ];
  }

  // ─── 게시글 로드 ────────────────────────────────────────
  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    List<MealPost> posts;
    if (jsonList.isEmpty) {
      // 첫 실행: 샘플 데이터로 초기화
      posts = _samplePosts();
      await prefs.setStringList(
        _storageKey,
        posts.map((p) => jsonEncode(p.toMap())).toList(),
      );
    } else {
      posts = jsonList.map((json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return MealPost.fromMap(map);
      }).toList();
    }

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _posts.map((p) => jsonEncode(p.toMap())).toList(),
    );
  }

  // ─── 취향 로드 / 저장 ───────────────────────────────────
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      setState(() => _myPref = UserPreference.fromJson(raw));
    }
  }

  Future<void> _savePreference(UserPreference pref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, pref.toJson());
    setState(() => _myPref = pref);
  }

  // ─── 매너 온도 (신뢰도) 로드 / 저장 ───────────────────────
  Future<void> _loadTrustScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getString(_trustScoresKey);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final score = map[_mySessionId];
      if (score != null) {
        setState(() => _myTrustScore = (score as int).clamp(0, 100));
      }
    }
  }

  /// trust_scores 맵에서 특정 세션의 점수를 증감
  Future<void> _updateTrustScore(String sessionId, int delta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getString(_trustScoresKey);
    final map = raw != null
        ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
        : <String, dynamic>{};

    final current = (map[sessionId] as int?) ?? 70;
    map[sessionId] = (current + delta).clamp(0, 100);
    await prefs.setString(_trustScoresKey, jsonEncode(map));

    // 내 점수면 UI 업데이트
    if (sessionId == _mySessionId) {
      setState(() => _myTrustScore = map[sessionId] as int);
    }
  }

  /// 매너 온도에 따른 라벨
  String _trustLabel(int score) {
    if (score >= 90) return '최우수 😎';
    if (score >= 80) return '우수 😊';
    if (score >= 70) return '보통 🙂';
    if (score >= 55) return '주의 😐';
    return '낮음 😶';
  }

  /// 매너 온도에 따른 색상
  Color _trustColor(int score) {
    if (score >= 90) return const Color(0xFF2ECC71);
    if (score >= 80) return const Color(0xFF54D3C2);
    if (score >= 70) return Colors.blue[400]!;
    if (score >= 55) return Colors.orange[600]!;
    return Colors.red[400]!;
  }

  // ─── AI 궁합 점수 계산 ──────────────────────────────────
  /// 메뉴(40점) + 장소(35점) + 시간(25점) 기반 매칭 점수
  /// 게시글 ID 기반 고정 변동값(±8)으로 자연스러운 분포 형성
  int _calcCompatibility(MealPost post) {
    if (_myPref == null) return 0;
    final pref = _myPref!;
    int score = 0;

    // 메뉴 궁합 (40점)
    if (post.menu == '아무거나' || pref.menu == '아무거나') {
      score += 35;
    } else if (post.menu == pref.menu) {
      score += 40;
    } else if (_isSimilarMenu(pref.menu, post.menu)) {
      score += 20;
    }

    // 장소 궁합 (35점)
    if (post.location == pref.location) {
      score += 35;
    } else if (post.location.contains(pref.location) ||
        pref.location.contains(post.location)) {
      score += 18;
    } else if (post.location == '기타' || pref.location == '기타') {
      score += 10;
    }

    // 시간 궁합 (25점)
    final diff = (_toMinutes(post.time) - _toMinutes(pref.freeTime)).abs();
    if (diff == 0)       score += 25;
    else if (diff <= 15) score += 22;
    else if (diff <= 30) score += 18;
    else if (diff <= 60) score += 10;
    else if (diff <= 90) score += 4;

    // ID 기반 고정 변동값 (±8) — 매번 달라지지 않도록 포스트 ID 시드 사용
    final seed = post.id.length >= 4
        ? int.tryParse(post.id.substring(post.id.length - 4)) ?? 0
        : 0;
    score += (seed % 17) - 8;

    // 매너 온도 보너스 (±5) — 신뢰도 높은 사용자의 글 우선 노출
    // 70점 기준: 90+ → +5, 80+ → +3, 70+ → 0, 55+ → -2, 미만 → -5
    final trust = post.authorTrustScore;
    if (trust >= 90)      score += 5;
    else if (trust >= 80) score += 3;
    else if (trust < 55)  score -= 5;
    else if (trust < 70)  score -= 2;

    return score.clamp(0, 100);
  }

  bool _isSimilarMenu(String a, String b) {
    // 비슷한 카테고리 묶음
    final groups = [
      {'한식', '분식'},
      {'일식', '중식'},
      {'양식'},
    ];
    return groups.any((g) => g.contains(a) && g.contains(b));
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return (int.tryParse(parts[0]) ?? 12) * 60 +
        (int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  // 표시할 게시글 목록 (정렬 적용)
  List<MealPost> get _displayPosts {
    if (_sortByAI && _myPref != null) {
      final sorted = List<MealPost>.from(_posts);
      sorted.sort(
          (a, b) => _calcCompatibility(b).compareTo(_calcCompatibility(a)));
      return sorted;
    }
    return _posts;
  }

  // 궁합 점수에 따른 색상
  Color _compatColor(int score) {
    if (score >= 85) return Colors.green[600]!;
    if (score >= 70) return _teal;
    if (score >= 50) return Colors.orange[600]!;
    return Colors.grey[500]!;
  }

  // ─── 게시글 추가 / 참가 / 삭제 ─────────────────────────
  Future<void> _addPost() async {
    final result = await Navigator.push<MealPost>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMealPostScreen(
        sessionId: _mySessionId,
        authorTrustScore: _myTrustScore,
      ),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() => _posts.insert(0, result));
      await _savePosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('밥친구 모집 글이 등록되었습니다! 🎉'),
            backgroundColor: _teal,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _joinPost(int indexInPosts) async {
    final post = _posts[indexInPosts];
    if (post.authorId == _mySessionId) {
      _snack('내가 올린 글에는 참가할 수 없어요!', Colors.orange);
      return;
    }
    if (post.isFull) {
      _snack('이미 마감된 모집입니다.', Colors.red);
      return;
    }
    setState(() => _posts[indexInPosts].currentPeople++);
    await _savePosts();

    // 매너 온도: 참가자 +2점, 글 작성자 +3점
    await _updateTrustScore(_mySessionId, 2);
    await _updateTrustScore(post.authorId, 3);

    if (mounted) {
      _snack(
        '${post.location} 밥친구 모임에 참가했어요! 🎉  매너 온도 +2°',
        _teal,
      );
    }
  }

  Future<void> _deletePost(int indexInPosts) async {
    final post = _posts[indexInPosts];
    if (post.authorId != _mySessionId) {
      _snack('내가 올린 글만 삭제할 수 있어요.', Colors.red);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('삭제 확인'),
        content: const Text('이 모집 글을 삭제할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _posts.removeAt(indexInPosts));
      await _savePosts();
    }
  }

  // ─── 다른 유저 매너 온도 팝업 ───────────────────────────
  void _showTrustDetailDialog(int score, String nickname) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.local_fire_department,
                color: _trustColor(score), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$nickname 님의 매너 온도',
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score°',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: _trustColor(score),
              ),
            ),
            Text(
              _trustLabel(score),
              style: TextStyle(fontSize: 16, color: _trustColor(score)),
            ),
            const SizedBox(height: 12),
            Text(
              score >= 80
                  ? '믿을 수 있는 밥친구예요 😊'
                  : score >= 70
                      ? '평범한 매너의 유저예요 🙂'
                      : '이전에 노쇼 이력이 있을 수 있어요 😐',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // ─── 내 매너 온도 안내 다이얼로그 ──────────────────────────
  void _showTrustInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.local_fire_department,
                color: _trustColor(_myTrustScore), size: 22),
            const SizedBox(width: 8),
            const Text('내 매너 온도', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '$_myTrustScore°',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _trustColor(_myTrustScore),
                ),
              ),
            ),
            Center(
              child: Text(
                _trustLabel(_myTrustScore),
                style: TextStyle(
                  fontSize: 16,
                  color: _trustColor(_myTrustScore),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('점수를 올리려면:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            _trustTip(Icons.group_add, '밥친구에 참가하기', '+2°'),
            _trustTip(Icons.people, '내 글에 누군가 참가', '+3°'),
            _trustTip(Icons.cancel_outlined, '스터디룸 제때 취소', '+1°'),
            const SizedBox(height: 8),
            Text(
              '⚠ AI 매칭 시 신뢰도가 높은 유저의 글이 상단 노출됩니다.',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _trustTip(IconData icon, String label, String bonus) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _teal),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(bonus,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _trustColor(_myTrustScore))),
        ],
      ),
    );
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  // ─── 취향 설정 Bottom Sheet ─────────────────────────────
  void _showPreferenceSheet() {
    final menus = ['한식', '중식', '일식', '양식', '분식', '아무거나'];
    final locations = ['학생식당', '제2학생회관', '교직원식당', '스타벅스', '편의점', '기타'];

    String selMenu = _myPref?.menu ?? '아무거나';
    String selLoc = _myPref?.location ?? '학생식당';
    String selTime = _myPref?.freeTime ?? '12:00';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                // 제목
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: _teal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.psychology, color: _teal, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('나의 식사 취향 설정',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Text('AI가 최적의 밥친구를 찾아드려요',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 선호 메뉴
                _sheetLabel('🍽️ 선호 메뉴'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: menus.map((m) => ChoiceChip(
                    label: Text(m),
                    selected: selMenu == m,
                    onSelected: (_) => setSheet(() => selMenu = m),
                    selectedColor: _teal.withOpacity(0.2),
                    checkmarkColor: _teal,
                  )).toList(),
                ),
                const SizedBox(height: 16),

                // 선호 장소
                _sheetLabel('📍 선호 장소'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: locations.map((l) => ChoiceChip(
                    label: Text(l),
                    selected: selLoc == l,
                    onSelected: (_) => setSheet(() => selLoc = l),
                    selectedColor: _teal.withOpacity(0.2),
                    checkmarkColor: _teal,
                  )).toList(),
                ),
                const SizedBox(height: 16),

                // 공강 시간
                _sheetLabel('⏰ 공강 시간'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final parts = selTime.split(':');
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay(
                        hour: int.tryParse(parts[0]) ?? 12,
                        minute: int.tryParse(parts[1]) ?? 0,
                      ),
                    );
                    if (picked != null) {
                      setSheet(() {
                        selTime =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selTime,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const Icon(Icons.edit, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final pref = UserPreference(
                          menu: selMenu,
                          location: selLoc,
                          freeTime: selTime);
                      await _savePreference(pref);
                      if (mounted) Navigator.pop(ctx);
                      if (mounted) {
                        _snack('취향이 저장되었어요! AI 추천을 시작합니다 🤖', _teal);
                        setState(() => _sortByAI = true);
                      }
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('취향 저장하고 AI 추천받기',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetLabel(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));

  // ─── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final display = _displayPosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: const Row(
          children: [
            Icon(Icons.restaurant, color: _teal, size: 24),
            SizedBox(width: 8),
            Text('밥친구 찾기',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
        actions: [
          // 새로고침
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
            tooltip: '새로고침',
          ),
          // AI 취향 설정
          IconButton(
            icon: Icon(
              Icons.psychology,
              color: _myPref != null ? _teal : Colors.grey[600],
            ),
            onPressed: _showPreferenceSheet,
            tooltip: 'AI 취향 설정',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Container(
            color: const Color(0xFFF0FAFA),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 13, color: _teal),
                const SizedBox(width: 6),
                Text(
                  '새 탭 = 새 유저 | 탭마다 다른 사람으로 테스트 가능',
                  style: TextStyle(fontSize: 11, color: Colors.teal[700]),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // ── AI / 최신순 정렬 토글 ─────────────────────────
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // 취향 미설정 안내
                if (_myPref == null)
                  Expanded(
                    child: GestureDetector(
                      onTap: _showPreferenceSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _teal.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.psychology,
                                color: _teal, size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '취향을 설정하면 AI가 궁합 점수를 계산해드려요 👆',
                                style: TextStyle(
                                    fontSize: 12, color: _teal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  // 정렬 칩
                  _sortChip('최신순', !_sortByAI, () {
                    setState(() => _sortByAI = false);
                  }),
                  const SizedBox(width: 8),
                  _sortChip('🤖 AI 추천순', _sortByAI, () {
                    setState(() => _sortByAI = true);
                  }),
                  const Spacer(),
                  // 내 매너 온도
                  GestureDetector(
                    onTap: () => _showTrustInfoDialog(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _trustColor(_myTrustScore).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _trustColor(_myTrustScore).withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department,
                              size: 13, color: _trustColor(_myTrustScore)),
                          const SizedBox(width: 3),
                          Text(
                            '$_myTrustScore° ${_trustLabel(_myTrustScore)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _trustColor(_myTrustScore),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          // ── 게시글 목록 ───────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _teal))
                : display.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: _teal,
                        onRefresh: _loadPosts,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 80),
                          itemCount: display.length,
                          itemBuilder: (_, i) {
                            // display 리스트의 포스트를 _posts에서 찾아 인덱스 확인
                            final post = display[i];
                            final postsIdx = _posts.indexOf(post);
                            return _buildPostCard(post, postsIdx);
                          },
                        ),
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPost,
        backgroundColor: _teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('밥친구 모집하기',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ),
    );
  }

  Widget _sortChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _teal : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('아직 모집 중인 밥친구가 없어요',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('먼저 모집 글을 올려보세요!',
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addPost,
            icon: const Icon(Icons.add),
            label: const Text('밥친구 모집하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(MealPost post, int postsIdx) {
    final isMyPost = post.authorId == _mySessionId;
    final isFull = post.isFull;
    final compat = _myPref != null ? _calcCompatibility(post) : null;

    return Dismissible(
      key: Key(post.id),
      direction: isMyPost
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        await _deletePost(postsIdx);
        return false;
      },
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isMyPost
              ? Border.all(
                  color: _teal.withOpacity(0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 닉네임 + 시간 + 상태 뱃지
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isMyPost
                        ? _teal.withOpacity(0.2)
                        : Colors.grey[100],
                    child: Text(
                      post.nickname.isNotEmpty
                          ? post.nickname[0]
                          : '?',
                      style: TextStyle(
                          color: isMyPost ? _teal : Colors.grey[600],
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(post.nickname,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const SizedBox(width: 6),
                            // 매너 온도 배지 (탭 시 상세 팝업)
                            GestureDetector(
                              onTap: () => isMyPost
                                  ? _showTrustInfoDialog()
                                  : _showTrustDetailDialog(post.authorTrustScore, post.nickname),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _trustColor(post.authorTrustScore)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _trustColor(post.authorTrustScore)
                                        .withOpacity(0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_fire_department,
                                        size: 11,
                                        color: _trustColor(post.authorTrustScore)),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${post.authorTrustScore}°',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _trustColor(post.authorTrustScore),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isMyPost) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _teal.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Text('내 글',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _teal,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        Text(_timeAgo(post.createdAt),
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  // AI 궁합 점수 배지
                  if (compat != null && !isMyPost) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _compatColor(compat).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _compatColor(compat).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.psychology,
                              size: 12,
                              color: _compatColor(compat)),
                          const SizedBox(width: 3),
                          Text(
                            '$compat%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _compatColor(compat),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // 모집 상태 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull
                          ? Colors.red[50]
                          : _teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFull ? '마감' : '모집중',
                      style: TextStyle(
                        color: isFull ? Colors.red[400] : _teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // 정보 그리드
              Row(
                children: [
                  Expanded(
                      child: _infoTile(Icons.location_on_outlined,
                          '장소', post.location)),
                  Expanded(
                      child: _infoTile(
                          Icons.access_time, '시간', post.time)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _infoTile(
                          Icons.restaurant_menu_outlined, '메뉴', post.menu)),
                  Expanded(
                      child: _infoTile(Icons.people_outline, '인원',
                          '${post.currentPeople}/${post.maxPeople}명')),
                ],
              ),

              if (post.memo.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text('💬 ${post.memo}',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[700])),
                ),
              ],
              const SizedBox(height: 12),

              // 참가 / 삭제 버튼
              if (isMyPost)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _deletePost(postsIdx),
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.red),
                    label: const Text('모집 글 삭제',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isFull ? null : () => _joinPost(postsIdx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFull ? Colors.grey[300] : _teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: isFull ? 0 : 2,
                    ),
                    child: Text(
                      isFull
                          ? '마감되었습니다'
                          : '참가하기 (${post.remainingSpots}자리 남음)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isFull
                            ? Colors.grey[500]
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _teal),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
