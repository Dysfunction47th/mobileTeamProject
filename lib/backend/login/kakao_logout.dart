import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:logger/logger.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'package:mobile_team_project/front/screens/login_screen.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';

final logger = Logger();

Future<void> logoutWithKakao(BuildContext context) async {
  try {
    await UserApi.instance.logout();
    logger.i('로그아웃 성공, SDK에서 토큰 폐기');
  } catch (error) {
    logger.i('로그아웃 실패, SDK에서 토큰 폐기 $error');
  }

  // try {
  //   await UserApi.instance.unlink();
  //   logger.i('연결 해제 성공, SDK에서 토큰 폐기');
  // } catch (error) {
  //   logger.i('연결 해제 실패 $error');
  // }


  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),

      //로그인 화면으로 바로 이동
    ),
    (route) => false,
  );
}
