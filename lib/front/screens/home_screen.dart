import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';
import 'package:mobile_team_project/backend/user_data/user_model.dart';

// 홈 화면 (앱 첫 진입 후 보여주는 메인 화면)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 저장된 사용자 정보 가져오기 (nullable)
  KakaoUser? get user => UserData.user;

  // 화면에 표시할 이름 (닉네임 우선, 없으면 이름, 둘 다 없으면 "사용자")
  String get _displayName =>
      user?.nickname ?? user?.name ?? '사용자';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 전체 배경색
      backgroundColor: const Color(0xFFFFF8FB),

      // 상단 앱바
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('번호팅'),

        // 앱바 아래 구분선
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFF2E0E8),
          ),
        ),
      ),

      // 스크롤 가능하게 설정 (콘텐츠가 길어질 수 있음)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 상단 인사 배너
            _buildGreetingBanner(),
            const SizedBox(height: 24),

            // 본문 영역 (패딩 적용)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 섹션 제목
                  _sectionTitle('번호팅 이용 안내'),
                  const SizedBox(height: 12),

                  // 사용 방법 카드 리스트
                  _buildGuideCards(),
                  const SizedBox(height: 24),

                  // 안내 배너
                  _buildNoticeBanner(),
                  const SizedBox(height: 16),

                  // 학교 인증 안내 (미인증 시에만 표시)
                  if (!UserData.isSchoolVerified) _buildSchoolVerifyBanner(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // 상단 인사 배너 UI
  // =========================
  Widget _buildGreetingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),

      // 그라데이션 배경
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
          const Text('👋 ', style: TextStyle(fontSize: 22)),

          // 사용자 이름 포함 인사 메시지
          Text(
            '안녕하세요, $_displayName님!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          // 서브 메시지
          const Text(
            '오늘도 설레는 만남이 기다리고 있어요 💕',
            style: TextStyle(fontSize: 13.5, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // =========================
  // 섹션 제목 위젯
  // =========================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2D2D2D),
      ),
    );
  }

  // =========================
  // 이용 안내 카드 리스트
  // =========================
  Widget _buildGuideCards() {

    // 안내 데이터 리스트
    final guides = [
      _GuideItem('1', '카카오 로그인', '개인정보 없이 간편하게 시작'),
      _GuideItem('2', '익명 매칭', '상대방과 익명으로 연결됩니다'),
      _GuideItem('3', '대화 시작', '공개된 정보로만 대화해요'),
    ];

    return Column(
      children: guides.map((g) {

        // 각각 카드 UI
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),

              // 그림자 효과
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [

                // 번호 원형 아이콘
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B9D),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      g.number,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 제목 + 설명
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      g.desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // =========================
  // 하단 공지 배너
  // =========================
  Widget _buildNoticeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFCCDD).withOpacity(0.6),
        ),
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
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 학교 인증 안내 배너 (미인증 시에만 표시)
  Widget _buildSchoolVerifyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCCDD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Text('🔒', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '프로필에서 학교 이메일 인증을 해야\n매칭을 시작할 수 있어요.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFFFF6B9D),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// 안내 카드 데이터 모델
// =========================
class _GuideItem {
  final String number; // 단계 번호
  final String title;  // 제목
  final String desc;   // 설명

  _GuideItem(this.number, this.title, this.desc);
}
