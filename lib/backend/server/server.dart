import 'dart:io';
import 'dart:convert';

class MatchUser {
  final WebSocket socket;
  final String nickname;
  final String gender;
  final List<dynamic> years;

  MatchUser({
    required this.socket,
    required this.nickname,
    required this.gender,
    required this.years,
  });
}

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 4001);
  print("🚀 [서버 가동] 1:1 매칭 서버 대기 중... (포트: 4001)");

  List<MatchUser> waitingQueue = [];
  Map<String, MatchUser> activeChatRooms = {};

  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      final String myKey = socket.hashCode.toString();
      print("🔌 [연결] 유저 접속 (ID: $myKey)");

      socket.listen(
            (message) {
          try {
            final Map<String, dynamic> packet = jsonDecode(message.toString());
            final type = packet['type'];

            if (type == 'match_start') {
              final myProfile = packet['myProfile'] ?? {};
              final filter = packet['filter'] ?? {};

              final currentUser = MatchUser(
                socket: socket,
                nickname: myProfile['nickname'] ?? '익명',
                gender: myProfile['gender'] ?? '미지정',
                years: filter['years'] ?? [],
              );

              print("🔔 [대기열] ${currentUser.nickname}(${currentUser.gender}) 입장");

              MatchUser? opponentUser;
              for (var waitingUser in waitingQueue) {
                if (waitingUser.gender != currentUser.gender) {
                  opponentUser = waitingUser;
                  break;
                }
              }

              if (opponentUser != null) {
                waitingQueue.remove(opponentUser);
                print("🎯 [매칭 성공] ${currentUser.nickname} 🤝 ${opponentUser.nickname}");

                final String oppKey = opponentUser.socket.hashCode.toString();
                activeChatRooms[myKey] = opponentUser;
                activeChatRooms[oppKey] = currentUser;

                socket.add(jsonEncode({'type': 'match_start', 'sender': {'nickname': opponentUser.nickname}}));
                opponentUser.socket.add(jsonEncode({'type': 'match_start', 'sender': {'nickname': currentUser.nickname}}));
              } else {
                waitingQueue.add(currentUser);
              }
            } else if (type == 'msg') {
              final MatchUser? partner = activeChatRooms[myKey];
              if (partner != null) {
                partner.socket.add(jsonEncode({
                  'type': 'msg',
                  'message': packet['message'],
                  'sender': {'nickname': packet['sender']['nickname']}
                }));
              }
            } else if (type == 'match_cancel') {
              waitingQueue.removeWhere((u) => u.socket.hashCode == socket.hashCode);
              print("❌ 매칭 취소됨");
            }
          } catch (e) {
            print("⚠️ 에러 발생: $e");
          }
        },
        onDone: () {
          print("🔌 [종료] 연결 해제 (ID: $myKey)");
          waitingQueue.removeWhere((u) => u.socket.hashCode == socket.hashCode);
          activeChatRooms.remove(myKey);
        },
      );
    }
  });
}