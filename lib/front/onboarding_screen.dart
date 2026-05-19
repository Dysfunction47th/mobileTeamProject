import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/login/kakao_logout.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';
import 'package:mobile_team_project/front/schoolCheck.dart';
import 'package:mobile_team_project/front/screens/chat_screen.dart';
import 'package:mobile_team_project/main.dart';

import 'package:mobile_team_project/front/screens/chat_list_screen.dart';
import 'package:mobile_team_project/front/screens/chat_room_screen.dart';
import 'package:mobile_team_project/front/screens/home_screen.dart';
import 'package:mobile_team_project/front/screens/login_screen.dart';
import 'package:mobile_team_project/front/screens/matching_home_screen.dart';
import 'package:mobile_team_project/front/screens/matching_tab_screen.dart';
import 'package:mobile_team_project/front/screens/profile_screen.dart';
import 'package:mobile_team_project/front/screens/chat_screen.dart';

import 'main_navigation.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _go(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen, // 전달된 화면으로 이동
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = UserData.user;

    // [보안] 데이터가 null일 경우 에러 화면 대신 로그인으로 튕겨내는 안전장치 사실상 필요없을거같긴한데
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage(title: '로그인 필요')),
              (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('온보딩')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('닉네임: ${user?.nickname ?? "없음"}'),
            Text('이름: ${user?.name ?? "없음"}'),
            Text('성별: ${user?.gender ?? "없음"}'),
            Text('연령대: ${user?.ageRange ?? "없음"}'),
            Text('전화번호: ${user?.phoneNumber ?? "없음"}'),
            Text('나이: ${user?.birthyear ?? "없음"}'),
            Text('생일: ${user?.birthday ?? "없음"}'),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SchoolCheck(),
                  ),
                );
              },
              child: const Text('학교인증'),
            ),

            ElevatedButton(
              onPressed: () async {
                await logoutWithKakao(context);
                UserData.clearUser(); // ⭐ 로그아웃 시 초기화
              },
              child: const Text('카카오 로그아웃'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleChatApp(user: user), // user_model의 KakaoUser 전달
                  ),
                );
              },
              child: const Text('1:1 랜덤 채팅 시작하기'),
            ),
            // ===== 화면 이동 버튼들 =====

            // 채팅 리스트 화면 이동
            ElevatedButton(
              onPressed: () =>
                  _go(context, const ChatListScreen()),
              child: const Text("Chat List Screen"),
            ),

            // 채팅방 화면 (현재 required parameter 때문에 주석 처리됨)
            // ElevatedButton(
            //   onPressed: () =>
            //       _go(context, const ChatRoomScreen()),
            //   child: const Text("Chat Room Screen"),
            // ),

            // 홈 화면 이동
            ElevatedButton(
              onPressed: () =>
                  _go(context, const HomeScreen()),
              child: const Text("Home Screen"),
            ),

            // // 홈 화면 이동
            // ElevatedButton(
            //   onPressed: () =>
            //       _go(context, const SimpleChatApp()),
            //   child: const Text("Home Screen"),
            // ),

            // 로그인 화면 이동
            ElevatedButton(
              onPressed: () =>
                  _go(context, const LoginScreen()),
              child: const Text("Login Screen"),
            ),

            // 매칭 홈 화면 이동
            ElevatedButton(
              onPressed: () =>
                  _go(context, const MatchingHomeScreen()),
              child: const Text("Matching Home Screen"),
            ),

            // 매칭 탭 화면 이동
            ElevatedButton(
              onPressed: () =>
                  _go(context, const MatchingTabScreen()),
              child: const Text("Matching Tab Screen"),
            ),

            // 프로필 화면 이동
            ElevatedButton(
              onPressed: () =>
                  _go(context, const ProfileScreen()),
              child: const Text("Profile Screen"),
            ),

            // 메인 네비게이션 화면 이동 (앱 구조 핵심 화면일 가능성 큼)
            ElevatedButton(
              onPressed: () =>
                  _go(context, const MainNavigation()),
              child: const Text("Main Navigation"),
            ),
          ],
        ),
      ),
    );
  }
}