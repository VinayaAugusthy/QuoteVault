import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/constants/route_constants.dart';
import 'package:quote_vault/core/utils/snackbar_utils.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quotes_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_shimmers.dart';
import 'package:quote_vault/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:quote_vault/core/services/widget_quote_sync_service.dart';
import 'package:quote_vault/core/services/user_profile_local_service.dart';

class QuotesListPage extends StatefulWidget {
  const QuotesListPage({super.key});

  @override
  State<QuotesListPage> createState() => _QuotesListPageState();
}

class _QuotesListPageState extends State<QuotesListPage> {
  String? _userId;
  String? _avatarPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && _userId != authState.user.id) {
      _userId = authState.user.id;
      _loadAvatar();
    }
  }

  Future<void> _loadAvatar() async {
    final userId = _userId;
    if (userId == null) return;
    final path = await UserProfileLocalService.getAvatarPath(userId);
    if (!mounted) return;
    setState(() => _avatarPath = path);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (shouldLogout == true) {
      authBloc.add(const LogoutRequested());
    }
  }

  void _maybeSyncQuoteOfDayToWidget(QuotesState state) {
    final q = state.dailyQuote;
    if (q == null) return;
    WidgetQuoteSyncService.pushQuoteOfDayToWidget(
      id: q.id,
      body: q.body,
      author: q.author,
    );
  }

  List<Widget> _buildHomeLoadingChildren(BuildContext context) {
    return [
      const QuoteOfTheDayShimmer(),
      const SizedBox(height: 20),
      _buildSearchBar(context),
      const SizedBox(height: 12),
      const CategoryChipsShimmer(),
      const SizedBox(height: 16),
      const QuoteCardShimmer(),
      const QuoteCardShimmer(),
      const QuoteCardShimmer(),
      const QuoteCardShimmer(),
    ];
  }

  Widget _buildQuoteOfTheDayCard(BuildContext context, QuotesState state) {
    final scheme = Theme.of(context).colorScheme;
    final dailyQuote = state.dailyQuote;
    final quoteText = dailyQuote?.body ?? AppStrings.dailyQuoteFallback;
    final authorText = dailyQuote?.author ?? AppStrings.dailyAuthorFallback;
    final isFavorite =
        dailyQuote != null && state.favoriteQuoteIds.contains(dailyQuote.id);
    final fontScale = context.select((SettingsCubit c) => c.state.fontScale);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
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
            textScaler: TextScaler.linear(fontScale),
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
                    final currentIsFavorite = context
                        .read<QuotesBloc>()
                        .state
                        .favoriteQuoteIds
                        .contains(dailyQuote.id);
                    final willBeFavorite = !currentIsFavorite;
                    context.read<QuotesBloc>().add(
                      QuotesFavoriteToggled(
                        quoteId: dailyQuote.id,
                        shouldAdd: willBeFavorite,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(
                    isFavorite
                        ? AppStrings.favorited
                        : AppStrings.addToFavorites,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      onChanged: (value) {
        context.read<QuotesBloc>().add(QuotesSearchQueryChanged(value));
      },
      decoration: InputDecoration(
        hintText: AppStrings.searchHint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, QuotesState state) {
    final scheme = Theme.of(context).colorScheme;
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
            selectedColor: scheme.primary,
            backgroundColor: scheme.surface,
            checkmarkColor: scheme.onPrimary,
            labelStyle: TextStyle(
              color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : Theme.of(context).dividerColor,
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
    final avatarFile = (_avatarPath != null && File(_avatarPath!).existsSync())
        ? File(_avatarPath!)
        : null;

    return BlocListener<QuotesBloc, QuotesState>(
      listenWhen: (prev, curr) =>
          prev.dailyQuote?.id != curr.dailyQuote?.id && curr.dailyQuote != null,
      listener: (_, state) => _maybeSyncQuoteOfDayToWidget(state),
      child: BlocListener<AuthBloc, AuthState>(
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
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              AppStrings.appName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () async {
                    await Navigator.pushNamed(context, RouteConstants.profile);
                    await _loadAvatar();
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    backgroundImage: avatarFile != null
                        ? FileImage(avatarFile)
                        : null,
                    child: avatarFile == null
                        ? Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => _handleLogout(context),
                tooltip: AppStrings.logout,
              ),
            ],
          ),
          body: BlocConsumer<QuotesBloc, QuotesState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage &&
                current.errorMessage != null,
            listener: (context, state) {
              SnackbarUtils.showError(context, state.errorMessage!);
            },
            builder: (context, state) {
              final isInitialLoading =
                  state.status == QuotesStatus.loading && !state.isRefreshing;
              return RefreshIndicator(
                onRefresh: () async {
                  final bloc = context.read<QuotesBloc>();
                  bloc.add(const QuotesRefreshRequested());
                  await bloc.stream.firstWhere((s) => !s.isRefreshing);
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 320) {
                      context.read<QuotesBloc>().add(
                        const QuotesLoadMoreRequested(),
                      );
                    }
                    return false;
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      if (isInitialLoading)
                        ..._buildHomeLoadingChildren(context)
                      else ...[
                        _buildQuoteOfTheDayCard(context, state),
                        const SizedBox(height: 20),
                        _buildSearchBar(context),
                        const SizedBox(height: 12),
                        _buildCategoryChips(context, state),
                        const SizedBox(height: 16),
                      ],
                      if (!isInitialLoading &&
                          state.status == QuotesStatus.failure) ...[
                        Center(
                          child: Text(
                            AppStrings.unableToLoadQuotes,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (!isInitialLoading &&
                          state.status == QuotesStatus.success &&
                          state.quotes.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(
                            child: Text(
                              AppStrings.noQuotesMatchSearch,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
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
                            key: ValueKey('quote_${quote.id}_$isFavorite'),
                            quote: quote,
                            isFavorite: isFavorite,
                            onFavoriteToggle: () {
                              final currentIsFavorite = context
                                  .read<QuotesBloc>()
                                  .state
                                  .favoriteQuoteIds
                                  .contains(quote.id);
                              final willBeFavorite = !currentIsFavorite;
                              context.read<QuotesBloc>().add(
                                QuotesFavoriteToggled(
                                  quoteId: quote.id,
                                  shouldAdd: willBeFavorite,
                                ),
                              );
                            },
                          );
                        }),
                      if (state.isLoadingMore) ...[
                        const SizedBox(height: 12),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 16),
                      ] else if (!state.hasMore &&
                          state.status == QuotesStatus.success &&
                          state.quotes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'You reached the end.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
