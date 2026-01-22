part of 'quotes_bloc.dart';

enum QuotesStatus { initial, loading, success, failure }

class QuotesState extends Equatable {
  const QuotesState({
    required this.status,
    required this.quotes,
    required this.dailyQuote,
    required this.categories,
    required this.selectedCategory,
    required this.searchQuery,
    required this.favoriteQuoteIds,
    required this.errorMessage,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasMore,
  });

  factory QuotesState.initial() => const QuotesState(
    status: QuotesStatus.initial,
    quotes: [],
    dailyQuote: null,
    categories: ['All'],
    selectedCategory: 'All',
    searchQuery: '',
    favoriteQuoteIds: {},
    errorMessage: null,
    isRefreshing: false,
    isLoadingMore: false,
    hasMore: true,
  );

  final QuotesStatus status;
  final List<Quote> quotes;
  final Quote? dailyQuote;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final Set<String> favoriteQuoteIds;
  final String? errorMessage;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;

  List<String> get _sortedFavoriteIds {
    final ids = favoriteQuoteIds.toList();
    ids.sort();
    return ids;
  }

  QuotesState copyWith({
    QuotesStatus? status,
    List<Quote>? quotes,
    Quote? dailyQuote,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    Set<String>? favoriteQuoteIds,
    String? errorMessage,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return QuotesState(
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
      dailyQuote: dailyQuote ?? this.dailyQuote,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      favoriteQuoteIds: favoriteQuoteIds ?? this.favoriteQuoteIds,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    quotes,
    dailyQuote,
    categories,
    selectedCategory,
    searchQuery,
    _sortedFavoriteIds,
    errorMessage,
    isRefreshing,
    isLoadingMore,
    hasMore,
  ];
}
