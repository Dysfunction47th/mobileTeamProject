import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get KAKAO_API_KEY =>
      dotenv.env['KAKAO_API_KEY'] ?? '';

  static String get APP_PASSWORD =>
      dotenv.env['APP_PASSWORD'] ?? '';
}