import 'package:flutter/material.dart';
import 'package:mobile_team_project/front/screens/profile_screen.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';


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
                UserData.isSchoolVerified = true; // 인증 완료 저장
                Navigator.pop(context, true);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
