import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../services/swap_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String userId;

  const ChatScreen({Key? key, required this.chatRoomId, required this.userId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final SwapService _swapService = SwapService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _otherUser;
  Map<String, dynamic>? _swapDetails;
  bool _isLoading = true;
  bool _isPhoneVisible = false;

  final ValueNotifier<List<Map<String, dynamic>>> _messagesNotifier = ValueNotifier([]);
  List<Map<String, dynamic>> _cachedMessages = [];

  @override
  void initState() {
    super.initState();
    _loadChatData();
    _listenForMessages();
  }

  Future<void> _loadChatData() async {
    try {
      final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(widget.chatRoomId).get();
      if (chatDoc.exists && chatDoc.data() != null) {
        final data = chatDoc.data()!;
        final participants = List<int>.from(data['participants'] ?? []);
        final swapId = data['swapId'];

        String otherUserId = participants.firstWhere((id) => id.toString() != widget.userId).toString();

        final otherUserData = await _userService.getUserDetails(otherUserId);
        final swapData = await _swapService.fetchSwapById(swapId);

        if (mounted) {
          setState(() {
            _otherUser = otherUserData;
            _swapDetails = {
              "swapId": swapData.id,
              "productImage1": swapData.product.productImage ?? '',
              "productImage2": swapData.swapProductImage ?? '',
            };
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading chat data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _listenForMessages() {
    _chatService.getMessages(widget.chatRoomId).listen((newMessages) {
      _cachedMessages = newMessages;
      _messagesNotifier.value = List.from(_cachedMessages);
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final String messageText = _messageController.text.trim();
    final String senderId = widget.userId;

    _addTemporaryMessage(messageText, senderId);
    _messageController.clear();

    try {
      await _chatService.sendMessage(widget.chatRoomId, senderId, messageText);
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message. Try again.")),
      );
    }
  }

  void _addTemporaryMessage(String message, String senderId) {
    final tempMessage = {
      "messageId": DateTime.now().millisecondsSinceEpoch.toString(),
      "message": message,
      "senderId": senderId,
      "timestamp": Timestamp.now(),
      "isSending": true,
    };

    _cachedMessages.insert(0, tempMessage);
    _messagesNotifier.value = List.from(_cachedMessages);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Chat")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _otherUser == null
            ? Text("Chat")
            : Row(
          children: [
            CircleAvatar(
              backgroundImage: _otherUser!['profilePictureURL'] != null
                  ? NetworkImage(_otherUser!['profilePictureURL'])
                  : null,
              backgroundColor: Colors.grey,
              child: _otherUser!['profilePictureURL'] == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10),
            Text(_otherUser!['fullName']),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_swapDetails != null) _buildSwapDetails(_swapDetails!),
          Expanded(child: _buildMessages()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildSwapDetails(Map<String, dynamic> swapDetails) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(swapDetails["productImage1"], width: 50, height: 50, fit: BoxFit.cover),
          Icon(Icons.swap_horiz, size: 30, color: Colors.blue),
          Image.network(swapDetails["productImage2"], width: 50, height: 50, fit: BoxFit.cover),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _messagesNotifier,
      builder: (context, messages, _) {
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final bool isMe = message['senderId'].toString() == widget.userId;
            return _buildChatBubble(message, isMe);
          },
        );
      },
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message, bool isMe) {
    final timestamp = (message['timestamp'] != null && message['timestamp'] is Timestamp)
        ? (message['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[300] : Colors.grey[600],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message['message'], style: TextStyle(fontSize: 16, color: Colors.white)),
            SizedBox(height: 5),
            Text(formattedTime, style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(controller: _messageController),
          ),
          IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
