import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';

// 각 화면 import (다른 페이지로 이동하기 위해 필요)
import 'package:mobile_team_project/front/screens/chat_list_screen.dart';
import 'package:mobile_team_project/front/screens/chat_room_screen.dart';
import 'package:mobile_team_project/front/screens/home_screen.dart';
import 'package:mobile_team_project/front/screens/login_screen.dart';
import 'package:mobile_team_project/front/screens/matching_home_screen.dart';
import 'package:mobile_team_project/front/screens/matching_tab_screen.dart';
import 'package:mobile_team_project/front/screens/profile_screen.dart';
import 'main_navigation.dart';

// 온보딩 2 화면 (사용자 정보 확인 + 테스트 이동 버튼 화면)
class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  // 화면 이동을 간단하게 하기 위한 함수
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
    // 저장된 사용자 데이터 가져오기
    final user = UserData.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('온보딩 2'),
      ),

      // 화면 전체 padding 설정
      body: Padding(
        padding: const EdgeInsets.all(16),

        // 스크롤 가능하게 (내용 많아도 넘치지 않게)
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 사용자 정보 표시 영역
              Text('닉네임: ${user?.nickname ?? "정보 없음"}'),
              Text('이름: ${user?.name ?? "정보 없음"}'),
              Text('성별: ${user?.gender ?? "정보 없음"}'),
              Text('나이대: ${user?.ageRange ?? "정보 없음"}'),
              Text('생년: ${user?.birthyear ?? "정보 없음"}'),
              Text('생일: ${user?.birthday ?? "정보 없음"}'),
              Text('전화번호: ${user?.phoneNumber ?? "정보 없음"}'),

              const SizedBox(height: 20), // UI 간격

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
      ),
    );
  }
}