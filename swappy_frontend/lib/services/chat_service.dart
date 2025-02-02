import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Store temporary messages before Firestore saves them
  final Map<String, List<Map<String, dynamic>>> _tempMessages = {};

  /// **Add temporary message to UI**
  void addLocalMessage(String chatRoomId, Map<String, dynamic> message) {
    _tempMessages.putIfAbsent(chatRoomId, () => []).add(message);
  }

  /// **Update temporary message status once Firestore confirms**
  void updateLocalMessageStatus(String chatRoomId, String tempId) {
    _tempMessages[chatRoomId]?.removeWhere((msg) => msg["messageId"] == tempId);
  }

  /// **Remove failed message from UI**
  void removeLocalMessage(String chatRoomId, String tempId) {
    _tempMessages[chatRoomId]?.removeWhere((msg) => msg["messageId"] == tempId);
  }

  /// **Get messages stream with local messages included**
  Stream<List<Map<String, dynamic>>> getMessages(String chatRoomId) {
    return _firestore
        .collection("chats")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> firestoreMessages = snapshot.docs
          .map((doc) => {"messageId": doc.id, ...doc.data()})
          .toList();

      // Merge Firestore messages with temporary unsent ones
      if (_tempMessages.containsKey(chatRoomId)) {
        firestoreMessages.insertAll(0, _tempMessages[chatRoomId]!);
      }

      return firestoreMessages;
    });
  }

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
