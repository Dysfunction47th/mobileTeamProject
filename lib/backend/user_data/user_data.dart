import 'user_model.dart';
import 'package:flutter/material.dart';

class UserData {
  static KakaoUser? user;

  // 플러터에서는 단순 변수로는 UI가 그 변경을 감지하지 못해 상태관리로 변경을 감지해야 화면이 갱신
  // ex)static bool isSchoolVerified = false;
  static ValueNotifier<bool> isSchoolVerified = ValueNotifier(false);

  static void setUser(KakaoUser newUser) {
    user = newUser;
  }
  static void clearUser() {
    user = null;
    isSchoolVerified.value = false;
  }
}
