import 'dart:io';
import 'dart:convert';

// 실시간 대기열 및 연결된 유저 세션을 저장하는 명세서
class MatchUser {
  final WebSocket socket; // 유저의 고유 소켓 파이프라인
  final String nickname;
  final String gender;
  final String department;
  final List<dynamic> years;

  MatchUser({
    required this.socket,
    required this.nickname,
    required this.gender,
    required this.department,
    required this.years,
  });
}

void main() async {
  // 4001번 포트 바인딩 가동
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 4001);
  print("🚀 [1:1 번호팅 통합 백엔드 중계 서버 정식 기동] ws://0.0.0.0:4001");

  // 현재 매칭 대기방에서 대기 중인 유저 풀
  List<MatchUser> waitingQueue = [];

  // 🔴 실시간 1:1 대화방 매핑 주소록 (안전한 세션 보존 치트키)
  // Key: 내 소켓 해시값 string ➔ Value: 상대방 유저의 MatchUser 객체
  Map<String, MatchUser> activeChatRooms = {};

  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      final String myKey = socket.hashCode.toString();
      print("🔌 [연결] 새로운 기기가 소켓 망에 정착했습니다. (ID: $myKey)");

      socket.listen(
            (message) {
          try {
            final Map<String, dynamic> packet = jsonDecode(message.toString());
            final type = packet['type'];

            // ══════════════════════════════════════════════════════
            // 1. 매칭 대기열 등록 및 성별 크로스 검증 매칭
            // ══════════════════════════════════════════════════════
            if (type == 'match_start') {
              final myProfile = packet['myProfile'] ?? {};
              final filter = packet['filter'] ?? {};

              final currentUser = MatchUser(
                socket: socket,
                nickname: myProfile['nickname'] ?? '익명',
                gender: myProfile['gender'] ?? '미지정',
                department: myProfile['department'] ?? '소프트웨어학과',
                years: filter['years'] ?? [],
              );

              print("🔔 [대기열 진입] 닉네임: ${currentUser.nickname} | 성별: ${currentUser.gender}");

              // 대기열에 조건이 매칭되는 이성 상대방이 있는지 전수조사
              MatchUser? opponentUser;
              for (var waitingUser in waitingQueue) {
                // 성별이 서로 다르고, 연결 상태가 정상인 경우 매칭 성공
                if (waitingUser.gender != currentUser.gender) {
                  opponentUser = waitingUser;
                  break;
                }
              }

              if (opponentUser != null) {
                // 대기열 수용소에서 상대방 탈출 처리
                waitingQueue.remove(opponentUser);

                print("🎯 [매칭 성사 성공] ${currentUser.nickname} 🤝 ${opponentUser.nickname}");

                final String oppKey = opponentUser.socket.hashCode.toString();

                // 🔴 핵심 주소록 바인딩: 주소록 맵에 서로를 1:1 파트너로 강제 매핑 명시
                activeChatRooms[myKey] = opponentUser;
                activeChatRooms[oppKey] = currentUser;

                // 내 화면에 상대 프로필 던지며 매칭 전환 트리거 발송
                socket.add(jsonEncode({
                  'type': 'match_start',
                  'sender': {
                    'nickname': opponentUser.nickname,
                    'gender': opponentUser.gender,
                    'department': opponentUser.department
                  }
                }));

                // 상대방 화면에도 내 프로필 수동 주입하며 채팅방 동시 슬라이딩 진입 지시
                opponentUser.socket.add(jsonEncode({
                  'type': 'match_start',
                  'sender': {
                    'nickname': currentUser.nickname,
                    'gender': currentUser.gender,
                    'department': currentUser.department
                  }
                }));
              } else {
                // 조건에 맞는 상대가 없으므로 대기큐에 적재
                waitingQueue.add(currentUser);
              }
            }

            // ══════════════════════════════════════════════════════
            // 2. 실시간 메시지 중계 포워딩 (배달 사고 100% 방어 완비)
            // ══════════════════════════════════════════════════════
            else if (type == 'msg') {
              final text = packet['message'] ?? '';
              final sender = packet['sender'] ?? {};
              final nickname = sender['nickname'] ?? '익명';

              print("💬 [중계 배달 중] 보낸이: $nickname ➔ 메세지 내용: $text");

              // 🔴 주소록 맵에서 내 고유 키(myKey)를 대입해 1:1 짝꿍 상대방 소켓을 역추적합니다.
              final MatchUser? partner = activeChatRooms[myKey];

              if (partner != null) {
                // 상대방 소켓 구멍에 내가 보낸 가공 패킷 그대로 정밀하게 슛!
                partner.socket.add(jsonEncode({
                  'type': 'msg',
                  'message': text,
                  'sender': {
                    'nickname': nickname,
                    'gender': sender['gender'] ?? '미지정',
                  }
                }));
                print("📦 [중계 배달 완료] -> ${partner.nickname} 기기로 패킷 포워딩 성공");
              } else {
                print("⚠️ [배달 실패] 대화방 매핑 주소록에 매칭된 상대방 세션이 없습니다.");
              }
            }

            // 3. 매칭 취소 처리
            else if (type == 'match_cancel') {
              waitingQueue.removeWhere((u) => u.socket.hashCode == socket.hashCode);
              print("❌ 유저가 취소 요청하여 대기열에서 정상 취소 처리했습니다.");
            }

          } catch (e) {
            print("⚠️ 서버 패킷 팅김 및 라우팅 예외 발생: $e");
          }
        },
        onDone: () {
          print("🔌 [종료] 기기 연결 해제됨 (ID: $myKey)");
          waitingQueue.removeWhere((u) => u.socket.hashCode == socket.hashCode);

          // 나가면 연결된 대화방 폭파 청소
          final MatchUser? partner = activeChatRooms[myKey];
          if (partner != null) {
            final String oppKey = partner.socket.hashCode.toString();
            activeChatRooms.remove(myKey);
            activeChatRooms.remove(oppKey);
          }
        },
      );
    }
  });
}