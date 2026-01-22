import '../entities/collection.dart';
import '../repositories/collection_repository.dart';

class CreateCollectionUseCase {
  final CollectionRepository repository;

  CreateCollectionUseCase(this.repository);

  Future<Collection> call({
    required String userId,
    required String name,
    String? initialQuoteId,
  }) {
    return repository.createCollection(
      userId: userId,
      name: name,
      initialQuoteId: initialQuoteId,
    );
  }
}
