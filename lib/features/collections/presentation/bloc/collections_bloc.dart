// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:quote_vault/features/collections/domain/entities/collection.dart';
import 'package:quote_vault/features/collections/domain/usecases/add_quote_to_collection_usecase.dart';
import 'package:quote_vault/features/collections/domain/usecases/create_collection_usecase.dart';
import 'package:quote_vault/features/collections/domain/usecases/get_collections_usecase.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/quotes/domain/usecases/get_quotes_by_ids_usecase.dart';

part 'collections_event.dart';
part 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetCollectionsUseCase getCollectionsUseCase;
  final CreateCollectionUseCase createCollectionUseCase;
  final AddQuoteToCollectionUseCase addQuoteToCollectionUseCase;
  final GetQuotesByIdsUseCase getQuotesByIdsUseCase;
  final String userId;

  CollectionsBloc({
    required this.getCollectionsUseCase,
    required this.createCollectionUseCase,
    required this.addQuoteToCollectionUseCase,
    required this.getQuotesByIdsUseCase,
    required this.userId,
  }) : super(CollectionsState.initial()) {
    on<CollectionsRequested>(_onCollectionsRequested);
    on<CollectionCreated>(_onCollectionCreated);
    on<CollectionQuoteToggled>(_onCollectionQuoteToggled);
    on<CollectionQuotesRequested>(_onCollectionQuotesRequested);

    add(const CollectionsRequested());
  }

  Future<void> _onCollectionsRequested(
    CollectionsRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(state.copyWith(status: CollectionsStatus.loading, errorMessage: null));
    try {
      final collections = await getCollectionsUseCase.call(userId: userId);
      emit(
        state.copyWith(
          status: CollectionsStatus.success,
          collections: collections,
          quoteToCollectionId: {
            for (final c in collections)
              for (final qId in c.quoteIds) qId: c.id,
          },
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: state.collections.isEmpty
              ? CollectionsStatus.failure
              : CollectionsStatus.success,
          errorMessage: 'Failed to load collections.',
        ),
      );
    }
  }

  Future<void> _onCollectionCreated(
    CollectionCreated event,
    Emitter<CollectionsState> emit,
  ) async {
    try {
      final created = await createCollectionUseCase.call(
        userId: userId,
        name: event.name,
        initialQuoteId: event.initialQuoteId,
      );
      final nextMap = Map<String, String>.from(state.quoteToCollectionId);
      if (event.initialQuoteId != null) {
        nextMap[event.initialQuoteId!] = created.id;
      }
      emit(
        state.copyWith(
          collections: [created, ...state.collections],
          status: CollectionsStatus.success,
          quoteToCollectionId: nextMap,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CollectionsStatus.success,
          errorMessage: 'Unable to create collection.',
        ),
      );
    }
  }

  Future<void> _onCollectionQuoteToggled(
    CollectionQuoteToggled event,
    Emitter<CollectionsState> emit,
  ) async {
    try {
      await addQuoteToCollectionUseCase.call(
        userId: userId,
        collectionId: event.collectionId,
        quoteId: event.quoteId,
        shouldAdd: event.shouldAdd,
      );

      final updatedCollections = state.collections.toList(growable: true);
      final nextMap = Map<String, String>.from(state.quoteToCollectionId);

      final previousCollectionId = nextMap[event.quoteId];

      if (event.shouldAdd) {
        // Remove from previous collection (one-collection-per-quote).
        if (previousCollectionId != null &&
            previousCollectionId != event.collectionId) {
          final prevIndex = updatedCollections.indexWhere(
            (c) => c.id == previousCollectionId,
          );
          if (prevIndex != -1) {
            final prev = updatedCollections[prevIndex];
            updatedCollections[prevIndex] = prev.copyWith(
              quoteIds: prev.quoteIds
                  .where((id) => id != event.quoteId)
                  .toList(growable: false),
            );
          }
        }

        final idx = updatedCollections.indexWhere(
          (c) => c.id == event.collectionId,
        );
        if (idx != -1) {
          final target = updatedCollections[idx];
          if (!target.quoteIds.contains(event.quoteId)) {
            updatedCollections[idx] = target.copyWith(
              quoteIds: [...target.quoteIds, event.quoteId],
            );
          }
        }

        nextMap[event.quoteId] = event.collectionId;
      } else {
        final removeFromId = previousCollectionId ?? event.collectionId;
        final idx = updatedCollections.indexWhere((c) => c.id == removeFromId);
        if (idx != -1) {
          final target = updatedCollections[idx];
          updatedCollections[idx] = target.copyWith(
            quoteIds: target.quoteIds
                .where((id) => id != event.quoteId)
                .toList(growable: false),
          );
        }
        nextMap.remove(event.quoteId);
      }

      final nextQuotesById = Map<String, List<Quote>>.from(
        state.quotesByCollectionId,
      );
      if (previousCollectionId != null) {
        nextQuotesById.remove(previousCollectionId);
      }
      nextQuotesById.remove(event.collectionId);

      emit(
        state.copyWith(
          collections: updatedCollections.toList(growable: false),
          quotesByCollectionId: nextQuotesById,
          status: CollectionsStatus.success,
          quoteToCollectionId: nextMap,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CollectionsStatus.success,
          errorMessage: 'Unable to update collection.',
        ),
      );
    }
  }

  Future<void> _onCollectionQuotesRequested(
    CollectionQuotesRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    final collection = state.collections
        .where((c) => c.id == event.collectionId)
        .cast<Collection?>()
        .firstWhere((c) => c != null, orElse: () => null);

    if (collection == null) return;

    final loading = {...state.loadingCollectionQuoteIds, event.collectionId};
    emit(state.copyWith(loadingCollectionQuoteIds: loading));

    if (collection.quoteIds.isEmpty) {
      final nextQuotesById = Map<String, List<Quote>>.from(
        state.quotesByCollectionId,
      );
      nextQuotesById[event.collectionId] = const <Quote>[];
      final nextLoading = Set<String>.from(state.loadingCollectionQuoteIds)
        ..remove(event.collectionId);
      emit(
        state.copyWith(
          quotesByCollectionId: nextQuotesById,
          loadingCollectionQuoteIds: nextLoading,
        ),
      );
      return;
    }

    try {
      final quotes = await getQuotesByIdsUseCase.call(
        quoteIds: collection.quoteIds,
      );
      final nextQuotesById = Map<String, List<Quote>>.from(
        state.quotesByCollectionId,
      );
      nextQuotesById[event.collectionId] = quotes;

      final nextLoading = Set<String>.from(state.loadingCollectionQuoteIds)
        ..remove(event.collectionId);

      emit(
        state.copyWith(
          quotesByCollectionId: nextQuotesById,
          loadingCollectionQuoteIds: nextLoading,
        ),
      );
    } catch (e) {
      final nextLoading = Set<String>.from(state.loadingCollectionQuoteIds)
        ..remove(event.collectionId);
      emit(
        state.copyWith(
          loadingCollectionQuoteIds: nextLoading,
          errorMessage: 'Failed to load quotes.',
        ),
      );
    }
  }
}
