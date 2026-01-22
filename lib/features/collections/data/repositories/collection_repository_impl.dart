import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_remote_datasource.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionRemoteDataSource remoteDataSource;

  CollectionRepositoryImpl({required this.remoteDataSource});

  String _normalizeName(String name) => name.trim();

  @override
  Future<List<Collection>> getCollections({required String userId}) async {
    final collections = await remoteDataSource.fetchCollections(userId: userId);
    final items = await remoteDataSource.fetchCollectionItems(userId: userId);

    final quoteIdsByCollection = <String, List<String>>{};
    for (final row in items) {
      final cId = row['collection_id']?.toString();
      final qId = row['quote_id']?.toString();
      if (cId == null || qId == null) continue;
      (quoteIdsByCollection[cId] ??= <String>[]).add(qId);
    }

    return collections
        .map(
          (c) => c.copyWith(
            quoteIds: quoteIdsByCollection[c.id] ?? const <String>[],
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Collection> createCollection({
    required String userId,
    required String name,
    String? initialQuoteId,
  }) async {
    final normalized = _normalizeName(name);
    if (normalized.isEmpty) {
      throw ArgumentError('Collection name cannot be empty');
    }

    final created = await remoteDataSource.createCollection(
      userId: userId,
      name: normalized,
    );

    if (initialQuoteId != null) {
      await remoteDataSource.setQuoteInCollection(
        userId: userId,
        collectionId: created.id,
        quoteId: initialQuoteId,
        shouldAdd: true,
      );
      return created.copyWith(quoteIds: [initialQuoteId]);
    }

    return created;
  }

  @override
  Future<void> updateCollectionName({
    required String userId,
    required String collectionId,
    required String name,
  }) async {
    final normalized = _normalizeName(name);
    if (normalized.isEmpty) {
      throw ArgumentError('Collection name cannot be empty');
    }

    await remoteDataSource.updateCollectionName(
      userId: userId,
      collectionId: collectionId,
      name: normalized,
    );
  }

  @override
  Future<void> deleteCollection({
    required String userId,
    required String collectionId,
  }) async {
    await remoteDataSource.deleteCollection(
      userId: userId,
      collectionId: collectionId,
    );
  }

  @override
  Future<void> setQuoteInCollection({
    required String userId,
    required String collectionId,
    required String quoteId,
    required bool shouldAdd,
  }) async {
    await remoteDataSource.setQuoteInCollection(
      userId: userId,
      collectionId: collectionId,
      quoteId: quoteId,
      shouldAdd: shouldAdd,
    );
  }
}
