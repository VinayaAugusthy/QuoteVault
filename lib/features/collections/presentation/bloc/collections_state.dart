part of 'collections_bloc.dart';

enum CollectionsStatus { initial, loading, success, failure }

final class CollectionsState extends Equatable {
  final CollectionsStatus status;
  final List<Collection> collections;
  final Map<String, String> quoteToCollectionId;
  final Map<String, List<Quote>> quotesByCollectionId;
  final Set<String> loadingCollectionQuoteIds;
  final String? errorMessage;

  const CollectionsState({
    required this.status,
    required this.collections,
    required this.quoteToCollectionId,
    required this.quotesByCollectionId,
    required this.loadingCollectionQuoteIds,
    required this.errorMessage,
  });

  factory CollectionsState.initial() => const CollectionsState(
    status: CollectionsStatus.initial,
    collections: <Collection>[],
    quoteToCollectionId: <String, String>{},
    quotesByCollectionId: <String, List<Quote>>{},
    loadingCollectionQuoteIds: <String>{},
    errorMessage: null,
  );

  CollectionsState copyWith({
    CollectionsStatus? status,
    List<Collection>? collections,
    Map<String, String>? quoteToCollectionId,
    Map<String, List<Quote>>? quotesByCollectionId,
    Set<String>? loadingCollectionQuoteIds,
    String? errorMessage,
  }) {
    return CollectionsState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      quoteToCollectionId: quoteToCollectionId ?? this.quoteToCollectionId,
      quotesByCollectionId: quotesByCollectionId ?? this.quotesByCollectionId,
      loadingCollectionQuoteIds:
          loadingCollectionQuoteIds ?? this.loadingCollectionQuoteIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    collections,
    quoteToCollectionId,
    quotesByCollectionId,
    loadingCollectionQuoteIds,
    errorMessage,
  ];
}
