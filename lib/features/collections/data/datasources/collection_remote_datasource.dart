import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/collection_model.dart';

abstract class CollectionRemoteDataSource {
  Future<List<CollectionModel>> fetchCollections({required String userId});

  Future<List<Map<String, dynamic>>> fetchCollectionItems({
    required String userId,
  });

  Future<CollectionModel> createCollection({
    required String userId,
    required String name,
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

class CollectionRemoteDataSourceImpl implements CollectionRemoteDataSource {
  static const String _collectionsTable = 'collections';
  static const String _itemsTable = 'collection_quotes';
  static const String _collectionColumns = 'id, name, created_at';

  final SupabaseClient supabaseClient;

  CollectionRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CollectionModel>> fetchCollections({
    required String userId,
  }) async {
    final result = await supabaseClient
        .from(_collectionsTable)
        .select(_collectionColumns)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final data = (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );

    return data
        .map(
          (row) => CollectionModel(
            id: row['id'].toString(),
            name: (row['name'] as String?) ?? '',
            createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
            quoteIds: const <String>[],
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCollectionItems({
    required String userId,
  }) async {
    final result = await supabaseClient
        .from(_itemsTable)
        .select('collection_id, quote_id')
        .eq('user_id', userId);

    return (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );
  }

  @override
  Future<CollectionModel> createCollection({
    required String userId,
    required String name,
  }) async {
    final result = await supabaseClient
        .from(_collectionsTable)
        .insert({'user_id': userId, 'name': name})
        .select(_collectionColumns)
        .single();

    final row = result;
    return CollectionModel(
      id: row['id'].toString(),
      name: (row['name'] as String?) ?? name,
      createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
      quoteIds: const <String>[],
    );
  }

  @override
  Future<void> updateCollectionName({
    required String userId,
    required String collectionId,
    required String name,
  }) async {
    await supabaseClient
        .from(_collectionsTable)
        .update({'name': name})
        .eq('user_id', userId)
        .eq('id', collectionId);
  }

  @override
  Future<void> deleteCollection({
    required String userId,
    required String collectionId,
  }) async {
    await supabaseClient
        .from(_collectionsTable)
        .delete()
        .eq('user_id', userId)
        .eq('id', collectionId);
  }

  @override
  Future<void> setQuoteInCollection({
    required String userId,
    required String collectionId,
    required String quoteId,
    required bool shouldAdd,
  }) async {
    if (shouldAdd) {
      await supabaseClient.from(_itemsTable).upsert([
        {'user_id': userId, 'quote_id': quoteId, 'collection_id': collectionId},
      ], onConflict: 'user_id,quote_id');
      return;
    }

    await supabaseClient
        .from(_itemsTable)
        .delete()
        .eq('user_id', userId)
        .eq('quote_id', quoteId);
  }
}
