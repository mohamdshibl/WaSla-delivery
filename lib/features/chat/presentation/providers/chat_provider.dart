import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/message_entity.dart';

// --- Dependencies ---
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(firestore: ref.read(firestoreProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.read(chatRemoteDataSourceProvider));
});

// --- UseCases ---
final sendMessageUseCaseProvider = Provider((ref) {
  return SendMessageUseCase(ref.read(chatRepositoryProvider));
});

final getMessagesUseCaseProvider = Provider((ref) {
  return GetMessagesUseCase(ref.read(chatRepositoryProvider));
});

// --- State ---
final chatMessagesProvider = StreamProvider.family<List<MessageEntity>, String>(
  (ref, orderId) {
    final getMessages = ref.read(getMessagesUseCaseProvider);

    return getMessages(orderId).map((event) {
      return event.fold((failure) => [], (messages) => messages);
    });
  },
);
