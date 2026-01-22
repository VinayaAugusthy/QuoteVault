import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/di/injection_container.dart';
import 'package:quote_vault/core/utils/snackbar_utils.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/quotes/domain/usecases/save_quote_card_image_usecase.dart';
import 'package:quote_vault/features/quotes/domain/usecases/share_quote_image_usecase.dart';
import 'package:quote_vault/features/quotes/domain/usecases/share_quote_text_usecase.dart';

import '../utils/quote_card_image_generator.dart';
import 'quote_card_preview.dart';
import 'quote_card_styles.dart';
import 'quote_style_selector.dart';

enum _ShareMode { text, image }

class ShareQuoteBottomSheet extends StatefulWidget {
  final Quote quote;
  final BuildContext parentContext;

  const ShareQuoteBottomSheet({
    super.key,
    required this.quote,
    required this.parentContext,
  });

  static Future<void> show(BuildContext context, Quote quote) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          ShareQuoteBottomSheet(quote: quote, parentContext: context),
    );
  }

  @override
  State<ShareQuoteBottomSheet> createState() => _ShareQuoteBottomSheetState();
}

class _ShareQuoteBottomSheetState extends State<ShareQuoteBottomSheet> {
  final _repaintKey = GlobalKey();

  _ShareMode _mode = _ShareMode.image;
  QuoteCardStyle _style = QuoteCardStyle.gradient;
  bool _busy = false;

  late final ShareQuoteTextUseCase _shareTextUseCase;
  late final ShareQuoteImageUseCase _shareImageUseCase;
  late final SaveQuoteCardImageUseCase _saveImageUseCase;

  @override
  void initState() {
    super.initState();
    final container = InjectionContainer();
    _shareTextUseCase = ShareQuoteTextUseCase(container.quoteShareRepository);
    _shareImageUseCase = ShareQuoteImageUseCase(container.quoteShareRepository);
    _saveImageUseCase = SaveQuoteCardImageUseCase(
      container.quoteShareRepository,
    );
  }

  String get _formattedQuoteText =>
      '"${widget.quote.body}"\n\n— ${widget.quote.author}';

  Future<void> _runBusy(
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);

    final navigator = Navigator.of(widget.parentContext);
    final messenger = ScaffoldMessenger.maybeOf(widget.parentContext);
    try {
      await action();

      if (navigator.canPop()) navigator.pop();
      if (successMessage != null && successMessage.isNotEmpty) {
        SnackbarUtils.showWithMessenger(
          messenger,
          successMessage,
          backgroundColor: AppColors.successGreen,
        );
      }
    } catch (e) {
      if (e is PlatformException) {
        final msg = switch (e.code) {
          'permission_denied' => AppStrings.permissionDeniedMessage,
          'save_failed' => AppStrings.saveFailedMessage,
          _ => e.message ?? AppStrings.somethingWentWrong,
        };
        if (navigator.canPop()) navigator.pop();
        SnackbarUtils.showWithMessenger(
          messenger,
          msg,
          backgroundColor: AppColors.errorRed,
        );
      } else if (e is StateError) {
        if (navigator.canPop()) navigator.pop();
        SnackbarUtils.showWithMessenger(
          messenger,
          e.message,
          backgroundColor: AppColors.errorRed,
        );
      } else {
        if (navigator.canPop()) navigator.pop();
        SnackbarUtils.showWithMessenger(
          messenger,
          AppStrings.somethingWentWrong,
          backgroundColor: AppColors.errorRed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareText() {
    return _runBusy(() async {
      await _shareTextUseCase(widget.quote);
    }, successMessage: AppStrings.shareSuccess);
  }

  Future<void> _shareImage() {
    return _runBusy(() async {
      final bytes = await QuoteCardImageGenerator.capturePngBytes(_repaintKey);
      await _shareImageUseCase(pngBytes: bytes, text: _formattedQuoteText);
    }, successMessage: AppStrings.shareSuccess);
  }

  Future<void> _saveImage() {
    return _runBusy(() async {
      final bytes = await QuoteCardImageGenerator.capturePngBytes(_repaintKey);
      final fileName = 'quote_${DateTime.now().millisecondsSinceEpoch}.png';
      final id = await _saveImageUseCase(pngBytes: bytes, fileName: fileName);
      if (id == null || id.isEmpty) {
        throw PlatformException(
          code: 'save_failed',
          message: AppStrings.saveFailedMessage,
        );
      }
    }, successMessage: AppStrings.saveSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetHeader(
                    busy: _busy,
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        selected: _mode == _ShareMode.text,
                        label: const Text(AppStrings.shareModeText),
                        selectedColor: AppColors.primaryTeal,
                        checkmarkColor: AppColors.backgroundWhite,
                        labelStyle: TextStyle(
                          color: _mode == _ShareMode.text
                              ? AppColors.backgroundWhite
                              : AppColors.textSecondary,
                        ),
                        onSelected: _busy
                            ? null
                            : (_) => setState(() => _mode = _ShareMode.text),
                      ),
                      ChoiceChip(
                        selected: _mode == _ShareMode.image,
                        label: const Text(AppStrings.shareModeImage),
                        selectedColor: AppColors.primaryTeal,
                        checkmarkColor: AppColors.backgroundWhite,
                        labelStyle: TextStyle(
                          color: _mode == _ShareMode.image
                              ? AppColors.backgroundWhite
                              : AppColors.textSecondary,
                        ),
                        onSelected: _busy
                            ? null
                            : (_) => setState(() => _mode = _ShareMode.image),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_mode == _ShareMode.text) ...[
                    _TextPreviewBox(text: _formattedQuoteText),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _busy ? null : _shareText,
                      icon: const Icon(Icons.share),
                      label: const Text(AppStrings.shareTextButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: AppColors.backgroundWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ] else ...[
                    QuoteCardPreview(
                      quote: widget.quote,
                      style: _style,
                      repaintBoundaryKey: _repaintKey,
                    ),
                    const SizedBox(height: 12),
                    const _SectionTitle(title: AppStrings.shareStyleLabel),
                    const SizedBox(height: 8),
                    QuoteStyleSelector(
                      selected: _style,
                      onChanged: _busy
                          ? (_) {}
                          : (s) => setState(() => _style = s),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _busy ? null : _shareImage,
                            icon: const Icon(Icons.share),
                            label: const Text(AppStrings.shareImageButton),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: AppColors.backgroundWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _busy ? null : _saveImage,
                            icon: const Icon(Icons.download),
                            label: const Text(AppStrings.saveImageButton),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: AppColors.backgroundWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_busy) ...[
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.shadowBlack.withValues(alpha: 0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final bool busy;
  final VoidCallback onClose;

  const _SheetHeader({required this.busy, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            AppStrings.share,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: busy ? null : onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _TextPreviewBox extends StatelessWidget {
  final String text;

  const _TextPreviewBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Text(text, style: const TextStyle(height: 1.35)),
    );
  }
}
