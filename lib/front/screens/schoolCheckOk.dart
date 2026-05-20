import 'package:flutter/material.dart';
import 'package:mobile_team_project/front/screens/profile_screen.dart';

class SchoolCheckOk extends StatelessWidget {
  const SchoolCheckOk({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인증 완료')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '✅ 학교 인증이 완료되었습니다!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 인증 완료 후 프로필 화면으로 이동 (스택 유지)
                Navigator.pop(context,true);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
