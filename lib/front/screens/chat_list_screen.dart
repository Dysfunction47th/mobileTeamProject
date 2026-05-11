import 'package:flutter/material.dart';
import 'package:mobile_team_project/front/models/models.dart';
import 'package:mobile_team_project/front/screens/chat_room_screen.dart';

// ══════════════════════════════════════════════════════
//  채팅 탭 — 채팅방 목록
// ══════════════════════════════════════════════════════
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // 더미 채팅방 목록 (실제 연동 시 서버에서 가져옴)
  final List<ChatRoom> _rooms = [
    const ChatRoom(
      id: '1',
      nickname: '익명 🌸',
      lastMessage: '안녕하세요! 반갑습니다 😊',
      time: '방금',
      unread: 2,
      emoji: '🌸',
    ),
    const ChatRoom(
      id: '2',
      nickname: '익명 🌙',
      lastMessage: '어떤 학과 다니세요?',
      time: '5분 전',
      unread: 0,
      emoji: '🌙',
    ),
    const ChatRoom(
      id: '3',
      nickname: '익명 ⭐',
      lastMessage: '오늘 날씨 진짜 좋네요',
      time: '1시간 전',
      unread: 1,
      emoji: '⭐',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_rooms.isEmpty) {
      return _buildEmpty();
    }
    return Container(
      color: const Color(0xFFFFF8FB),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _rooms.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 72,
          endIndent: 20,
          color: Color(0xFFF5E8EE),
        ),
        itemBuilder: (context, index) {
          return _buildChatRoomTile(_rooms[index]);
        },
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom room) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(room: room),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 아바타
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE4EF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    Text(room.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            // 닉네임 + 마지막 메시지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.nickname,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    room.lastMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 시간 + 안읽은 수
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  room.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
                const SizedBox(height: 4),
                if (room.unread > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B9D),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${room.unread}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      color: const Color(0xFFFFF0F5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💬', style: TextStyle(fontSize: 52)),
            SizedBox(height: 16),
            Text(
              '아직 채팅방이 없어요',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),
            SizedBox(height: 6),
            Text(
              '매칭 탭에서 상대방과 연결해보세요!',
              style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }
}
