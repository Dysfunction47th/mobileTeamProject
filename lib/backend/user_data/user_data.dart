import 'user_model.dart';
import 'package:mobile_team_project/backend/user_data/user_model.dart';

class UserData {
  static KakaoUser? user;
  static bool isSchoolVerified = false; // 학교 인증 여부

  static void setUser(KakaoUser newUser) {
    user = newUser;
  }

  static void clearUser() {
    user = null;
    isSchoolVerified = false; // 로그아웃 시 인증 상태 초기화
  }
}