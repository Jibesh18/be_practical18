import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/chat_provider.dart';
import '../viewmodel/auth_provider.dart';
import '../model/message.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    final primaryColor = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Conversations', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: chatRoomsAsync.when(
        data: (rooms) => rooms.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: rooms.length,
                itemBuilder: (ctx, i) => _ChatRoomTile(room: rooms[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Messaging Sync Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No messages yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text('Your professional conversations will appear here once a connection is made.', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.black38)),
          ),
        ],
      ),
    );
  }
}

class _ChatRoomTile extends ConsumerWidget {
  final ChatRoom room;
  const _ChatRoomTile({required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(authProvider).user?.id ?? '';
    final otherId = room.participantIds.firstWhere((id) => id != myId, orElse: () => '');
    
    // Get info for the other participant (could be student info or company info)
    final otherInfo = room.participantInfo[otherId] ?? {'name': 'User', 'avatar': '👤'};
    final unreadCount = room.unreadCounts[myId] ?? 0;
    final timeStr = DateFormat('hh:mm a').format(room.lastMessageTime);

    return ListTile(
      onTap: () => context.push('/chat/${room.id}'),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
        child: Text(otherInfo['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
      ),
      title: Text(otherInfo['name'], style: TextStyle(fontWeight: unreadCount > 0 ? FontWeight.w900 : FontWeight.w700, fontSize: 16)),
      subtitle: Text(
        room.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: unreadCount > 0 ? Colors.black87 : Colors.black45, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeStr, style: TextStyle(fontSize: 11, color: unreadCount > 0 ? const Color(0xFF1565C0) : Colors.black38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(10)),
              child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

