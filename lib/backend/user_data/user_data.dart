import 'user_model.dart';
import 'package:mobile_team_project/backend/user_data/user_model.dart';

class UserData {
  static KakaoUser? user;

  // 로그인 시 저장
  static void setUser(KakaoUser newUser) {
    user = newUser;
  }

  // 로그아웃
  static void clearUser() {
    user = null;
  }
}