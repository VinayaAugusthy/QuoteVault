import 'package:flutter/material.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/utils/snackbar_utils.dart';

import '../../domain/entities/quote.dart';
import 'package:quote_vault/features/collections/presentation/widgets/add_to_collection_bottom_sheet.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_bloc.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  void _openAddToCollectionSheet(BuildContext context) {
    CollectionsBloc? collectionsBloc;
    try {
      collectionsBloc = context.read<CollectionsBloc>();
    } catch (_) {
      collectionsBloc = null;
    }
    if (collectionsBloc == null) return;
    final bloc = collectionsBloc;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: AddToCollectionBottomSheet(quoteId: quote.id),
      ),
    );
  }

  void _removeFromAllCollections(BuildContext context) {
    final bloc = context.read<CollectionsBloc>();
    final currentCollectionId = bloc.state.quoteToCollectionId[quote.id];
    final removed = currentCollectionId != null;
    if (currentCollectionId != null) {
      bloc.add(
        CollectionQuoteToggled(
          collectionId: currentCollectionId,
          quoteId: quote.id,
          shouldAdd: false,
        ),
      );
    }
    if (removed) {
      SnackbarUtils.showSuccess(context, AppStrings.removedFromCollection);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isInAnyCollection = false;
    try {
      isInAnyCollection = context.select(
        (CollectionsBloc bloc) =>
            bloc.state.quoteToCollectionId.containsKey(quote.id),
      );
    } catch (_) {
      isInAnyCollection = false;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            '"${quote.body}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryTeal.withValues(
                        alpha: 0.2,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        quote.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? AppColors.favoriteRed
                          : AppColors.iconGrey,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (isInAnyCollection) {
                        _removeFromAllCollections(context);
                      } else {
                        _openAddToCollectionSheet(context);
                      }
                    },
                    icon: Icon(
                      Icons.collections_bookmark_outlined,
                      color: isInAnyCollection
                          ? AppColors.primaryTeal
                          : AppColors.iconGrey,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.share,
                      color: AppColors.iconGrey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
