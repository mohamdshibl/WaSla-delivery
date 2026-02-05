import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String orderId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  const MessageEntity({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, orderId, senderId, content, timestamp];
}
