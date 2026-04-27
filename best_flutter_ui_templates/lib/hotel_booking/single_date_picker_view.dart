import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'hotel_app_theme.dart';

/// 단일 날짜 선택 팝업
/// 헤더: 요일(Mon) + 날짜(Apr 27) 두 줄 표시
class SingleDatePickerView extends StatefulWidget {
  const SingleDatePickerView({
    Key? key,
    required this.initialDate,
    required this.minimumDate,
    required this.maximumDate,
    required this.onDateSelected,
  }) : super(key: key);

  final DateTime initialDate;
  final DateTime minimumDate;
  final DateTime maximumDate;
  final Function(DateTime) onDateSelected;

  @override
  State<SingleDatePickerView> createState() => _SingleDatePickerViewState();
}

class _SingleDatePickerViewState extends State<SingleDatePickerView>
    with TickerProviderStateMixin {
  static const Color _teal = Color(0xFF54D3C2);

  late DateTime _selectedDate;
  late DateTime _currentMonthDate;
  List<DateTime> _dateList = [];

  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonthDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _animController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _buildDateList(_currentMonthDate);
    _animController?.forward();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  void _buildDateList(DateTime monthDate) {
    _dateList.clear();
    // 이 달의 1일이 무슨 요일인지 (월요일 시작)
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    int leadingDays = firstDay.weekday % 7; // 0=일, 1=월 ... 6=토 (일요일 시작)

    // 앞쪽 빈칸 (이전 달 날짜)
    for (int i = leadingDays - 1; i >= 0; i--) {
      _dateList.add(firstDay.subtract(Duration(days: i + 1)));
    }
    // 이번 달 날짜
    final daysInMonth =
        DateTime(monthDate.year, monthDate.month + 1, 0).day;
    for (int i = 0; i < daysInMonth; i++) {
      _dateList.add(DateTime(monthDate.year, monthDate.month, i + 1));
    }
    // 뒤쪽 빈칸 (6주 채우기)
    final remaining = 42 - _dateList.length;
    final lastDay = DateTime(monthDate.year, monthDate.month, daysInMonth);
    for (int i = 1; i <= remaining; i++) {
      _dateList.add(lastDay.add(Duration(days: i)));
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonthDate =
          DateTime(_currentMonthDate.year, _currentMonthDate.month - 1, 1);
      _buildDateList(_currentMonthDate);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonthDate =
          DateTime(_currentMonthDate.year, _currentMonthDate.month + 1, 1);
      _buildDateList(_currentMonthDate);
    });
  }

  bool _isCurrentMonth(DateTime d) =>
      d.month == _currentMonthDate.month && d.year == _currentMonthDate.year;

  bool _isSelected(DateTime d) =>
      d.year == _selectedDate.year &&
      d.month == _selectedDate.month &&
      d.day == _selectedDate.day;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isDisabled(DateTime d) =>
      d.isBefore(widget.minimumDate) || d.isAfter(widget.maximumDate);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animController!,
        builder: (_, __) => AnimatedOpacity(
          opacity: _animController!.value,
          duration: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 헤더: 요일 + 날짜 ──────────────────────────
                  Container(
                    decoration: const BoxDecoration(
                      color: _teal,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEE').format(_selectedDate),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM dd').format(_selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('yyyy').format(_selectedDate),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  // ── 월 이동 ────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _prevMonth,
                          color: Colors.grey[700],
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              DateFormat('MMMM, yyyy')
                                  .format(_currentMonthDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextMonth,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),

                  // ── 요일 헤더 ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                          .map((d) => SizedBox(
                                width: 36,
                                child: Center(
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                      color: _teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // ── 날짜 그리드 ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _dateList.length,
                      itemBuilder: (_, i) {
                        final d = _dateList[i];
                        final selected = _isSelected(d);
                        final today = _isToday(d);
                        final disabled = _isDisabled(d);
                        final currentMonth = _isCurrentMonth(d);

                        return GestureDetector(
                          onTap: (disabled || !currentMonth)
                              ? null
                              : () {
                                  setState(() => _selectedDate = d);
                                },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected ? _teal : Colors.transparent,
                              border: today && !selected
                                  ? Border.all(color: _teal, width: 1.5)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selected
                                      ? Colors.white
                                      : !currentMonth
                                          ? Colors.grey[300]
                                          : disabled
                                              ? Colors.grey[400]
                                              : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── 버튼 ───────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            widget.onDateSelected(_selectedDate);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text('OK',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
                ), // Column
                ), // SingleChildScrollView
              ), // ConstrainedBox
            ),
          ),
        ),
      ),
    );
  }
}
