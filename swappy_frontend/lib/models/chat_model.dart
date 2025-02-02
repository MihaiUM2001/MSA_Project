import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String messageId;
  String senderId;
  String receiverId;
  String message;
  Timestamp timestamp;
  String status; // "sent", "delivered", "read"

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.status,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ChatMessage(
      messageId: doc.id,
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      message: data['message'],
      timestamp: data['timestamp'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "timestamp": timestamp,
      "status": status,
    };
  }
}
