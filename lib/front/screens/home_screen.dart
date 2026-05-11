import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';

// ══════════════════════════════════════════════════════
//  홈 화면
//  KakaoUser 에서 닉네임(또는 이름) 을 받아 인사말 표시
// ══════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  final KakaoUser user;

  const HomeScreen({super.key, required this.user});

  // 표시할 이름: 닉네임 우선, 없으면 이름, 둘 다 없으면 '사용자'
  String get _displayName =>
      user.nickname ?? user.name ?? '사용자';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('번호팅'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF2E0E8)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단 인사 배너 (카카오 이름 표시)
            _buildGreetingBanner(),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('번호팅 이용 안내'),
                  const SizedBox(height: 12),
                  _buildGuideCards(),
                  const SizedBox(height: 24),
                  _buildNoticeBanner(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B9D), Color(0xFFFF99BB)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👋 ', style: TextStyle(fontSize: 22)),
              // ── 카카오 닉네임/이름 표시
              Text(
                '안녕하세요, $_displayName님!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '오늘도 설레는 만남이 기다리고 있어요 💕',
            style: TextStyle(fontSize: 13.5, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D)));
  }

  Widget _buildGuideCards() {
    final guides = [
      _GuideItem('1', '카카오 로그인', '개인정보 없이 간편하게 시작'),
      _GuideItem('2', '익명 매칭', '상대방과 익명으로 연결됩니다'),
      _GuideItem('3', '대화 시작', '공개된 정보로만 대화해요'),
    ];
    return Column(
      children: guides
          .map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B9D),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(g.number,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D2D2D))),
                          const SizedBox(height: 2),
                          Text(g.desc,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999))),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFFFFCCDD).withOpacity(0.6)),
      ),
      child: const Row(
        children: [
          Text('📢', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '매너 있는 대화 문화를 함께 만들어요.\n불쾌한 대화 상대는 신고할 수 있습니다.',
              style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF997788),
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideItem {
  final String number;
  final String title;
  final String desc;
  _GuideItem(this.number, this.title, this.desc);
}
