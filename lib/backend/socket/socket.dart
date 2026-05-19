import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:mobile_team_project/backend/login/kakao_login.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  WebSocketChannel? _channel;
  Stream? _broadcastStream;


  String get _url {
// 실제 기기 테스트 시: PC의 IPv4 주소를 직접 입력 (예: 192.168.0.15)
    // 에뮬레이터 테스트 시: "10.0.2.2" 사용
    const String serverIp = "10.0.2.2"; //실제 기기 시연용

    return "ws://$serverIp:4001";
  }

  // 현재 연결 상태 확인
  bool get isConnected => _channel != null;

  Future<Stream?> connect() async {
    // 기존 연결이 있다면 종료
    await disconnect();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      // asBroadcastStream을 써야 여러 Widget에서 동시에 들을 수 있음
      _broadcastStream = _channel!.stream.asBroadcastStream();

      print("🚀 소켓 연결 시도: $_url");
      return _broadcastStream;
    } catch (e) {
      print("❌ 연결 실패: $e");
      return null;
    }
  }

  void send(String msg) {
    if (_channel != null) {
      _channel!.sink.add(msg);
    } else {
      print("⚠️ 연결된 소켓이 없습니다.");
      logger.i('⚠️ 연결된 소켓이 없습니다.');
    }
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _broadcastStream = null;
  }
}