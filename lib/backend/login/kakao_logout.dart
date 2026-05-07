
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:logger/logger.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'package:mobile_team_project/main.dart';
import 'package:mobile_team_project/front/onboarding_screen.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';


Future<void> logoutWithKakao(BuildContext context) async {
  try {
    await UserApi.instance.logout();
    logger.i('로그아웃 성공, SDK에서 토큰 폐기');
  } catch (error) {
    logger.i('로그아웃 실패, SDK에서 토큰 폐기 $error');

  }

  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const MyHomePage(title: 'Flutter Demo Home Page'),
    ),
        (route) => false,
  );
}

