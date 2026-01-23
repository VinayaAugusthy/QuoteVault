import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quotes_bloc.dart';

import '../bloc/collections_bloc.dart';
import '../widgets/collection_card.dart';
import 'collection_detail_page.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navCollections),
        centerTitle: true,
      ),
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          if (state.status == CollectionsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CollectionsStatus.failure &&
              state.collections.isEmpty) {
            return Center(
              child: Text(
                AppStrings.somethingWentWrong,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: state.collections.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noCollectionsYet,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 1.2,
                              ),
                          itemCount: state.collections.length,
                          itemBuilder: (context, index) {
                            final collection = state.collections[index];
                            return CollectionCard(
                              name: collection.name,
                              onTap: () {
                                final collectionsBloc = context
                                    .read<CollectionsBloc>();
                                final quotesBloc = context.read<QuotesBloc>();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(
                                          value: collectionsBloc,
                                        ),
                                        BlocProvider.value(value: quotesBloc),
                                      ],
                                      child: CollectionDetailPage(
                                        collectionId: collection.id,
                                        collectionName: collection.name,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
