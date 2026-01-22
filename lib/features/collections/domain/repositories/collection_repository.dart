import '../entities/collection.dart';

abstract class CollectionRepository {
  Future<List<Collection>> getCollections({required String userId});

  Future<Collection> createCollection({
    required String userId,
    required String name,
    String? initialQuoteId,
  });

  Future<void> updateCollectionName({
    required String userId,
    required String collectionId,
    required String name,
  });

  Future<void> deleteCollection({
    required String userId,
    required String collectionId,
  });

  Future<void> setQuoteInCollection({
    required String userId,
    required String collectionId,
    required String quoteId,
    required bool shouldAdd,
  });
}
