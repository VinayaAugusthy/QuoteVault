import '../repositories/collection_repository.dart';

class AddQuoteToCollectionUseCase {
  final CollectionRepository repository;

  AddQuoteToCollectionUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String collectionId,
    required String quoteId,
    required bool shouldAdd,
  }) {
    return repository.setQuoteInCollection(
      userId: userId,
      collectionId: collectionId,
      quoteId: quoteId,
      shouldAdd: shouldAdd,
    );
  }
}
