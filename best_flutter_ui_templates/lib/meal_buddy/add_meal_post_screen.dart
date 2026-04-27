import 'package:flutter/material.dart';
import 'model/meal_post.dart';

class AddMealPostScreen extends StatefulWidget {
  final String sessionId;       // 작성자 세션 ID
  final int authorTrustScore;   // 작성자 매너 온도
  const AddMealPostScreen({
    Key? key,
    required this.sessionId,
    this.authorTrustScore = 70,
  }) : super(key: key);

  @override
  State<AddMealPostScreen> createState() => _AddMealPostScreenState();
}

class _AddMealPostScreenState extends State<AddMealPostScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  final _menuController = TextEditingController();
  final _memoController = TextEditingController();

  String _selectedTime = '12:00';
  int _maxPeople = 2;

  // 인기 장소 빠른 선택
  final List<String> _popularLocations = [
    '학생식당',
    '제2학생회관',
    '교직원식당',
    '스타벅스',
    '편의점',
    '기타',
  ];

  // 인기 메뉴 빠른 선택
  final List<String> _popularMenus = [
    '한식',
    '중식',
    '일식',
    '양식',
    '분식',
    '아무거나',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _locationController.dispose();
    _menuController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final post = MealPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: widget.sessionId,               // 작성자 세션 ID 저장
        nickname: _nicknameController.text.trim(),
        location: _locationController.text.trim(),
        time: _selectedTime,
        maxPeople: _maxPeople,
        menu: _menuController.text.trim(),
        memo: _memoController.text.trim(),
        createdAt: DateTime.now(),
        authorTrustScore: widget.authorTrustScore, // 글 작성 시점의 매너 온도 기록
      );
      Navigator.pop(context, post);
    }
  }

  Future<void> _pickTime() async {
    final parts = _selectedTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 12,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _selectedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF54D3C2);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: const Text(
          '밥친구 모집 글 작성',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text(
              '등록',
              style: TextStyle(
                  color: teal, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 닉네임
            _sectionCard(
              children: [
                _label('닉네임', Icons.person_outline),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nicknameController,
                  decoration: _inputDecoration('예: 배고픈 새내기'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '닉네임을 입력해주세요' : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 장소 선택
            _sectionCard(
              children: [
                _label('식사 장소', Icons.location_on_outlined),
                const SizedBox(height: 8),
                // 빠른 선택 칩
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _popularLocations.map((loc) {
                    return ChoiceChip(
                      label: Text(loc),
                      selected: _locationController.text == loc,
                      onSelected: (selected) {
                        setState(() {
                          _locationController.text = selected ? loc : '';
                        });
                      },
                      selectedColor: teal.withOpacity(0.2),
                      checkmarkColor: teal,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  decoration: _inputDecoration('직접 입력...'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '장소를 입력해주세요' : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 시간 + 인원 (가로 배치)
            Row(
              children: [
                // 시간
                Expanded(
                  child: _sectionCard(
                    children: [
                      _label('만날 시간', Icons.access_time),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedTime,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const Icon(Icons.edit, size: 16,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 인원
                Expanded(
                  child: _sectionCard(
                    children: [
                      _label('모집 인원', Icons.people_outline),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: teal,
                            onPressed: _maxPeople > 2
                                ? () => setState(() => _maxPeople--)
                                : null,
                          ),
                          Text('$_maxPeople명',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: teal,
                            onPressed: _maxPeople < 10
                                ? () => setState(() => _maxPeople++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 메뉴
            _sectionCard(
              children: [
                _label('희망 메뉴', Icons.restaurant_menu_outlined),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _popularMenus.map((menu) {
                    return ChoiceChip(
                      label: Text(menu),
                      selected: _menuController.text == menu,
                      onSelected: (selected) {
                        setState(() {
                          _menuController.text = selected ? menu : '';
                        });
                      },
                      selectedColor: teal.withOpacity(0.2),
                      checkmarkColor: teal,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _menuController,
                  decoration: _inputDecoration('직접 입력...'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '메뉴를 입력해주세요' : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 한마디
            _sectionCard(
              children: [
                _label('한마디', Icons.chat_bubble_outline),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _memoController,
                  decoration: _inputDecoration('예: 조용히 먹을 분 환영해요 😊'),
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 등록 버튼
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              child: const Text(
                '밥친구 모집 시작!',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _label(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF54D3C2)),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF54D3C2)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
