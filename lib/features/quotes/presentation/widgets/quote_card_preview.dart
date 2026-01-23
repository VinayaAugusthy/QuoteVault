import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/settings/presentation/cubit/settings_cubit.dart';

import 'quote_card_styles.dart';
import '../../../../core/constants/app_strings.dart';

class QuoteCardPreview extends StatelessWidget {
  final Quote quote;
  final QuoteCardStyle style;
  final GlobalKey repaintBoundaryKey;

  const QuoteCardPreview({
    super.key,
    required this.quote,
    required this.style,
    required this.repaintBoundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    final fontScale = context.select((SettingsCubit c) => c.state.fontScale);

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: style.decoration(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '"${quote.body}"',
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(fontScale),
              style: TextStyle(
                fontSize: 18,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: style.quoteTextColor(context),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 1.5,
                  color: style.authorTextColor(context).withValues(alpha: 0.65),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    quote.author,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: style.authorTextColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 28,
                  height: 1.5,
                  color: style.authorTextColor(context).withValues(alpha: 0.65),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 12,
                color: style.authorTextColor(context).withValues(alpha: 0.7),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
