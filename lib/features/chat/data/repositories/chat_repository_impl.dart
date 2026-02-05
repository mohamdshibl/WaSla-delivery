import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String orderId) {
    return remoteDataSource
        .getMessages(orderId)
        .map((models) {
          return Right<Failure, List<MessageEntity>>(models);
        })
        .handleError((error) {
          return Left<Failure, List<MessageEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String orderId,
    required String senderId,
    required String content,
  }) async {
    try {
      await remoteDataSource.sendMessage(
        orderId: orderId,
        senderId: senderId,
        content: content,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
