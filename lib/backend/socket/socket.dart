import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketManager {
  // 🔴 싱글톤 패턴 적용 (전역에서 단 하나의 소켓 인스턴스만 공유)
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  WebSocketChannel? _channel;
  Stream? _broadcastStream;

  // 💡 데스크톱 및 노트북이 서로 통신하기 위한 주소 세팅
  String get _url {
    // const String serverIp = "121.156.245.162"; // 동희님 데스크톱 IPv4 주소
    const String serverIp = "192.168.50.185"; // 동희님 데스크톱 IPv4 주소

    return "ws://$serverIp:4001";
  }

  // 🔴 핵심 수정: 기존 연결이 있으면 절대로 새로 만들지 않고 그대로 리턴!
  Future<Stream?> connect() async {
    // 이미 채널이 생성되어 있고 활성화 상태라면, 기존 스트림을 그대로 재활용 (빨대 유지)
    if (_channel != null && _broadcastStream != null) {
      print("🔄 [소켓] 이미 살아있는 싱글톤 스트림 방송망을 재활용합니다.");
      return _broadcastStream;
    }

    try {
      print("🚀 [소켓] 최초 연결 시도: $_url");
      _channel = WebSocketChannel.connect(Uri.parse(_url));

      // 여러 화면(MatchingTab, ChatRoom)에서 동시에 귀를 기울일 수 있도록 Broadcast 처리
      _broadcastStream = _channel!.stream.asBroadcastStream();

      return _broadcastStream;
    } catch (e) {
      print("❌ [소켓] 연결 실패 오류: $e");
      return null;
    }
  }

  // 서버로 패킷 데이터 전송
  void send(String message) {
    if (_channel != null) {
      print("📤 [소켓 발송]: $message");
      _channel!.sink.add(message);
    } else {
      print("⚠️ [소켓] 채널이 열려있지 않아 발송 실패: $message");
    }
  }

  // 소켓 완전 연결 해제 및 리셋
  void disconnect() {
    print("🔌 [소켓] 연결을 명시적으로 종료하고 세션을 리셋합니다.");
    _channel?.sink.close();
    _channel = null;
    _broadcastStream = null;
  }
}