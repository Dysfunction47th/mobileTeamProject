import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/socket/socket.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';
import 'package:mobile_team_project/front/models/models.dart';
import 'package:mobile_team_project/front/screens/chat_room_screen.dart'; // 팀원들이 만든 정식 채팅방 화면 연결

class MatchingTabScreen extends StatefulWidget {
  const MatchingTabScreen({super.key});

  @override
  State<MatchingTabScreen> createState() => _MatchingTabScreenState();
}

class _MatchingTabScreenState extends State<MatchingTabScreen> {
  String _myGender = '남성';
  bool _isMatching = false;
  final Set<String> _selectedYears = {};
  String _selectedDept = '전체 학과';
  bool _deptOpen = false;

  final List<String> _departments = [
    '전체 학과', '전기공학과', '전자공학과', '반도체공학과', '컴퓨터공학과',
    '소프트웨어학과', '인공지능학과', '정보통신공학과', '스마트정보기술공학과', '기계공학과',
    '자동차공학과', '메카트로닉스공학과', '건설환경공학과', '건축학과', '건축공학과',
    '화학공학과', '신소재공학과', '산업디자인공학과', '환경공학과', '금형설계공학과',
  ];

  final List<String> _years = ['1학년', '2학년', '3학년', '4학년'];

  String get _yearText {
    if (_selectedYears.length == 4) return '전체 학년';
    final sorted = _selectedYears.toList()..sort();
    return sorted.join(', ');
  }

  // 🔴 동희님 핵심 로직 이식: 서버 신호 대기 및 프로필 패키징 발송
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
    if (user == null) return;

    setState(() => _isMatching = true);

    final socketManager = SocketManager();
    final stream = await socketManager.connect();

    // 🔄 실시간 리스너 작동: 서버가 match_start 패킷을 던져주면 캐치함
    stream?.listen((data) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(data.toString());

        if (decoded['type'] == 'match_start') {
          final senderData = decoded['sender'] ?? {};
          final opponentNick = senderData['nickname'] ?? '익명 상대방';
          final opponentGender = senderData['gender'] ?? '여성';

          if (mounted) {
            setState(() => _isMatching = false);

            // 서버에서 받은 실시간 프로필 정보를 담아서 팀원들이 만든 정식 채팅방으로 진입!
            final matchedRoom = ChatRoom(
              id: 'matched_room_session',
              nickname: opponentNick,
              lastMessage: '연결되었습니다.',
              time: '방금',
              emoji: (opponentGender.contains('female') || opponentGender == '여성') ? '🌸' : '⭐',
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(room: matchedRoom),
              ),
            ).then((_) {
              if (mounted) setState(() => _isMatching = false);
            });
          }
        }
      } catch (e) {
        print("⚠️ 매칭 대기 중 패킷 파싱 오류: $e");
      }
    });

    // 내 필터 조건과 카카오 기반 진짜 프로필 정보를 결합하여 서버로 전송
    // (현재 가입창 학과 데이터 저장 로직 전이므로, 테스트 유연성을 위해 소프트웨어학과 디폴트 세팅)
    final matchRequestPacket = jsonEncode({
      'type': 'match_start',
      'filter': {
        'gender': _myGender == '남성' ? '여성' : '남성',
        'years': _selectedYears.toList(),
        'department': _selectedDept
      },
      'myProfile': {
        'nickname': user.nickname ?? "익명 유저",
        'gender': _myGender,
        'department': '소프트웨어학과'
      }
    });

    socketManager.send(matchRequestPacket);
  }

  void _onMatchCancel() {
    SocketManager().send(jsonEncode({'type': 'match_cancel'}));
    SocketManager().disconnect();
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
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF555555)));
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
                border: Border.all(color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFFE0E0E0)),
              ),
              child: Text(gender, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF888888))),
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
                border: Border.all(color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFFE0E0E0)),
              ),
              child: Text(year, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFF888888))),
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
              border: Border.all(color: _deptOpen ? const Color(0xFFFF6B9D) : const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(_selectedDept, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)))),
                Icon(_deptOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: const Color(0xFFFF6B9D), size: 20),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
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
                      border: index < _departments.length - 1 ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5)) : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(dept, style: TextStyle(fontSize: 13.5, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFF2D2D2D)))),
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

  Widget _buildNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFFFE4EF), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_rounded, color: Color(0xFFFF6B9D), size: 14),
          const SizedBox(width: 6),
          Text('${_myGender == '남성' ? '여성' : '남성'}과만 매칭됩니다', style: const TextStyle(fontSize: 12.5, color: Color(0xFFFF6B9D), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMatchButton() {
    if (_isMatching) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFCCDD))),
        child: Row(
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF6B9D))),
            const SizedBox(width: 12),
            Expanded(child: Text('${_myGender == '남성' ? '여성' : '남성'} / $_yearText / $_selectedDept 매칭 중...', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _onMatchCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(8)),
                child: const Text('취소', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF888888))),
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
        child: const Text('매칭 시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}