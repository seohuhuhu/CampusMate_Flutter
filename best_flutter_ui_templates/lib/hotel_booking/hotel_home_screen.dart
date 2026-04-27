import 'dart:convert';
import 'dart:math';
import 'package:best_flutter_ui_templates/hotel_booking/hotel_list_view.dart';
import 'package:best_flutter_ui_templates/hotel_booking/single_date_picker_view.dart';
import 'package:best_flutter_ui_templates/hotel_booking/model/hotel_list_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hotel_app_theme.dart';

// 탭마다 고유한 세션 ID (in-memory)
final String _mySessionId =
    'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

class HotelHomeScreen extends StatefulWidget {
  @override
  _HotelHomeScreenState createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen>
    with TickerProviderStateMixin {
  static const Color _teal = Color(0xFF54D3C2);

  AnimationController? animationController;
  List<HotelListData> hotelList = HotelListData.hotelList;
  List<HotelListData> filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  // 선택된 날짜 (단일)
  DateTime selectedDate = DateTime.now();
  int personCount = 1;

  // 이 세션에서 예약한 목록: roomId → dateStr ('yyyy-MM-dd')
  final Map<String, String> _myBookings = {};

  // 선택된 날짜의 방별 예약 수 (SharedPreferences에서 로드)
  Map<String, int> _bookingCounts = {};

  // SharedPreferences 키: 날짜별로 분리
  String get _dateKey =>
      'room_counts_${DateFormat("yyyy-MM-dd").format(selectedDate)}';

  String _toDateKey(DateTime date) =>
      'room_counts_${DateFormat("yyyy-MM-dd").format(date)}';

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    filteredList = List.from(hotelList);
    _loadBookingCounts();
  }

  @override
  void dispose() {
    animationController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 선택된 날짜의 예약 수 로드
  Future<void> _loadBookingCounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getString(_dateKey);
    setState(() {
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _bookingCounts = decoded.map((k, v) => MapEntry(k, v as int));
      } else {
        _bookingCounts = {};
      }
    });
  }

  // 날짜 변경 → 해당 날짜의 예약 수 로드
  Future<void> _changeDate(DateTime newDate) async {
    setState(() => selectedDate = newDate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getString(_toDateKey(newDate));
    setState(() {
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _bookingCounts = decoded.map((k, v) => MapEntry(k, v as int));
      } else {
        _bookingCounts = {};
      }
    });
  }

  // 특정 날짜의 예약 수를 SharedPreferences에서 가져옴
  Future<Map<String, int>> _fetchCountsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_toDateKey(date));
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as int));
  }

  // 특정 날짜의 예약 수를 SharedPreferences에 저장
  Future<void> _saveCountsForDate(
      DateTime date, Map<String, int> counts) async {
    final prefs = await SharedPreferences.getInstance();
    if (counts.isEmpty) {
      await prefs.remove(_toDateKey(date));
    } else {
      await prefs.setString(_toDateKey(date), jsonEncode(counts));
    }
  }

  // 실시간 잔여석
  int _remainingSeats(HotelListData room) {
    final booked = _bookingCounts[room.titleTxt] ?? 0;
    return (room.rating.toInt() - booked).clamp(0, room.rating.toInt());
  }

  // 현재 날짜에서 내가 예약했는지
  bool _isBookedOnSelected(String roomId) {
    final dateStr = DateFormat("yyyy-MM-dd").format(selectedDate);
    return _myBookings[roomId] == dateStr;
  }

  // 예약 / 취소 토글
  Future<void> _toggleBooking(HotelListData room) async {
    final roomId = room.titleTxt;
    final dateStr = DateFormat("yyyy-MM-dd").format(selectedDate);
    final bookedDateStr = _myBookings[roomId];
    final isBookedOnSelected = bookedDateStr == dateStr;

    // 다른 날짜에 이미 예약한 경우
    if (bookedDateStr != null && !isBookedOnSelected) {
      _showSnack(
          '이미 $bookedDateStr에 예약하셨습니다.\n먼저 해당 예약을 취소해주세요.', Colors.orange);
      return;
    }

    // 잔여석 없음 (내가 예약 안 한 경우)
    if (!isBookedOnSelected && _remainingSeats(room) <= 0) {
      _showSnack('잔여석이 없어 예약할 수 없습니다.', Colors.red);
      return;
    }

    // 현재 날짜의 예약 수 가져오기
    final counts = await _fetchCountsForDate(selectedDate);

    setState(() {
      if (isBookedOnSelected) {
        // 취소
        _myBookings.remove(roomId);
        counts[roomId] = (counts[roomId] ?? 1) - 1;
        if ((counts[roomId] ?? 0) <= 0) counts.remove(roomId);
      } else {
        // 예약
        _myBookings[roomId] = dateStr;
        counts[roomId] = (counts[roomId] ?? 0) + 1;
      }
      _bookingCounts = Map.from(counts);
    });

    await _saveCountsForDate(selectedDate, counts);
    _showSnack(
      isBookedOnSelected ? '예약이 취소되었습니다.' : '예약이 완료되었습니다!',
      isBookedOnSelected ? Colors.grey.shade600 : _teal,
    );
  }

  // 예약 취소 (roomId와 날짜를 명시적으로 지정 — 벨 패널에서 사용)
  Future<void> _cancelBooking(String roomId, String dateStr) async {
    final date = DateFormat("yyyy-MM-dd").parse(dateStr);
    final counts = await _fetchCountsForDate(date);

    counts[roomId] = (counts[roomId] ?? 1) - 1;
    if ((counts[roomId] ?? 0) <= 0) counts.remove(roomId);

    await _saveCountsForDate(date, counts);

    setState(() {
      _myBookings.remove(roomId);
      // 취소한 날짜가 현재 선택 날짜와 같으면 _bookingCounts도 갱신
      if (dateStr == DateFormat("yyyy-MM-dd").format(selectedDate)) {
        _bookingCounts = Map.from(counts);
      }
    });

    // 매너 온도 +1: 제때 취소한 유저 보상
    await _addCancelTrustBonus();

    _showSnack('예약이 취소되었습니다.  매너 온도 +1°', Colors.grey.shade600);
  }

  /// 스터디룸 예약 정상 취소 시 trust_scores에 +1 반영
  Future<void> _addCancelTrustBonus() async {
    const trustScoresKey = 'trust_scores';
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getString(trustScoresKey);
    final map = raw != null
        ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
        : <String, dynamic>{};
    final current = (map[_mySessionId] as int?) ?? 70;
    map[_mySessionId] = (current + 1).clamp(0, 100);
    await prefs.setString(trustScoresKey, jsonEncode(map));
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 날짜 피커 (단일 날짜)
  Future<void> _pickDate() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => SingleDatePickerView(
        initialDate: selectedDate,
        minimumDate: DateTime.now(),
        maximumDate: DateTime.now().add(const Duration(days: 90)),
        onDateSelected: (date) async {
          await _changeDate(date);
        },
      ),
    );
  }

  // 내 예약 목록 패널 (벨 아이콘)
  void _showMyBookings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (_, setSheet) {
            final bookingEntries = _myBookings.entries.toList();

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 핸들
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.notifications, color: _teal, size: 22),
                      const SizedBox(width: 8),
                      const Text('내 예약 목록',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('총 ${bookingEntries.length}건',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  bookingEntries.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.event_busy,
                                    size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text('예약 내역이 없습니다',
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                        )
                      : Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: bookingEntries.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final roomId = bookingEntries[i].key;
                              final dateStr = bookingEntries[i].value;
                              // 방 정보 찾기
                              final room = hotelList.firstWhere(
                                (r) => r.titleTxt == roomId,
                                orElse: () => hotelList.first,
                              );
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    // 방 이미지 썸네일
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        room.imagePath,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // 방 정보
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(roomId,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  size: 12,
                                                  color: Colors.grey[500]),
                                              const SizedBox(width: 4),
                                              Text(
                                                DateFormat('yyyy년 M월 d일').format(
                                                    DateFormat("yyyy-MM-dd")
                                                        .parse(dateStr)),
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 취소 버튼
                                    TextButton(
                                      onPressed: () async {
                                        await _cancelBooking(roomId, dateStr);
                                        setSheet(() {}); // 시트 내부 UI 갱신
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                      ),
                                      child: const Text('취소',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 검색어 + 인원수로 동시 필터링
  void _applyFilters({String? query}) {
    final q = query ?? _searchController.text;
    setState(() {
      filteredList = hotelList.where((r) {
        final matchesText = q.isEmpty ||
            r.titleTxt.contains(q) ||
            r.subTxt.contains(q);
        final matchesPeople = r.dist >= personCount; // 수용인원 >= 선택인원
        return matchesText && matchesPeople;
      }).toList();
    });
  }

  void _onSearch(String query) => _applyFilters(query: query);

  @override
  Widget build(BuildContext context) {
    final Color primary = HotelAppTheme.buildLightTheme().primaryColor;

    return Theme(
      data: HotelAppTheme.buildLightTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              // ── 앱바 ──────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.meeting_room, color: primary, size: 26),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '스터디룸 예약',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    // 새로고침
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.grey[600]),
                      tooltip: '새로고침',
                      onPressed: _loadBookingCounts,
                    ),
                    // 내 예약 목록 (벨)
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_none,
                              color: Colors.grey[600], size: 24),
                          tooltip: '내 예약 목록',
                          onPressed: _showMyBookings,
                        ),
                        if (_myBookings.isNotEmpty)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  '${_myBookings.length}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── 검색바 ────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: '건물명으로 검색...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // ── 날짜(단일)/인원 선택 ──────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 12, top: 4),
                child: Row(
                  children: [
                    // 날짜 (단일 날짜)
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 15, color: _teal),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('예약 날짜',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500])),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('EEE').format(selectedDate),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    DateFormat('MMM dd').format(selectedDate),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 인원
                    Expanded(
                      child: GestureDetector(
                        onTap: _showPersonPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.people_outline,
                                  size: 15, color: _teal),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('이용 인원',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500])),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$personCount명',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 결과 카운트 ───────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 8, top: 4),
                child: Row(
                  children: [
                    Text(
                      '스터디룸 ${filteredList.length}개',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const Spacer(),
                    Text(
                      '$personCount명 수용 가능',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── 스터디룸 목록 ─────────────────────────────────────
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('검색 결과가 없습니다',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredList.length,
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 16),
                        itemBuilder: (context, index) {
                          final count = filteredList.length > 10
                              ? 10
                              : filteredList.length;
                          final animation =
                              Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animationController!,
                              curve: Interval(
                                (1 / count) * index,
                                1.0,
                                curve: Curves.fastOutSlowIn,
                              ),
                            ),
                          );
                          animationController?.forward();
                          final room = filteredList[index];
                          return HotelListView(
                            callback: () {},
                            hotelData: room,
                            animation: animation,
                            animationController: animationController!,
                            isBooked: _isBookedOnSelected(room.titleTxt),
                            remainingSeats: _remainingSeats(room),
                            onToggleBooking: () => _toggleBooking(room),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        int temp = personCount;
        return StatefulBuilder(
          builder: (_, setModal) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('이용 인원 선택',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 32),
                      color: _teal,
                      onPressed:
                          temp > 1 ? () => setModal(() => temp--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('$temp명',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 32),
                      color: _teal,
                      onPressed: () => setModal(() => temp++),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() => personCount = temp);
                      _applyFilters();
                      Navigator.pop(ctx);
                    },
                    child: const Text('확인',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
