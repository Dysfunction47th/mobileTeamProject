import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:logger/logger.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'package:mobile_team_project/front/onboarding_screen.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';


final logger = Logger();
// 로그 사용을 위한 final logger 변수 선언
KakaoUser createKakaoUser(User user) {
  // 유저 정보를 KakaoUser클래스에 저장하는 함수
  return KakaoUser(
    nickname: user.kakaoAccount?.profile?.nickname,
    gender: user.kakaoAccount?.gender?.name,
    name: user.kakaoAccount?.name,
    ageRange: user.kakaoAccount?.ageRange?.name,
    birthyear: user.kakaoAccount?.birthyear,
    birthday: user.kakaoAccount?.birthday,
    phoneNumber: user.kakaoAccount?.phoneNumber,
  // ?는 널값 오류 방지용
  );
}

Future<void> loginWithKakao(BuildContext context) async {
  try {
    if (await AuthApi.instance.hasToken()) {
      // 만약 로그를 이용해 코드가 31번줄 이상으로 실행을 못하는걸 확인 했을때
      // 해시값을 확인하면 좋음 (메인액티비티.kt을 확인해서 해시값 확인)
      // 카카오(내가 저장한 나의 해시값) <-> 나(나의 해시값)
      // 서로 동일해야지 로그인이 됨
      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        OAuthToken? token =
        await TokenManagerProvider.instance.manager.getToken();

        logger.i(
            '✅ 기존 토큰 유효: userId=${tokenInfo.id}, accessToken=${token?.accessToken}');

        User user = await UserApi.instance.me();
        logger.i('✅ 사용자 정보: userId=${user.id}, '
            '닉네임=${user.kakaoAccount?.profile?.nickname}'
            '성별=${user.kakaoAccount?.gender}'
            '이름=${user.kakaoAccount?.name}'
            '연령대=${user.kakaoAccount?.ageRange}'
            '나이=${user.kakaoAccount?.birthyear}'
            '생일=${user.kakaoAccount?.birthday}'
            '전화번호=${user.kakaoAccount?.phoneNumber}'
        );
        final kakaoUser = createKakaoUser(user);
        // 유저정보 넘기기
        if (context.mounted) {

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>  OnboardingScreen(user: kakaoUser),
            // OnboardingScreen로 이동
            ),
          );

        }
        return;
      } catch (error) {
        if (error is KakaoException && error.isInvalidTokenError()) {
          logger.w('⚠️ 토큰 만료됨, 재로그인 필요');
        } else {
          logger.e('❌ 토큰 유효성 체크 실패: $error');
        }
      }
    } else {
      logger.w('🔑 저장된 토큰 없음, 로그인 필요');
    }

    bool isInstalled = await isKakaoTalkInstalled();
    logger.i('카카오톡 설치 여부 확인 결과: $isInstalled');

    if (isInstalled) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        logger.i('✅ 카카오톡 로그인 성공: accessToken=${token.accessToken}');
        User user = await UserApi.instance.me();
        logger.i('✅ 사용자 정보: userId=${user.id}, '
            '닉네임=${user.kakaoAccount?.profile?.nickname}'
            '성별=${user.kakaoAccount?.gender}'
            '이름=${user.kakaoAccount?.name}'
            '연령대=${user.kakaoAccount?.ageRange}'
            '나이=${user.kakaoAccount?.birthyear}'
            '생일=${user.kakaoAccount?.birthday}'
            '전화번호=${user.kakaoAccount?.phoneNumber}'

        );

        final kakaoUser = createKakaoUser(user);


        if (context.mounted) {
          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OnboardingScreen(user: kakaoUser),
            ),
          );

        }
        return;
      } catch (error) {
        logger.w('❌ 카카오톡 로그인 실패: $error');
        if (error is PlatformException && error.code == 'CANCELED') return;

        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          logger.i('✅ 카카오계정 로그인 성공: accessToken=${token.accessToken}');
          User user = await UserApi.instance.me();
          logger.i('✅ 사용자 정보: userId=${user.id}, '
              '닉네임=${user.kakaoAccount?.profile?.nickname}'
              '성별=${user.kakaoAccount?.gender}'
              '이름=${user.kakaoAccount?.name}'
              '연령대=${user.kakaoAccount?.ageRange}'
              '나이=${user.kakaoAccount?.birthyear}'
              '생일=${user.kakaoAccount?.birthday}'
              '전화번호=${user.kakaoAccount?.phoneNumber}'
          );

          final kakaoUser = createKakaoUser(user);

          if (context.mounted) {

            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OnboardingScreen(user: kakaoUser),
              ),
            );

          }
          return;
        } catch (error) {
          logger.e('❌ 카카오계정 로그인 실패: $error');
          return;
        }
      }
    } else {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        logger.i('✅ 카카오계정 로그인 성공: accessToken=${token.accessToken}');
        User user = await UserApi.instance.me();
        logger.i('✅ 사용자 정보: userId=${user.id}, '
            '닉네임=${user.kakaoAccount?.profile?.nickname}'
            '성별=${user.kakaoAccount?.gender}'
            '이름=${user.kakaoAccount?.name}'
            '연령대=${user.kakaoAccount?.ageRange}'
            '나이=${user.kakaoAccount?.birthyear}'
            '생일=${user.kakaoAccount?.birthday}'
            '전화번호=${user.kakaoAccount?.phoneNumber}'
        );
        final kakaoUser = createKakaoUser(user);


        if (context.mounted) {

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OnboardingScreen(user: kakaoUser),
            ),
          );

        }
      } catch (error) {
        logger.e('❌ 카카오계정 로그인 실패: $error');
      }
    }
  } catch (e, stack) {
    logger.e("⚠️ 로그인 중 예외 발생: $e\n$stack");
  }
}

