import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quotes_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';
import '../bloc/favorites_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(AppStrings.navFavorites),
        centerTitle: true,
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          switch (state.status) {
            case FavoritesStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case FavoritesStatus.failure:
              return Center(
                child: Text(
                  state.message ?? AppStrings.somethingWentWrong,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              );
            case FavoritesStatus.success:
              if (state.favorites.isEmpty) {
                return const Center(child: Text(AppStrings.noFavoritesYet));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                        QuotesFavoriteToggled(
                          quoteId: quote.id,
                          shouldAdd: false,
                        ),
                      );
                    },
                  );
                },
              );
            case FavoritesStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
