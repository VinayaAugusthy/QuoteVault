import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:quote_vault/core/di/injection_container.dart';
import 'package:quote_vault/core/navigation/persistent_bottom_nav_bar.dart';
import 'package:quote_vault/features/collections/presentation/pages/collections_page.dart';
import 'package:quote_vault/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/favorites/presentation/pages/favorites_page.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quotes_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/pages/quotes_list_page.dart';
import 'package:quote_vault/features/settings/presentation/pages/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const MainNavigationPage({
    super.key,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuotesBloc>(
          create: (_) => InjectionContainer().quotesBloc(userId: widget.userId),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) =>
              InjectionContainer().favoritesBloc(userId: widget.userId),
        ),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: AppColors.backgroundWhite,
            body: IndexedStack(
              index: _currentIndex,
              children: const [
                QuotesListPage(),
                FavoritesPage(),
                CollectionsPage(),
                SettingsPage(),
              ],
            ),
            bottomNavigationBar: PersistentBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                _onIndexChanged(index);
                if (index == 1) {
                  innerContext.read<FavoritesBloc>().add(
                    const FavoritesRequested(),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
