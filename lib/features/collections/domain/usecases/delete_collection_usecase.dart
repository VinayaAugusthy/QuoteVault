import '../repositories/collection_repository.dart';

class DeleteCollectionUseCase {
  final CollectionRepository repository;

  DeleteCollectionUseCase(this.repository);

  Future<void> call({required String userId, required String collectionId}) {
    return repository.deleteCollection(
      userId: userId,
      collectionId: collectionId,
    );
  }
}
