import 'dart:math';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  /// 인증 코드 생성
  static String generateCode({int length = 6}) {
    final random = Random();

    return List.generate(
      length,
          (_) => random.nextInt(10),
    ).join();
  }

  /// 이메일 전송
  static Future<String?> sendVerificationEmail({
    required String userEmail,
  }) async {
    // 네 Gmail
    const senderEmail = 'geonuk1115@gmail.com';

    // Gmail 앱 비밀번호
    const appPassword = 'dwvh topy epow acnw';

    // 인증 코드 생성
    final verificationCode = generateCode();

    // Gmail SMTP 서버
    final smtpServer = gmail(
      senderEmail,
      appPassword,
    );

    // 이메일 내용
    final message = Message()
      ..from = Address(senderEmail, 'My App')
      ..recipients.add(userEmail)
      ..subject = '이메일 인증 코드'
      ..text = '인증 코드는 $verificationCode 입니다.';

    try {
      await send(message, smtpServer);

      return verificationCode;
    } catch (e) {
      print('메일 전송 실패: $e');

      return null;
    }
  }
}