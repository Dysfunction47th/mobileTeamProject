import 'package:flutter/material.dart';


import 'package:mobile_team_project/front/schoolCheckOk.dart';
import 'package:mobile_team_project/backend/mail/email_service.dart';

class SchoolCheck extends StatefulWidget {
  const SchoolCheck({super.key});

  @override
  State<SchoolCheck> createState() =>
      _SchoolCheckState();
}

class _SchoolCheckState extends State<SchoolCheck> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController codeController =
  TextEditingController();

  String? sentCode;

  bool loading = false;

  /// 인증 코드 전송
  Future<void> sendCode() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일을 입력하세요'),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    final fullEmail =
        '${emailController.text.trim()}@smail.kongju.ac.kr';

    final code =
    await EmailService.sendVerificationEmail(
      userEmail: fullEmail,
    );

    setState(() {
      sentCode = code;
      loading = false;
    });

    if (code != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$fullEmail 로 인증코드를 전송했습니다',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('메일 전송 실패'),
        ),
      );
    }
  }

  /// 인증 확인
  void verifyCode() {
    if (codeController.text.trim() == sentCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const SchoolCheckOk(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증 코드가 틀렸습니다'),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학교 이메일 인증'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 이메일 입력
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '공주대 이메일 아이디 입력',
                suffixText: '@smail.kongju.ac.kr',
              ),
            ),

            const SizedBox(height: 20),

            /// 인증코드 보내기
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                loading ? null : sendCode,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('인증코드 보내기'),
              ),
            ),

            const SizedBox(height: 30),

            /// 인증코드 입력
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '인증코드 입력',
              ),
            ),

            const SizedBox(height: 20),

            /// 인증하기
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: verifyCode,
                child: const Text('인증하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}