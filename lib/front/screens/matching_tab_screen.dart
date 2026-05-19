import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';
import 'package:mobile_team_project/front/screens/chat_screen.dart';

class MatchingTabScreen extends StatefulWidget {
  const MatchingTabScreen({super.key});

  @override
  State<MatchingTabScreen> createState() => _MatchingTabScreenState();
}

class _MatchingTabScreenState extends State<MatchingTabScreen> {

  // 직접 선택하는 성별
  String _myGender = '남성';

  // 매칭 중 상태
  bool _isMatching = false;

  // 선택된 학년 (복수 선택)
  final Set<String> _selectedYears = {};

  // 선택된 학과
  String _selectedDept = '전체 학과';

  // 학과 드롭다운 열림 여부
  bool _deptOpen = false;

  // 공주대 천안공과대학 학과 목록
  final List<String> _departments = [
    '전체 학과',
    '전기공학과',
    '전자공학과',
    '반도체공학과',
    '컴퓨터공학과',
    '소프트웨어학과',
    '인공지능학과',
    '정보통신공학과',
    '스마트정보기술공학과',
    '기계공학과',
    '자동차공학과',
    '메카트로닉스공학과',
    '건설환경공학과',
    '건축학과',
    '건축공학과',
    '화학공학과',
    '신소재공학과',
    '산업디자인공학과',
    '환경공학과',
    '금형설계공학과',
  ];

  final List<String> _years = ['1학년', '2학년', '3학년', '4학년'];

  // 학년 텍스트 표시
  String get _yearText {
    if (_selectedYears.length == 4) return '전체 학년';
    final sorted = _selectedYears.toList()..sort();
    return sorted.join(', ');
  }

  void _onMatchStart() {
    if (_selectedYears.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('학년을 선택해주세요!',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: const Color(0xFFFF8C42),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final user = UserData.user;
    if (user == null) return;

    setState(() => _isMatching = true);

    // 소켓 서버 연결 및 채팅 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleChatApp(user: user),
      ),
    ).then((_) {
      // 채팅 화면에서 돌아오면 매칭 상태 초기화
      setState(() => _isMatching = false);
    });
  }

  void _onMatchCancel() {
    setState(() => _isMatching = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _deptOpen = false),
      child: Container(
        color: const Color(0xFFFFF0F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('내 성별 선택'),
              const SizedBox(height: 8),
              _buildGenderSelector(),
              const SizedBox(height: 20),

              _sectionLabel('상대방 학년'),
              const SizedBox(height: 8),
              _buildYearSelector(),
              const SizedBox(height: 20),

              _sectionLabel('상대방 학과'),
              const SizedBox(height: 8),
              _buildDeptSelector(),
              const SizedBox(height: 28),

              _buildNotice(),
              const SizedBox(height: 16),

              _buildMatchButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF555555),
      ),
    );
  }

  // 성별 선택
  Widget _buildGenderSelector() {
    return Row(
      children: ['남성', '여성'].asMap().entries.map((e) {
        final gender = e.value;
        final isSelected = gender == _myGender;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _myGender = gender),
            child: Container(
              margin: EdgeInsets.only(right: e.key == 0 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B9D)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B9D)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                gender,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? Colors.white : const Color(0xFF888888),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 학년 선택 (복수 선택, 4개 전부 선택 시 전체학년)
  Widget _buildYearSelector() {
    return Row(
      children: _years.asMap().entries.map((e) {
        final year = e.value;
        final isSelected = _selectedYears.contains(year);
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedYears.remove(year);
                } else {
                  _selectedYears.add(year);
                }
                if (_selectedYears.length == 4) {
                  _selectedYears
                    ..clear()
                    ..addAll(['1학년', '2학년', '3학년', '4학년']);
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                  right: e.key < _years.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFE4EF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B9D)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                year,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFFFF6B9D)
                      : const Color(0xFF888888),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 학과 선택 드롭다운
  Widget _buildDeptSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _deptOpen = !_deptOpen),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _deptOpen
                    ? const Color(0xFFFF6B9D)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDept,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                Icon(
                  _deptOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFFF6B9D),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_deptOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _departments.length,
              itemBuilder: (context, index) {
                final dept = _departments[index];
                final isSelected = dept == _selectedDept;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDept = dept;
                      _deptOpen = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF0F5)
                          : Colors.transparent,
                      border: index < _departments.length - 1
                          ? const Border(
                              bottom: BorderSide(
                                  color: Color(0xFFF5F5F5), width: 0.5))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dept,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFFFF6B9D)
                                  : const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_rounded,
                              color: Color(0xFFFF6B9D), size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // 이성 매칭 안내 배너
  Widget _buildNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_rounded,
              color: Color(0xFFFF6B9D), size: 14),
          const SizedBox(width: 6),
          Text(
            '${_myGender == '남성' ? '여성' : '남성'}과만 매칭됩니다',
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFFFF6B9D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 매칭 버튼 (매칭 중일 때 로딩바 + 취소 버튼)
  Widget _buildMatchButton() {
    if (_isMatching) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCCDD)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFFF6B9D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_myGender == '남성' ? '여성' : '남성'} / $_yearText / $_selectedDept 매칭 중...',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _onMatchCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _onMatchStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B9D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text(
          '매칭 시작하기',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
