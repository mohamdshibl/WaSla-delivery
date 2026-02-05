import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String senderId,
    required String content,
  }) {
    return repository.sendMessage(
      orderId: orderId,
      senderId: senderId,
      content: content,
    );
  }
}
