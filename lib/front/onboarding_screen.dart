import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/login/kakao_logout.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';
import 'package:mobile_team_project/front/schoolCheck.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserData.user;

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
          ],
        ),
      ),
    );
  }
}