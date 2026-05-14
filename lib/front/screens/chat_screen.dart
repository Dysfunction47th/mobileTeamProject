import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_team_project/backend/socket/socket.dart'; // 소켓 매니저 경로
import 'package:mobile_team_project/backend/user_data/user_model.dart'; // 수정된 모델 경로

//main에 있던 내용 여기로 옮김

class SimpleChatApp extends StatefulWidget {
  final KakaoUser user; // 수정된 KakaoUser 타입을 사용

  const SimpleChatApp({super.key, required this.user});

  @override
  State<SimpleChatApp> createState() => _SimpleChatAppState();
}

class _SimpleChatAppState extends State<SimpleChatApp> {
  final SocketManager _sm = SocketManager();
  final TextEditingController _tc = TextEditingController();
  List<String> chatLog = [];
  bool matched = false;

  void onStart() async {
    final stream = await _sm.connect();
    stream?.listen((data) {
      final decoded = jsonDecode(data);
      setState(() {
        if (decoded['type'] == 'init') {
          matched = true;
        } else if (decoded['type'] == 'msg') {
          String senderNick = decoded['sender']?['nickname'] ?? "상대방";
          chatLog.add("$senderNick: ${decoded['message']}");
        }
      });
    }, onError: (e) => print("스트림 에러: $e"));
  }

  void onSend() {
    if (_tc.text.isNotEmpty) {
      final msgStr = jsonEncode({
        'type': 'msg',
        'message': _tc.text,
        'sender': {
          'nickname': widget.user.nickname, // widget.user를 통해 접근
          'gender': widget.user.gender,
          'age': widget.user.ageRange,
        }
      });
      _sm.send(msgStr);
      setState(() {
        chatLog.add("나: ${_tc.text}");
        _tc.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(matched ? "1:1 채팅 중" : "매칭 시스템"),
        backgroundColor: matched ? Colors.blue : Colors.grey,
      ),
      body: !matched
          ? Center(
        child: ElevatedButton(
          onPressed: onStart,
          child: const Text("매칭 시작 (서버 접속)"),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatLog.length,
              itemBuilder: (context, i) => ListTile(title: Text(chatLog[i])),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _tc)),
                IconButton(icon: const Icon(Icons.send), onPressed: onSend),
              ],
            ),
          )
        ],
      ),
    );
  }
}