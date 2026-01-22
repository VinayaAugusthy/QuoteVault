part of 'quotes_bloc.dart';

@immutable
sealed class QuotesEvent {
  const QuotesEvent();
}

final class QuotesRequested extends QuotesEvent {
  const QuotesRequested();
}

final class QuotesRefreshRequested extends QuotesEvent {
  const QuotesRefreshRequested();
}

final class QuotesCategoryChanged extends QuotesEvent {
  final String category;

  const QuotesCategoryChanged(this.category);
}

final class QuotesSearchQueryChanged extends QuotesEvent {
  final String query;

  const QuotesSearchQueryChanged(this.query);
}

final class QuotesFavoriteToggled extends QuotesEvent {
  final String quoteId;
  final bool shouldAdd;

  const QuotesFavoriteToggled({required this.quoteId, required this.shouldAdd});
}

final class QuotesLoadMoreRequested extends QuotesEvent {
  const QuotesLoadMoreRequested();
}
