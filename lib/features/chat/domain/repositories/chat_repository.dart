import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> sendMessage({
    required String orderId,
    required String senderId,
    required String content,
  });

  Stream<Either<Failure, List<MessageEntity>>> getMessages(String orderId);
}
