import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Added intl import
import '../viewmodel/chat_provider.dart';
import '../viewmodel/auth_provider.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatRoomScreen({super.key, required this.roomId});
  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) ref.read(chatNotifierProvider.notifier).setTypingStatus(widget.roomId, _focusNode.hasFocus);
    });
  }

  @override
  void dispose() { _messageController.dispose(); _focusNode.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.roomId));
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    final myId = ref.watch(authProvider).user?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: chatRoomsAsync.when(
        data: (rooms) {
          final room = rooms.firstWhere((r) => r.id == widget.roomId);
          final otherId = room.participantIds.firstWhere((id) => id != myId, orElse: () => '');
          final otherInfo = room.participantInfo[otherId] ?? {'name': 'Candidate'};
          final isTyping = ref.watch(typingStatusProvider("${widget.roomId}_$otherId")).value ?? false;

          return AppBar(
            backgroundColor: Colors.white, elevation: 1,
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(otherInfo['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(isTyping ? 'typing...' : 'Online', style: TextStyle(fontSize: 12, color: isTyping ? Colors.blue : Colors.green)),
            ]),
          );
        },
        loading: () => AppBar(),
        error: (_, __) => AppBar(),
      ),
      body: Column(children: [
        Expanded(child: messagesAsync.when(
          data: (list) => ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (ctx, i) => _ChatBubble(message: list[i], isMe: list[i].senderId == myId),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        )),
        _buildInputArea(myId),
      ]),
    );
  }

  Widget _buildInputArea(String myId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(children: [
        Expanded(child: TextFormField(controller: _messageController, focusNode: _focusNode, decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none))),
        IconButton(icon: const Icon(Icons.send, color: Color(0xFF1565C0)), onPressed: () {
          if (_messageController.text.trim().isEmpty) return;
          // Logic to identify receiverId from room and send...
          _messageController.clear();
        }),
      ]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final dynamic message; final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});
  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);
    return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12), margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: isMe ? const Color(0xFF1565C0) : Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Text(message.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
        ),
        Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.black38)),
      ],
    ));
  }
}

