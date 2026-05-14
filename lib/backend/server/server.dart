import 'dart:io';
import 'dart:convert';

void main() async {
  // 127.0.0.1이 아닌 anyIPv4(0.0.0.0)로 열어야 에뮬레이터(10.0.2.2)가 들어옵니다.
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 4001);
  print('서버 가동 중: ws://0.0.0.0:4001');

  List<WebSocket> queue = [];

  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);

      // 접속 시마다 죽은 세션(찌꺼기) 정리
      queue.removeWhere((s) => s.readyState != WebSocket.open);

      queue.add(socket);
      print('새 접속 확인! 현재 대기열: ${queue.length}명');

      if (queue.length >= 2) {
        var u1 = queue.removeAt(0);
        var u2 = queue.removeAt(0);

        print('매칭 성공! 연결 시작');
        var initMsg = jsonEncode({'type': 'init', 'message': 'connected'});
        u1.add(initMsg); u2.add(initMsg);

        // 상호 전달 로직
        u1.listen((data) => u2.add(data), onDone: () => u2.close());
        u2.listen((data) => u1.add(data), onDone: () => u1.close());
      }
    }
  });
}