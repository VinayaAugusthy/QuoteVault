import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

enum QuoteCardStyleId { gradient, bordered, minimal }

class QuoteCardStyle {
  final QuoteCardStyleId id;
  final String name;

  const QuoteCardStyle._(this.id, this.name);

  static const gradient = QuoteCardStyle._(
    QuoteCardStyleId.gradient,
    AppStrings.quoteStyleGradient,
  );
  static const bordered = QuoteCardStyle._(
    QuoteCardStyleId.bordered,
    AppStrings.quoteStyleBordered,
  );
  static const minimal = QuoteCardStyle._(
    QuoteCardStyleId.minimal,
    AppStrings.quoteStyleMinimal,
  );

  static const all = <QuoteCardStyle>[gradient, bordered, minimal];

  BoxDecoration decoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (id) {
      case QuoteCardStyleId.gradient:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case QuoteCardStyleId.bordered:
        return BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.primary, width: 3),
        );
      case QuoteCardStyleId.minimal:
        return BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Theme.of(context).dividerColor),
        );
    }
  }

  Color quoteTextColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (id) {
      case QuoteCardStyleId.gradient:
        return scheme.onPrimary;
      case QuoteCardStyleId.bordered:
        return scheme.onSurface;
      case QuoteCardStyleId.minimal:
        return scheme.onSurface;
    }
  }

  Color authorTextColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (id) {
      case QuoteCardStyleId.gradient:
        return scheme.onPrimary.withValues(alpha: 0.85);
      case QuoteCardStyleId.bordered:
        return scheme.onSurfaceVariant;
      case QuoteCardStyleId.minimal:
        return scheme.onSurfaceVariant;
    }
  }

  Color chipPreviewColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (id) {
      case QuoteCardStyleId.gradient:
        return scheme.primary;
      case QuoteCardStyleId.bordered:
        return scheme.surface;
      case QuoteCardStyleId.minimal:
        return scheme.surface;
    }
  }
}
