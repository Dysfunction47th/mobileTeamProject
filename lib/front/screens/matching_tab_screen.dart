import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/client/client.dart'; // 소켓 매니저 연결
import 'package:mobile_team_project/backend/user_data/user_data.dart'; // 유저 데이터 연결
import 'package:mobile_team_project/front/models/models.dart'; // ChatRoom 모델 연결
import 'package:mobile_team_project/front/screens/chat_room_screen.dart'; // 정식 채팅방 화면 연결

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
    '전체 학과', '전기공학과', '전자공학과', '반도체공학과', '컴퓨터공학과',
    '소프트웨어학과', '인공지능학과', '정보통신공학과', '스마트정보기술공학과', '기계공학과',
    '자동차공학과', '메카트로닉스공학과', '건설환경공학과', '건축학과', '건축공학과',
    '화학공학과', '신소재공학과', '산업디자인공학과', '환경공학과', '금형설계공학과',
  ];

  final List<String> _years = ['1학년', '2학년', '3학년', '4학년'];

  // 학년 텍스트 표시
  String get _yearText {
    if (_selectedYears.length == 4) return '전체 학년';
    final sorted = _selectedYears.toList()..sort();
    return sorted.join(', ');
  }

  // 🔴 실시간 매칭 시작 및 소켓 빨대 리스너 가동
  void _onMatchStart() async {
    if (_selectedYears.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('학년을 선택해주세요!', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: const Color(0xFFFF8C42),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final user = UserData.user;
    if (user == null) {
      print("⚠️ 로그인된 유저 정보가 없습니다.");
      return;
    }

    setState(() => _isMatching = true);

    // 소켓 서버 물리적 연결
    final socketManager = SocketManager();
    final stream = await socketManager.connect();

    if (stream == null) {
      print("❌ 소켓 서버 연결 실패. IP 주소나 서버 구동 여부를 확인하세요.");
      setState(() => _isMatching = false);
      return;
    }

// 🔄 실시간 패킷 리스너 가동
    stream.listen((data) {
      print("📩 [소켓 수신]: $data"); // ◀ 로그를 통해 패킷이 진짜 오는지 확인!
      try {
        final Map<String, dynamic> decoded = jsonDecode(data.toString());

        if (decoded['type'] == 'match_start') {
          print("🎯 [매칭 성공] 서버로부터 신호 수신됨!"); // ◀ 여기까지 찍히는지 확인

          final senderData = decoded['sender'] ?? {};
          final opponentNick = senderData['nickname'] ?? '익명 상대방';
          final opponentGender = senderData['gender'] ?? '여성';

          // [핵심] 여기서 setState로 매칭 상태를 먼저 해제하고 안전하게 전환
          if (mounted) {
            setState(() => _isMatching = false);

            final matchedRoom = ChatRoom(
              id: 'matched_room_session',
              nickname: opponentNick,
              lastMessage: '연결되었습니다.',
              time: '방금',
              emoji: '🌸',
            );

            // 딜레이 없이 즉시 화면 전환
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(room: matchedRoom),
              ),
            );
          }
        }
      } catch (e) {
        print("⚠️ 매칭 파싱 에러 발생: $e");
      }
    });

    // 🔴 내 조건(filter)과 카카오 API에서 뽑아온 내 정보(myProfile) 전송 패킷 조립
    final matchRequestPacket = jsonEncode({
      'type': 'match_start',
      'filter': {
        'gender': _myGender == '남성' ? '여성' : '남성',
        'years': _selectedYears.toList(),
      },
      'myProfile': {
        'nickname': user.nickname ?? "익명 유저",
        'gender': _myGender,
      }
    });

    socketManager.send(matchRequestPacket);
  }

  // 🔴 매칭 취소 처리 로직
  void _onMatchCancel() {
    SocketManager().send(jsonEncode({'type': 'match_cancel'}));
    SocketManager().disconnect(); // 연결 해제 및 리셋
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
                color: isSelected ? const Color(0xFFFF6B9D) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                gender,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF888888),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

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
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: e.key < _years.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFE4EF) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                year,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFF888888),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeptSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _deptOpen = !_deptOpen),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _deptOpen ? const Color(0xFFFF6B9D) : const Color(0xFFE0E0E0),
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
                  _deptOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF0F5) : Colors.transparent,
                      border: index < _departments.length - 1
                          ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dept,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_rounded, color: Color(0xFFFF6B9D), size: 16),
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

  // 선택한 카테고리 표시 배너
  Widget _buildNotice() {
    final oppositeGender = _myGender == '남성' ? '여성' : '남성';
    final yearText = _selectedYears.isEmpty ? '학년 미선택' : _yearText;

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
          const Icon(Icons.favorite_rounded, color: Color(0xFFFF6B9D), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$oppositeGender / $yearText / $_selectedDept 로 매칭됩니다',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFFF6B9D),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchButton() {
    if (_isMatching) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF6B9D)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_myGender == '남성' ? '여성' : '남성'} / $_yearText / $_selectedDept 매칭 중...',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _onMatchCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '취소',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF888888)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
