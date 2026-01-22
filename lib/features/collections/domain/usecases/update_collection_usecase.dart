import '../repositories/collection_repository.dart';

class UpdateCollectionUseCase {
  final CollectionRepository repository;

  UpdateCollectionUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String collectionId,
    required String name,
  }) {
    return repository.updateCollectionName(
      userId: userId,
      collectionId: collectionId,
      name: name,
    );
  }
}
