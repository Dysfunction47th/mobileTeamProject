import 'dart:io';
import 'dart:convert';

// 대기열 유저 구조체 (소켓 + 가공된 유저 프로필 정보 통합)
class WaitingUser {
  final WebSocket socket;
  final String myGender;
  final String targetGender;
  final List<String> targetYears;
  final String targetDept;
  final Map<String, dynamic> myProfile; // 진짜 카카오/프로필 데이터

  WaitingUser({
    required this.socket,
    required this.myGender,
    required this.targetGender,
    required this.targetYears,
    required this.targetDept,
    required this.myProfile,
  });
}

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 4001);
  print('🚀 [1:1 카카오 연동 맞춤형 필터 매칭 서버 가동] ws://0.0.0.0:4001');

  List<WaitingUser> queue = [];

  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);

      // 접속 시마다 죽은 세션(찌꺼기) 정리
      queue.removeWhere((user) => user.socket.readyState != WebSocket.open);

      socket.listen((data) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(data.toString());

          // 1. 매칭 시작 요청 수신
          if (decoded['type'] == 'match_start') {
            final filter = decoded['filter'] ?? {};
            final myProfile = decoded['myProfile'] ?? {};

            final targetGender = filter['gender'] ?? '여성';
            final List<String> targetYears = List<String>.from(filter['years'] ?? []);
            final targetDept = filter['department'] ?? '전체 학과';
            final myGender = myProfile['gender'] ?? '남성';

            final newUser = WaitingUser(
              socket: socket,
              myGender: myGender,
              targetGender: targetGender,
              targetYears: targetYears,
              targetDept: targetDept,
              myProfile: myProfile,
            );

            queue.add(newUser);
            print('🔔 대기자 등록 ➔ 닉네임: ${myProfile['nickname']}, 학과: ${myProfile['department']}');

            // 2. 조건 매칭 알고리즘 가동
            _tryMatchMatchingUsers(queue);
          }

          // 3. 매칭 취소 요청 수신
          if (decoded['type'] == 'match_cancel') {
            queue.removeWhere((user) => user.socket == socket);
            print('👋 매칭 취소 처리 완료. 현재 대기열: ${queue.length}명');
          }

        } catch (e) {
          // 일반 대화 'msg' 패킷은 이 catch 블록을 타며 하단의 파이프라인으로 정상 중계됩니다.
        }
      }, onDone: () {
        queue.removeWhere((user) => user.socket == socket);
      });
    }
  });
}

void _tryMatchMatchingUsers(List<WaitingUser> queue) {
  if (queue.length < 2) return;

  for (int i = 0; i < queue.length; i++) {
    for (int j = i + 1; j < queue.length; j++) {
      WaitingUser u1 = queue[i];
      WaitingUser u2 = queue[j];

      // 조건 A: 성별 교차 매칭 검증
      bool genderMatch = (u1.targetGender == u2.myGender) && (u2.targetGender == u1.myGender);

      // 조건 B: 학년 매칭 (기본 프리패스, 필요시 확장)
      bool yearMatch = true;

      // 조건 C: 학과 조건 검증 (상대방 진짜 학과 프로필과 대조)
      bool deptMatch = (u1.targetDept == '전체 학과' || u1.targetDept == u2.myProfile['department']) &&
          (u2.targetDept == '전체 학과' || u2.targetDept == u1.myProfile['department']);

      if (genderMatch && yearMatch && deptMatch) {
        print('🎯 [매칭 성사] ${u1.myProfile['nickname']} 🤝 ${u2.myProfile['nickname']}');

        queue.remove(u1);
        queue.remove(u2);

        // 🔴 하드코딩 완전 삭제: 카카오에서 불러온 진짜 프로필을 서로 크로스로 교환 발송
        var u1Signal = jsonEncode({
          'type': 'match_start',
          'sender': u2.myProfile
        });
        var u2Signal = jsonEncode({
          'type': 'match_start',
          'sender': u1.myProfile
        });

        u1.socket.add(u1Signal);
        u2.socket.add(u2Signal);

        // 🔄 1:1 채팅 리슨 파이프라인 형성
        u1.socket.listen((data) => u2.socket.add(data), onDone: () => u2.socket.close());
        u2.socket.listen((data) => u1.socket.add(data), onDone: () => u1.socket.close());

        return;
      }
    }
  }
}