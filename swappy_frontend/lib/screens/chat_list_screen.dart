import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userProfile = await _userService.getUserProfile();
    setState(() {
      _userId = userProfile['id'].toString();
      print("User ID from backend: $_userId");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getUserChats(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading chats"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No chats yet"));
          }

          final chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final lastMessage = chat['lastMessage'] ?? "No messages yet";
              final participants = List<int>.from(chat['participants']);
              final otherUserId = participants.firstWhere((id) => id.toString() != _userId);

              print("Chat found: ${chat.id} with $otherUserId");

              return ListTile(
                title: Text("Chat with User $otherUserId"),
                subtitle: Text(lastMessage),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatRoomId: chat.id, userId: _userId!),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
