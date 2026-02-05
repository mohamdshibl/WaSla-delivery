import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String orderId) {
    return repository.getMessages(orderId);
  }
}
