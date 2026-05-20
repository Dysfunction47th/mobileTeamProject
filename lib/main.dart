import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import 'package:mobile_team_project/backend/config/securityData.dart';
import 'package:mobile_team_project/front/screens/login_screen.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // env 로드
  await dotenv.load(fileName: "securityData.env");

  // 카카오 로그인 초기화
  KakaoSdk.init(
    // env를 활용해 securityData.dart에서 네이키브 키값 가져옴
    nativeAppKey: Env.KAKAO_API_KEY,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '번호팅',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
          primary: const Color(0xFFFF6B9D),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2D2D2D),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // 시작 화면: 우리가 만든 로그인 화면
      home: const LoginScreen(),
    );
  }
}
