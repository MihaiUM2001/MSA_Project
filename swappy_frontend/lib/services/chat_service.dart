import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a chat room when a swap is confirmed
  Future<void> createChatRoom(String chatRoomId, String buyerId, String sellerId) async {
    DocumentReference chatRef = _firestore.collection('chats').doc(chatRoomId);

    // Check if chat already exists
    DocumentSnapshot chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      await chatRef.set({
        'buyerId': buyerId,
        'sellerId': sellerId,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Sends a message in the chat
  Future<void> sendMessage(String chatRoomId, String senderId, String message) async {
    await _firestore.collection('chats').doc(chatRoomId).collection('messages').add({
      'senderId': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message in chat metadata
    await _firestore.collection('chats').doc(chatRoomId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches chat messages
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore.collection('chats').doc(chatRoomId).collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Fetches all chat rooms for a user
  Stream<QuerySnapshot> getUserChats(String userId) {
    print("Fetching chats for user: $userId");

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: int.parse(userId)) // ✅ Use arrayContains
        .orderBy('lastMessageTime', descending: true) // ✅ Order properly
        .snapshots();
  }
}
