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
  // ?는 널값 가능 즉 값이 널값이여도 상관없다
  KakaoUser({
    // 클래스에서 얻은 외부 데이터를 KakaoUser객체 내부에 this를 이용하여 ㄴ저장
    this.nickname,
    this.gender,
    this.name,
    this.ageRange,
    this.birthyear,
    this.birthday,
    this.phoneNumber
  });
}