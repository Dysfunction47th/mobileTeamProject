import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:logger/logger.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mobile_team_project/backend/config/securityData.dart';
import 'package:mobile_team_project/backend/login/kakao_login.dart';
import 'package:mobile_team_project/front/onboarding_screen.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // env 로드
  await dotenv.load(fileName: "securityData.env");

  // 카카오 로그인 초기화
  KakaoSdk.init(
    // env를 활용해 securityData.dart에서 네이키브 키값 가져옴
    nativeAppKey: Env.KAKAO_API_KEY,


    // javaScriptAppKey: '${YOUR_JAVASCRIPT_APP_KEY}',
  );
  print("3");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text('You have pushed the button this many times:'),

            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              // 로그인 버튼
              onPressed: () async {
                await loginWithKakao(context);
                // loginWithKakao() 함수가 끝날 때까지 기다렸다가 다음 코드를 실행
              },
              child: const Text('카카오 로그인'),
            ),



          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}


//이거 어디에다가 넣지 simplechatapp을 만드시라는 건가용?
//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () async {
//                 // 선배님 로직 그대로 실행: 성공 시 OnboardingScreen으로 자동 이동함
//                 await loginWithKakao(context);
//               },
//               child: const Text('카카오 로그인'),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
//
// // SimpleChatApp은 OnboardingScreen에서 호출될 것이므로 여기에 정의만 해둡니다.
// class SimpleChatApp extends StatefulWidget {
//   final KakaoUser user; // 선배님이 정의한 KakaoUser 타입을 사용합니다.
//
//   const SimpleChatApp({super.key, required this.user});
//
//   @override
//   State<SimpleChatApp> createState() => _SimpleChatAppState();
// }
//
// class _SimpleChatAppState extends State<SimpleChatApp> {
//   final SocketManager _sm = SocketManager();
//   final TextEditingController _tc = TextEditingController();
//   List<String> chatLog = [];
//   bool matched = false;
//
//   void onStart() async { //매칭 시작
//     final stream = await _sm.connect(); //
//     stream?.listen((data) { //서버에서 정보 오는지 패킷 감지
//       final decoded = jsonDecode(data);
//       setState(() {
//         if (decoded['type'] == 'init') { //서버 대기열 2명 모이면 넘어감
//           matched = true; //얘를 통해서
//         } else if (decoded['type'] == 'msg') { //상대방이 보낸 메세지, json 내부의 sender정보확인 후
//           String senderNick = decoded['sender']?['nickname'] ?? "상대방"; //닉네임과 메시지 화면출력
//           chatLog.add("$senderNick: ${decoded['message']}");
//         }
//       });
//     }, onError: (e) => print("스트림 에러: $e"));
//   }
//
//   void onSend() { //전송 버튼 누를 시
//     if (_tc.text.isNotEmpty) {
//       final msgStr = jsonEncode({
//         'type': 'msg',
//         'message': _tc.text,
//         'sender': {
//           'nickname': widget.user.nickname,
//           'gender': widget.user.gender,
//           'age': widget.user.ageRange,
//         }
//       });
//
//       _sm.send(msgStr);
//       setState(() {
//         chatLog.add("나: ${_tc.text}");
//         _tc.clear();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) { //매칭시작 버튼
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(matched ? "1:1 채팅 중" : "매칭 시스템"),
//         backgroundColor: matched ? Colors.blue : Colors.grey,
//       ),
//       body: !matched
//           ? Center(
//         child: ElevatedButton(
//           onPressed: onStart,
//           child: const Text("매칭 시작 (서버 접속)"),
//         ),
//       )
//           : Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: chatLog.length,
//               itemBuilder: (context, i) => ListTile(title: Text(chatLog[i])),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 Expanded(child: TextField(controller: _tc)),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: onSend,
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }


