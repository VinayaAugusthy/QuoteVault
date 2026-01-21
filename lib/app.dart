import 'package:flutter/material.dart';
// TODO: Add flutter_bloc dependency
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'features/auth/presentation/bloc/auth_bloc.dart';
// import 'features/quotes/presentation/bloc/quote_bloc.dart';
// import 'features/favorites/presentation/bloc/favorite_bloc.dart';
// import 'features/collections/presentation/bloc/collection_bloc.dart';
// import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/quotes/presentation/pages/quotes_list_page.dart';

class QuoteVaultApp extends StatelessWidget {
  const QuoteVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuoteVault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const QuotesListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
