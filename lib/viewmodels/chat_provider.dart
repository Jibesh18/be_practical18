import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/message.dart';
import '../repo/chat_service.dart';

final chatServiceProvider = Provider((ref) => ChatService());

final chatRoomsProvider = StreamProvider<List<ChatRoom>>((ref) {
  return ref.watch(chatServiceProvider).streamChatRooms();
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, roomId) {
  return ref.watch(chatServiceProvider).streamMessages(roomId);
});

// Fixed: Using a stable String key for the family instead of a Map to avoid reference equality issues
final typingStatusProvider = StreamProvider.family<bool, String>((ref, roomAndUser) {
  final parts = roomAndUser.split('_');
  if (parts.length != 2) return Stream.value(false);
  return ref.watch(chatServiceProvider).streamTypingStatus(parts[0], parts[1]);
});

class ChatNotifier extends StateNotifier<bool> {
  final ChatService _service;
  ChatNotifier(this._service) : super(false);

  Future<void> sendMessage(String roomId, String receiverId, String content, {MessageType type = MessageType.text, String? fileName, String? fileUrl}) async {
    await _service.sendMessage(roomId, receiverId, content, type: type, fileName: fileName, fileUrl: fileUrl);
  }

  Future<void> markAsRead(String roomId) async {
    await _service.markAsRead(roomId);
  }

  Future<void> setTypingStatus(String roomId, bool isTyping) async {
    await _service.setTypingStatus(roomId, isTyping);
  }

  Future<String> getOrCreateRoom(String otherId, Map<String, dynamic> otherInfo) async {
    return await _service.getOrCreateChatRoom(otherId, otherInfo);
  }
}

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, bool>((ref) {
  return ChatNotifier(ref.watch(chatServiceProvider));
});

