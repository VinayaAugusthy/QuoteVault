part of 'favorites_bloc.dart';

@immutable
sealed class FavoritesEvent {
  const FavoritesEvent();
}

final class FavoritesRequested extends FavoritesEvent {
  const FavoritesRequested();
}

final class FavoriteToggled extends FavoritesEvent {
  final String quoteId;
  final bool shouldAdd;

  const FavoriteToggled({required this.quoteId, required this.shouldAdd});
}
