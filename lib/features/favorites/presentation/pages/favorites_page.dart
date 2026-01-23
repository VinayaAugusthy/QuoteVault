import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quotes_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';
import '../bloc/favorites_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navFavorites),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.initial) {
            return const SizedBox.shrink();
          }

          if (state.status == FavoritesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FavoritesStatus.failure) {
            return Center(
              child: Text(
                AppStrings.failedToLoadFavourites,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (state.favorites.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noFavouritesFound,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: state.favorites.length,
            itemBuilder: (context, index) {
              final quote = state.favorites[index];
              return QuoteCard(
                quote: quote,
                isFavorite: true,
                onFavoriteToggle: () {
                  context.read<FavoritesBloc>().add(
                    FavoriteToggled(quoteId: quote.id, shouldAdd: false),
                  );
                  context.read<QuotesBloc>().add(
                    QuotesFavoriteToggled(quoteId: quote.id, shouldAdd: false),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
