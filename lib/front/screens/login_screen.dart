import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/login/kakao_login.dart';

// ══════════════════════════════════════════════════════
//  로그인 전 화면
//
//  카카오 공식 로그인 버튼 이미지 사용법:
//  1) https://developers.kakao.com/tool/resource/login
//     → "카카오 로그인 버튼" 이미지 다운로드
//  2) 프로젝트 루트 기준  assets/images/kakao_login_medium_wide.png  저장
//  3) pubspec.yaml > flutter > assets 에 경로 추가
//  4) 아래 _useKakaoImage = true 로 변경
// ══════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onKakaoLogin() async {
    await loginWithKakao(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5F9),
              Color(0xFFFFE4EF),
              Color(0xFFFFCCDE),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // ── 로고 영역 ──
                    _buildLogo(),
                    const SizedBox(height: 22),
                    const Text(
                      '번호팅',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF6B9D),
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '익명으로 시작하는 설레는 만남 💌',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF999999),
                        height: 1.4,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── 카카오 로그인 버튼 ──
                    _KakaoLoginButton(onTap: _onKakaoLogin),

                    const SizedBox(height: 20),
                    const Text(
                      '로그인 시 이용약관 및 개인정보처리방침에 동의합니다',
                      style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.22),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Center(
        child: Text('💕', style: TextStyle(fontSize: 54)),
      ),
    );
  }
}

// ────────────────────────────────────────────
//  카카오 공식 로그인 버튼
//
//  ★ 이미지 등록 완료 후 _useKakaoImage = true 로 변경
// ────────────────────────────────────────────
class _KakaoLoginButton extends StatelessWidget {
  final VoidCallback onTap;

  // ← 카카오 이미지 assets에 등록하면 true로 바꾸세요
  static const bool _useKakaoImage = true;

  const _KakaoLoginButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (_useKakaoImage) {
      return GestureDetector(
        onTap: onTap,
        child: Center(             // ← 중앙 정렬
          child: Image.asset(
            'assets/images/kakao_login_medium_wide.png',
            width: 300,            // ← 원하는 너비로 숫자 조절
            height: 60,            // ← 원하는 높이로 숫자 조절
            fit: BoxFit.contain,   // ← fitWidth → contain 으로 변경
          ),
        ),
      );
    }

    // Fallback 버튼 (이미지 미등록 상태)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE500), // 카카오 공식 Yellow
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE6CF00).withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 카카오 말풍선 심볼 (간소화 버전)
            Container(
              width: 28,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF3C1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    color: Color(0xFFFEE500),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '카카오로 로그인',
              style: TextStyle(
                color: Color(0xFF3C1E1E),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
