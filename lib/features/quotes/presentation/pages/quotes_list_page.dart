import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/constants/route_constants.dart';
import 'package:quote_vault/core/utils/snackbar_utils.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quotes_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';

class QuotesListPage extends StatelessWidget {
  const QuotesListPage({super.key});

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(const LogoutRequested());
  }

  Widget _buildQuoteOfTheDayCard(BuildContext context, QuotesState state) {
    final dailyQuote = state.dailyQuote;
    final quoteText =
        dailyQuote?.body ??
        AppStrings.dailyQuoteFallback;
    final authorText = dailyQuote?.author ?? AppStrings.dailyAuthorFallback;
    final isFavorite =
        dailyQuote != null && state.favoriteQuoteIds.contains(dailyQuote.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF00B4D8), Color(0xFF48CAE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.quoteOfTheDay,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"$quoteText"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '– $authorText',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: '"$quoteText"\n– $authorText'),
                  );
                  SnackbarUtils.showSuccess(
                    context,
                    AppStrings.quoteCopiedToClipboard,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: const Text(AppStrings.share),
              ),
              const SizedBox(width: 12),
              if (dailyQuote != null)
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<QuotesBloc>().add(
                      QuotesFavoriteToggled(
                        quoteId: dailyQuote.id,
                        shouldAdd: !isFavorite,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(
                    isFavorite ? AppStrings.favorited : AppStrings.addToFavorites,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      onChanged: (value) {
        context.read<QuotesBloc>().add(QuotesSearchQueryChanged(value));
      },
      decoration: InputDecoration(
        hintText: AppStrings.searchHint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, QuotesState state) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final isSelected = state.selectedCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            selectedColor: AppColors.primaryTeal,
            backgroundColor: AppColors.backgroundWhite,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.borderGrey,
              ),
            ),
            onSelected: (_) {
              context.read<QuotesBloc>().add(QuotesCategoryChanged(category));
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.login,
            (route) => false,
          );
        } else if (state is AuthError) {
          SnackbarUtils.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            AppStrings.appName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: AppColors.primaryTeal),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primaryTeal),
              onPressed: () => _handleLogout(context),
              tooltip: AppStrings.logout,
            ),
          ],
        ),
        body: BlocConsumer<QuotesBloc, QuotesState>(
          listener: (context, state) {
            if (state.status == QuotesStatus.failure &&
                state.errorMessage != null) {
              SnackbarUtils.showError(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            final isInitialLoading =
                state.status == QuotesStatus.loading && !state.isRefreshing;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuotesBloc>().add(const QuotesRefreshRequested());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  _buildQuoteOfTheDayCard(context, state),
                  const SizedBox(height: 20),
                  _buildSearchBar(context),
                  const SizedBox(height: 12),
                  _buildCategoryChips(context, state),
                  const SizedBox(height: 16),
                  if (isInitialLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 16),
                  ],
                  if (!isInitialLoading &&
                      state.status == QuotesStatus.failure) ...[
                    const Center(
                      child: Text(
                        AppStrings.unableToLoadQuotes,
                        style: TextStyle(color: AppColors.errorRed),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!isInitialLoading &&
                      state.status == QuotesStatus.success &&
                      state.quotes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          AppStrings.noQuotesMatchSearch,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  if (!isInitialLoading &&
                      state.status == QuotesStatus.success &&
                      state.quotes.isNotEmpty)
                    ...state.quotes.map((quote) {
                      final isFavorite = state.favoriteQuoteIds.contains(
                        quote.id,
                      );
                      return QuoteCard(
                        quote: quote,
                        isFavorite: isFavorite,
                        onFavoriteToggle: () {
                          context.read<QuotesBloc>().add(
                            QuotesFavoriteToggled(
                              quoteId: quote.id,
                              shouldAdd: !isFavorite,
                            ),
                          );
                        },
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
