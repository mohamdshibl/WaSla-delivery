import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.orderId,
    required super.senderId,
    required super.content,
    required super.timestamp,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'orderId': orderId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
