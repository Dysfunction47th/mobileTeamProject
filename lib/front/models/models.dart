class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class ChatRoom {
  final String id;
  final String nickname;
  final String lastMessage;
  final String time;
  final int unread;
  final String emoji;

  const ChatRoom({
    required this.id,
    required this.nickname,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.emoji = '👤',
  });
}
