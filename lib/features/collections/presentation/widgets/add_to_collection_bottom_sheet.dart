import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

import '../../domain/entities/collection.dart';
import '../../presentation/bloc/collections_bloc.dart';

class AddToCollectionBottomSheet extends StatefulWidget {
  final String quoteId;

  const AddToCollectionBottomSheet({super.key, required this.quoteId});

  @override
  State<AddToCollectionBottomSheet> createState() =>
      _AddToCollectionBottomSheetState();
}

class _AddToCollectionBottomSheetState
    extends State<AddToCollectionBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _showCreate = false;
  bool _isCreating = false;
  String? _selectedCollectionId;

  static const _sheetRadius = 24.0;
  static const _sheetPadding = EdgeInsets.symmetric(horizontal: 16);
  static const _sectionSpacing = SizedBox(height: 12);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeSelection(List<Collection> collections) {
    if (_selectedCollectionId != null) return;
    final containing = collections
        .where((c) => c.quoteIds.contains(widget.quoteId))
        .toList(growable: false);
    if (containing.isNotEmpty) {
      _selectedCollectionId = containing.first.id;
    }
  }

  void _applySelection(List<Collection> collections) {
    final selectedId = _selectedCollectionId;
    final bloc = context.read<CollectionsBloc>();

    if (selectedId != null) {
      bloc.add(
        CollectionQuoteToggled(
          collectionId: selectedId,
          quoteId: widget.quoteId,
          shouldAdd: true,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  Future<void> _createAndAdd() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    if (_isCreating) return;

    setState(() => _isCreating = true);
    context.read<CollectionsBloc>().add(
      CollectionCreated(name: name, initialQuoteId: widget.quoteId),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    setState(() {
      _isCreating = false;
      _controller.clear();
      _showCreate = false;
      _selectedCollectionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: _sheetPadding.copyWith(
          top: 10,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocBuilder<CollectionsBloc, CollectionsState>(
          builder: (context, state) {
            final collections = state.collections;
            _initializeSelection(collections);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BottomSheetGrabber(),
                _sectionSpacing,
                _BottomSheetHeader(
                  title: AppStrings.addToCollection,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 6),

                _CreateNewCollectionTile(
                  expanded: _showCreate,
                  onTap: () => setState(() => _showCreate = !_showCreate),
                ),
                if (_showCreate) ...[
                  const SizedBox(height: 10),
                  _CollectionNameField(
                    controller: _controller,
                    onSubmitted: _createAndAdd,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createAndAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_sheetRadius),
                        ),
                      ),
                      child: Text(
                        _isCreating ? AppStrings.creating : AppStrings.create,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.yourCollections,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (collections.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      AppStrings.noCollectionsYetCreateOne,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                else
                  Flexible(
                    child: RadioGroup<String?>(
                      groupValue: _selectedCollectionId,
                      onChanged: (value) => setState(() {
                        _selectedCollectionId = value;
                      }),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: collections.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final collection = collections[index];
                          return _CollectionRow(collection: collection);
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedCollectionId == null
                        ? null
                        : () => _applySelection(collections),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_sheetRadius),
                      ),
                    ),
                    child: const Text(AppStrings.addToCollection),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomSheetGrabber extends StatelessWidget {
  const _BottomSheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _BottomSheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
      ],
    );
  }
}

class _CreateNewCollectionTile extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _CreateNewCollectionTile({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.createNewCollection,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionNameField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const _CollectionNameField({
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        hintText: AppStrings.collectionName,
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  final Collection collection;

  const _CollectionRow({required this.collection});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RadioListTile<String?>(
      value: collection.id,
      activeColor: scheme.primary,
      title: Text(
        collection.name,
        style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${collection.quoteIds.length} quotes',
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
