import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quotes_bloc.dart';

import '../bloc/collections_bloc.dart';

class CollectionDetailPage extends StatelessWidget {
  final String collectionId;
  final String collectionName;

  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(collectionName),
        centerTitle: true,
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
      ),
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          final favIds = context.select(
            (QuotesBloc bloc) => bloc.state.favoriteQuoteIds,
          );
          final isLoading = state.loadingCollectionQuoteIds.contains(
            collectionId,
          );
          final cached = state.quotesByCollectionId[collectionId];

          if (cached == null && !isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<CollectionsBloc>().add(
                CollectionQuotesRequested(collectionId: collectionId),
              );
            });
          }

          if (isLoading && cached == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final quotes = cached ?? const [];
          if (quotes.isEmpty) {
            return const Center(
              child: Text(
                AppStrings.noQuotesAddedYet,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              final isFavorite = favIds.contains(quote.id);
              return QuoteCard(
                quote: quote,
                isFavorite: isFavorite,
                onFavoriteToggle: () {
                  final willBeFavorite = !isFavorite;
                  context.read<QuotesBloc>().add(
                    QuotesFavoriteToggled(
                      quoteId: quote.id,
                      shouldAdd: willBeFavorite,
                    ),
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
