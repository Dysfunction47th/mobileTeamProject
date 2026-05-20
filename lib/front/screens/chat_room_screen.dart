import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_team_project/front/models/models.dart';
import 'package:mobile_team_project/backend/socket/socket.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom room;
  const ChatRoomScreen({super.key, required this.room});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<ChatMessage> _messages = [];

  String _opponentNickname = '연결 중...';
  String _opponentEmoji = '👤';

  @override
  void initState() {
    super.initState();
    _opponentNickname = widget.room.nickname;
    _opponentEmoji = widget.room.emoji;
    _listenSocket();
  }

  void _listenSocket() async {
    final socketManager = SocketManager();
    final stream = await socketManager.connect();

    stream?.listen((data) {
      try {
        Map<String, dynamic> decoded;
        if (data is List<int>) {
          decoded = jsonDecode(utf8.decode(data));
        } else {
          decoded = jsonDecode(data.toString());
        }

        if (decoded['type'] == 'msg') {
          final text = decoded['message'] ?? '';
          final senderData = decoded['sender'] ?? {};
          final nickname = senderData['nickname'] ?? '익명 상대방';
          final gender = senderData['gender'] ?? '미지정'; // 성별 데이터 유연하게 확보

          final myNickname = UserData.user?.nickname ?? "익명";

          print("📥 [소켓 패킷 수신] 보낸이: $nickname, 나: $myNickname, 내용: $text");

          // 🔴 성별 조건에 관계없이 "내가 보낸 게 아니라면" 무조건 화면에 렌더링하도록 락 해제
          if (nickname != myNickname && nickname != "나") {
            setState(() {
              _opponentNickname = nickname;
              // 노트북영희가 '남성'으로 들어와도 깨지지 않게 이모지 다중 매핑 처리
              _opponentEmoji = (gender.contains('female') || gender == '여성' || nickname.contains('영희')) ? '🌸' : '⭐';

              _messages.add(ChatMessage(
                text: text,
                isMe: false,
                time: _nowTime(),
              ));
            });
            _animateToBottom();
          }
        }
      } catch (e) {
        print("⚠️ 채팅방 리스너 에러: $e");
      }
    });
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    final user = UserData.user;
    final myNickname = user?.nickname ?? "익명";

    final msgPacket = {
      'type': 'msg',
      'message': text,
      'sender': {
        'nickname': myNickname,
        'gender': user?.gender ?? "미지정",
        'age': user?.ageRange ?? "알 수 없음",
      }
    };

    SocketManager().send(jsonEncode(msgPacket));

    setState(() {
      _messages.add(ChatMessage(
          text: text,
          isMe: true,
          time: _nowTime()
      ));
    });

    _inputCtrl.clear();
    _animateToBottom();
  }

  void _animateToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _nowTime() {
    final n = DateTime.now();
    final ampm = n.hour >= 12 ? '오후' : '오전';
    final h = n.hour > 12 ? n.hour - 12 : (n.hour == 0 ? 12 : n.hour);
    final m = n.minute.toString().padLeft(2, '0');
    return '$ampm $h:$m';
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('채팅 나가기', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text('채팅방을 나가면 대화 내용이 사라집니다.\n정말 나가시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Color(0xFFAAAAAA))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('나가기', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 키보드가 올라올 때 하단 패딩(뷰 인셋)을 자동으로 계산하여 UI를 위로 밀어 올려줍니다.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false, // 시스템이 임의로 찌그러뜨리는 현상 방지
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomInset), // 🔴 키보드 높이만큼 정확하게 패딩 주입
        child: Column(
          children: [
            _buildDateDivider('오늘'),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                child: Text(
                  '매칭된 상대방과 대화를 시작해보세요!',
                  style: TextStyle(color: Color(0xFFCC99AA), fontSize: 13.5),
                ),
              )
                  : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _buildBubble(_messages[i]),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFFF6B9D), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: Color(0xFFFFD6E7), shape: BoxShape.circle),
            child: Center(child: Text(_opponentEmoji, style: const TextStyle(fontSize: 15))),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_opponentNickname, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  const Text('대화 중', style: TextStyle(fontSize: 10, color: Color(0xFF4CAF50))),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton.icon(
            onPressed: _showExitDialog,
            icon: const Icon(Icons.exit_to_app_rounded, size: 18, color: Color(0xFFFF6B9D)),
            label: const Text('나가기', style: TextStyle(color: Color(0xFFFF6B9D), fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF0F0F0)),
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFEECCD8))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFFCC99AA))),
          ),
          const Expanded(child: Divider(color: Color(0xFFEECCD8))),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isMe = msg.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: Color(0xFFFFCCDD), shape: BoxShape.circle),
              child: Center(child: Text(_opponentEmoji, style: const TextStyle(fontSize: 15))),
            ),
            const SizedBox(width: 6),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 3),
                  child: Text(_opponentNickname, style: const TextStyle(fontSize: 11, color: Color(0xFFAA7788), fontWeight: FontWeight.w500)),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      child: Text(msg.time, style: const TextStyle(fontSize: 10, color: Color(0xFFBBAAB0))),
                    ),
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.62),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFF6B9D) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 3),
                        bottomRight: Radius.circular(isMe ? 3 : 18),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 5, offset: const Offset(0, 2))],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(fontSize: 14.5, color: isMe ? Colors.white : const Color(0xFF2D2D2D), height: 1.4),
                    ),
                  ),
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(msg.time, style: const TextStyle(fontSize: 10, color: Color(0xFFBBAAB0))),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: const TextStyle(fontSize: 14.5),
              decoration: InputDecoration(
                hintText: '메시지 입력',
                hintStyle: const TextStyle(color: Color(0xFFCCBBCC), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFFFF0F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: Color(0xFFFFAACC), width: 1)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFFF6B9D).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}