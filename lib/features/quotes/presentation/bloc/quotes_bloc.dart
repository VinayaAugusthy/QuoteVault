import 'package:bloc/bloc.dart';
import 'dart:developer' as developer;
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/quote.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_daily_quote_usecase.dart';
import '../../domain/usecases/get_favorite_quote_ids_usecase.dart';
import '../../domain/usecases/get_quotes_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  static const int _pageSize = 30;
  final GetQuotesUseCase getQuotesUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetDailyQuoteUseCase getDailyQuoteUseCase;
  final GetFavoriteQuoteIdsUseCase getFavoriteQuoteIdsUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final String userId;

  QuotesBloc({
    required this.getQuotesUseCase,
    required this.getCategoriesUseCase,
    required this.getDailyQuoteUseCase,
    required this.getFavoriteQuoteIdsUseCase,
    required this.toggleFavoriteUseCase,
    required this.userId,
  }) : super(QuotesState.initial()) {
    on<QuotesRequested>(_onQuotesRequested);
    on<QuotesRefreshRequested>(_onRefreshRequested);
    on<QuotesCategoryChanged>(_onCategoryChanged);
    on<QuotesSearchQueryChanged>(_onSearchQueryChanged);
    on<QuotesFavoriteToggled>(_onFavoriteToggled);
    on<QuotesLoadMoreRequested>(_onLoadMoreRequested);

    add(const QuotesRequested());
  }

  Future<void> _onQuotesRequested(
    QuotesRequested event,
    Emitter<QuotesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: QuotesStatus.loading,
        errorMessage: null,
        isLoadingMore: false,
        hasMore: true,
      ),
    );

    try {
      final categories = await getCategoriesUseCase.call();
      final quotes = await _loadQuotesPage(offset: 0);
      final favorites = await getFavoriteQuoteIdsUseCase.call(userId: userId);
      final dailyQuote = await getDailyQuoteUseCase.call();
      final hasMore = quotes.length >= _pageSize;

      emit(
        state.copyWith(
          status: QuotesStatus.success,
          quotes: quotes,
          dailyQuote: dailyQuote,
          categories: _buildCategoryOptions(categories),
          favoriteQuoteIds: favorites.toSet(),
          errorMessage: null,
          isRefreshing: false,
          isLoadingMore: false,
          hasMore: hasMore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: QuotesStatus.failure,
          errorMessage: e.toString(),
          isRefreshing: false,
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    QuotesRefreshRequested event,
    Emitter<QuotesState> emit,
  ) async {
    emit(
      state.copyWith(
        isRefreshing: true,
        isLoadingMore: false,
        errorMessage: null,
        hasMore: true,
      ),
    );

    try {
      final categories = await getCategoriesUseCase.call();
      final quotes = await _loadQuotesPage(offset: 0);
      final favorites = await getFavoriteQuoteIdsUseCase.call(userId: userId);
      final dailyQuote = await getDailyQuoteUseCase.call();
      final hasMore = quotes.length >= _pageSize;

      emit(
        state.copyWith(
          status: QuotesStatus.success,
          quotes: quotes,
          favoriteQuoteIds: favorites.toSet(),
          dailyQuote: dailyQuote,
          categories: _buildCategoryOptions(categories),
          errorMessage: null,
          isRefreshing: false,
          isLoadingMore: false,
          hasMore: hasMore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: QuotesStatus.failure,
          errorMessage: e.toString(),
          isRefreshing: false,
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onCategoryChanged(
    QuotesCategoryChanged event,
    Emitter<QuotesState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        status: QuotesStatus.loading,
        errorMessage: null,
        isLoadingMore: false,
        hasMore: true,
      ),
    );

    try {
      final quotes = await _loadQuotesPage(category: event.category, offset: 0);
      final hasMore = quotes.length >= _pageSize;
      emit(
        state.copyWith(
          status: QuotesStatus.success,
          quotes: quotes,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: QuotesStatus.failure,
          errorMessage: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onSearchQueryChanged(
    QuotesSearchQueryChanged event,
    Emitter<QuotesState> emit,
  ) async {
    emit(
      state.copyWith(
        searchQuery: event.query,
        status: QuotesStatus.loading,
        errorMessage: null,
        isLoadingMore: false,
        hasMore: true,
      ),
    );

    try {
      final quotes = await _loadQuotesPage(searchQuery: event.query, offset: 0);
      final hasMore = quotes.length >= _pageSize;
      emit(
        state.copyWith(
          status: QuotesStatus.success,
          quotes: quotes,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: QuotesStatus.failure,
          errorMessage: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    QuotesLoadMoreRequested event,
    Emitter<QuotesState> emit,
  ) async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.status != QuotesStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    try {
      final next = await _loadQuotesPage(offset: state.quotes.length);
      final hasMore = next.length >= _pageSize;
      emit(
        state.copyWith(
          quotes: [...state.quotes, ...next],
          isLoadingMore: false,
          hasMore: hasMore,
          status: QuotesStatus.success,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onFavoriteToggled(
    QuotesFavoriteToggled event,
    Emitter<QuotesState> emit,
  ) async {
    final previousFavorites = Set<String>.from(state.favoriteQuoteIds);
    final updatedFavorites = Set<String>.from(state.favoriteQuoteIds);
    if (event.shouldAdd) {
      updatedFavorites.add(event.quoteId);
    } else {
      updatedFavorites.remove(event.quoteId);
    }

    // Optimistic UI update so the icon flips immediately.
    emit(
      state.copyWith(
        favoriteQuoteIds: updatedFavorites,
        status: QuotesStatus.success,
        errorMessage: null,
      ),
    );

    try {
      await toggleFavoriteUseCase.call(
        userId: userId,
        quoteId: event.quoteId,
        shouldAdd: event.shouldAdd,
      );
    } catch (e) {
      developer.log(
        'Toggle favorite failed (quoteId=${event.quoteId}, shouldAdd=${event.shouldAdd}, userId=$userId): ${e.toString()}',
        name: 'QuoteVault',
        error: e,
      );
      // Revert optimistic update if remote write fails.
      emit(
        state.copyWith(
          favoriteQuoteIds: previousFavorites,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  List<String> _buildCategoryOptions(List<String> categories) {
    final normalized = <String>['All'];
    for (final category in categories) {
      if (category.trim().isNotEmpty && category != 'All') {
        normalized.add(category);
      }
    }
    return normalized;
  }

  Future<List<Quote>> _loadQuotesPage({
    String? category,
    String? searchQuery,
    required int offset,
  }) {
    return getQuotesUseCase.call(
      category: category ?? state.selectedCategory,
      searchQuery: searchQuery ?? state.searchQuery,
      limit: _pageSize,
      offset: offset,
    );
  }
}
