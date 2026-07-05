import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodel/chat_provider.dart';
import '../viewmodel/auth_provider.dart';
import '../model/message.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        ref.read(chatNotifierProvider.notifier).setTypingStatus(widget.roomId, _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String receiverId) {
    if (_messageController.text.trim().isEmpty) return;
    ref.read(chatNotifierProvider.notifier).sendMessage(
      widget.roomId, 
      receiverId, 
      _messageController.text.trim()
    );
    _messageController.clear();
  }

  Future<void> _showAttachmentOptions(String receiverId) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send Attachment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachBtn(Icons.image_rounded, 'Image', Colors.purple, () => _pickMedia(receiverId, true)),
                _attachBtn(Icons.insert_drive_file_rounded, 'Document', Colors.blue, () => _pickMedia(receiverId, false)),
                _attachBtn(Icons.description_rounded, 'Share Job', Colors.orange, () {}),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _attachBtn(IconData i, String l, Color c, VoidCallback onTap) => InkWell(
    onTap: () { Navigator.pop(context); onTap(); },
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircleAvatar(radius: 28, backgroundColor: c.withValues(alpha: 0.1), child: Icon(i, color: c)),
      const SizedBox(height: 8),
      Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    ]),
  );

  Future<void> _pickMedia(String receiverId, bool isImage) async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = isImage 
        ? await picker.pickImage(source: ImageSource.gallery)
        : await picker.pickMedia();
    
    if (media != null) {
      ref.read(chatNotifierProvider.notifier).sendMessage(
        widget.roomId, receiverId, isImage ? 'Sent an image' : 'Sent a document',
        type: isImage ? MessageType.image : MessageType.file,
        fileUrl: media.path,
        fileName: media.name,
      );
    }
  }

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
          
          // Fixed: Using stable String key for typing indicator provider
          final isTyping = ref.watch(typingStatusProvider("${widget.roomId}_$otherId")).value ?? false;

          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1), child: Text(otherInfo['name'][0])),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(otherInfo['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(isTyping ? 'typing...' : 'Online', 
                         style: TextStyle(fontSize: 12, color: isTyping ? Colors.blue : Colors.green, fontWeight: isTyping ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => AppBar(),
        error: (_, __) => AppBar(),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                Future.microtask(() => ref.read(chatNotifierProvider.notifier).markAsRead(widget.roomId));
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    return _ChatBubble(message: msg, isMe: msg.senderId == myId);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          _buildInputArea(messagesAsync),
        ],
      ),
    );
  }

  Widget _buildInputArea(AsyncValue<List<Message>> messagesAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1565C0)),
              onPressed: () {
                final msgs = messagesAsync.value;
                if (msgs != null && msgs.isNotEmpty) {
                  final receiverId = msgs.first.senderId == ref.read(authProvider).user?.id ? msgs.first.receiverId : msgs.first.senderId;
                  _showAttachmentOptions(receiverId);
                }
              },
            ),
            Expanded(
              child: TextFormField(
                controller: _messageController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) {
                  final msgs = messagesAsync.value;
                  if (msgs != null && msgs.isNotEmpty) {
                    final receiverId = msgs.first.senderId == ref.read(authProvider).user?.id ? msgs.first.receiverId : msgs.first.senderId;
                    _sendMessage(receiverId);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true, fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF1565C0),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  final msgs = messagesAsync.value;
                  if (msgs != null && msgs.isNotEmpty) {
                    final receiverId = msgs.first.senderId == ref.read(authProvider).user?.id ? msgs.first.receiverId : msgs.first.senderId;
                    _sendMessage(receiverId);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF1565C0) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0), bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              boxShadow: [if (!isMe) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.image)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(message.fileUrl ?? '', errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
                  )
                else if (message.type == MessageType.file)
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file, color: Colors.black45),
                      const SizedBox(width: 8),
                      Expanded(child: Text(message.fileName ?? 'Document', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline))),
                    ],
                  )
                else
                  Text(message.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(Icons.done_all_rounded, size: 12, color: message.isRead ? Colors.blue : Colors.black26),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

