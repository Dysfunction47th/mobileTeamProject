import 'package:flutter/material.dart';
import 'package:mobile_team_project/front/onboarding_screen2.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';

class SchoolCheckOk extends StatelessWidget {
  const SchoolCheckOk({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인증 완료')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const OnboardingScreen2(),
              ),
            );
          },
          child: const Text('다음으로 이동'),
        ),
      ),
    );
  }
}
