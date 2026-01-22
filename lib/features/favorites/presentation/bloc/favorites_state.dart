part of 'favorites_bloc.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  const FavoritesState({required this.status, required this.favorites});

  factory FavoritesState.initial() =>
      const FavoritesState(status: FavoritesStatus.initial, favorites: []);

  final FavoritesStatus status;
  final List<Quote> favorites;

  FavoritesState copyWith({FavoritesStatus? status, List<Quote>? favorites}) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object?> get props => [status, favorites];
}
