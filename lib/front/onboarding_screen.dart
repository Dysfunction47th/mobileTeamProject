import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/login/kakao_logout.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';


class OnboardingScreen extends StatelessWidget {
  final KakaoUser user;

  const OnboardingScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('온보딩')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('닉네임: ${user.nickname ?? "없음"}'),
            Text('이름: ${user.name ?? "없음"}'),
            Text('성별: ${user.gender ?? "없음"}'),
            Text('연령대: ${user.ageRange ?? "없음"}'),
            Text('전화번호: ${user.phoneNumber ?? "없음"}'),
            Text('나이: ${user.birthyear ?? "없음"}'),
            Text('생일: ${user.birthday ?? "없음"}'),

            ElevatedButton(
              onPressed: () async {
                await logoutWithKakao(context);
              },
              child: const Text('카카오 로그아웃'),
            ),
          ],
        ),

      ),
    );
  }
}
