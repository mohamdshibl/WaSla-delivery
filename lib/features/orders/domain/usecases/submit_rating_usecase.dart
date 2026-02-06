import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class SubmitRatingUseCase {
  final OrdersRepository repository;

  SubmitRatingUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String providerId,
    required int rating,
    String? review,
  }) {
    return repository.submitRating(
      orderId: orderId,
      providerId: providerId,
      rating: rating,
      review: review,
    );
  }
}
