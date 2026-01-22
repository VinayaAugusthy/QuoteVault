import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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
    switch (id) {
      case QuoteCardStyleId.gradient:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              AppColors.quoteCardGradientStart,
              AppColors.quoteCardGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case QuoteCardStyleId.bordered:
        return BoxDecoration(
          color: AppColors.quoteCardBorderedBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryTeal, width: 3),
        );
      case QuoteCardStyleId.minimal:
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;
        return BoxDecoration(
          color: isDark
              ? AppColors.quoteCardMinimalDarkBackground
              : AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? AppColors.quoteCardMinimalDarkBorder
                : AppColors.borderGrey,
          ),
        );
    }
  }

  Color quoteTextColor(BuildContext context) {
    switch (id) {
      case QuoteCardStyleId.gradient:
        return AppColors.backgroundWhite;
      case QuoteCardStyleId.bordered:
        return AppColors.textPrimary;
      case QuoteCardStyleId.minimal:
        return Theme.of(context).brightness == Brightness.dark
            ? AppColors.quoteCardMinimalDarkText
            : AppColors.textPrimary;
    }
  }

  Color authorTextColor(BuildContext context) {
    switch (id) {
      case QuoteCardStyleId.gradient:
        return AppColors.backgroundWhite.withValues(alpha: 0.85);
      case QuoteCardStyleId.bordered:
        return AppColors.textSecondary;
      case QuoteCardStyleId.minimal:
        return Theme.of(context).brightness == Brightness.dark
            ? AppColors.quoteCardMinimalDarkSubtext
            : AppColors.textSecondary;
    }
  }

  Color chipPreviewColor(BuildContext context) {
    switch (id) {
      case QuoteCardStyleId.gradient:
        return AppColors.primaryTeal;
      case QuoteCardStyleId.bordered:
        return AppColors.quoteCardBorderedBackground;
      case QuoteCardStyleId.minimal:
        return Theme.of(context).brightness == Brightness.dark
            ? AppColors.quoteCardMinimalDarkBackground
            : AppColors.backgroundWhite;
    }
  }
}
