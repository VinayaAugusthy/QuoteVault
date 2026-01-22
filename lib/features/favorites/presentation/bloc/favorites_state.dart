part of 'favorites_bloc.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  const FavoritesState({
    required this.status,
    required this.favorites,
    required this.message,
  });

  factory FavoritesState.initial() => const FavoritesState(
    status: FavoritesStatus.initial,
    favorites: [],
    message: null,
  );

  final FavoritesStatus status;
  final List<Quote> favorites;
  final String? message;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Quote>? favorites,
    String? message,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, favorites, message];
}
