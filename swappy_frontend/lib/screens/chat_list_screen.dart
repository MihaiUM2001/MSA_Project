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
      appBar: AppBar(
        title: Text("Chats", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
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
            return Center(
              child: Text(
                "No chats yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            );
          }

          final chats = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final lastMessage = chat['lastMessage'] ?? "No messages yet";
              final timestamp = chat['lastMessageTime'] as Timestamp?;
              final formattedTime = timestamp != null
                  ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
                  : '';

              final participants = List<int>.from(chat['participants']);
              final otherUserId = participants.firstWhere((id) => id.toString() != _userId);

              return FutureBuilder<Map<String, dynamic>>(
                future: _userService.getUserDetails(otherUserId.toString()),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return SizedBox.shrink();

                  final otherUser = userSnapshot.data!;
                  final otherUserName = otherUser['fullName'] ?? "Unknown User";
                  final profilePicUrl = otherUser['profilePictureURL'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(chatRoomId: chat.id, userId: _userId!),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: profilePicUrl != null
                                ? NetworkImage(profilePicUrl)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: profilePicUrl == null
                                ? Icon(Icons.person, color: Colors.white, size: 30)
                                : null,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherUserName,
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          if (formattedTime.isNotEmpty)
                            Text(
                              formattedTime,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
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
