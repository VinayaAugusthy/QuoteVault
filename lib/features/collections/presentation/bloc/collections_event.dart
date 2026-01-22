part of 'collections_bloc.dart';

@immutable
sealed class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object?> get props => [];
}

final class CollectionsRequested extends CollectionsEvent {
  const CollectionsRequested();
}

final class CollectionCreated extends CollectionsEvent {
  final String name;
  final String? initialQuoteId;

  const CollectionCreated({required this.name, this.initialQuoteId});

  @override
  List<Object?> get props => [name, initialQuoteId];
}

final class CollectionQuoteToggled extends CollectionsEvent {
  final String collectionId;
  final String quoteId;
  final bool shouldAdd;

  const CollectionQuoteToggled({
    required this.collectionId,
    required this.quoteId,
    required this.shouldAdd,
  });

  @override
  List<Object?> get props => [collectionId, quoteId, shouldAdd];
}

final class CollectionQuotesRequested extends CollectionsEvent {
  final String collectionId;

  const CollectionQuotesRequested({required this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}
