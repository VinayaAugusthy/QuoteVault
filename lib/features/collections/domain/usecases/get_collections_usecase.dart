import '../entities/collection.dart';
import '../repositories/collection_repository.dart';

class GetCollectionsUseCase {
  final CollectionRepository repository;

  GetCollectionsUseCase(this.repository);

  Future<List<Collection>> call({required String userId}) {
    return repository.getCollections(userId: userId);
  }
}
