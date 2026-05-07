// user_model.dart
import 'package:mobile_team_project/front/onboarding_screen.dart';
import 'package:mobile_team_project/backend/login/kakao_login.dart';

class KakaoUser {
  final String? nickname;
  final String? gender;
  final String? name;
  final String? ageRange;
  final String? birthyear;
  final String? birthday;
  final String? phoneNumber;

  KakaoUser({
    this.nickname,
    this.gender,
    this.name,
    this.ageRange,
    this.birthyear,
    this.birthday,
    this.phoneNumber
  });
}