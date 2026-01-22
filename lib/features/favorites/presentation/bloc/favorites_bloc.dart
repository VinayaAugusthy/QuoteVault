// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/quotes/domain/usecases/get_favorite_quotes_usecase.dart';
import 'package:quote_vault/features/quotes/domain/usecases/toggle_favorite_usecase.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteQuotesUseCase getFavoriteQuotesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final String userId;

  FavoritesBloc({
    required this.getFavoriteQuotesUseCase,
    required this.toggleFavoriteUseCase,
    required this.userId,
  }) : super(FavoritesState.initial()) {
    on<FavoritesRequested>(_onFavoritesRequested);
    on<FavoriteToggled>(_onFavoriteToggled);

    add(const FavoritesRequested());
  }

  Future<void> _onFavoritesRequested(
    FavoritesRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final favorites = await getFavoriteQuotesUseCase.call(userId: userId);
      emit(
        state.copyWith(status: FavoritesStatus.success, favorites: favorites),
      );
    } catch (e) {
      final shouldHardFail = state.favorites.isEmpty;
      emit(
        state.copyWith(
          status: shouldHardFail
              ? FavoritesStatus.failure
              : FavoritesStatus.success,
        ),
      );
    }
  }

  Future<void> _onFavoriteToggled(
    FavoriteToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await toggleFavoriteUseCase.call(
        userId: userId,
        quoteId: event.quoteId,
        shouldAdd: event.shouldAdd,
      );
      add(const FavoritesRequested());
    } catch (e) {
      emit(
        state.copyWith(
          status: state.favorites.isEmpty
              ? FavoritesStatus.failure
              : FavoritesStatus.success,
        ),
      );
    }
  }
}
