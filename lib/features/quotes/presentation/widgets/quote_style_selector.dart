import 'package:flutter/material.dart';

import 'quote_card_styles.dart';

class QuoteStyleSelector extends StatelessWidget {
  final List<QuoteCardStyle> styles;
  final QuoteCardStyle selected;
  final ValueChanged<QuoteCardStyle> onChanged;

  const QuoteStyleSelector({
    super.key,
    this.styles = QuoteCardStyle.all,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: styles.map((style) {
        final isSelected = style.id == selected.id;
        return ChoiceChip(
          selected: isSelected,
          showCheckmark: false,
          label: Text(style.name),
          avatar: _StylePreviewDot(
            color: style.chipPreviewColor(context),
            selected: isSelected,
          ),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor.withValues(alpha: 0.45),
          ),
          onSelected: (_) => onChanged(style),
        );
      }).toList(),
    );
  }
}

class _StylePreviewDot extends StatelessWidget {
  final Color color;
  final bool selected;

  const _StylePreviewDot({required this.color, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 5.5,
                height: 5.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : null,
    );
  }
}
