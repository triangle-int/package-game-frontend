import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';

class BuildPanelItem extends StatelessWidget {
  const BuildPanelItem({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.details,
    required this.canBuild,
    this.isBusy = false,
    this.isDemolition = false,
    required this.onPressed,
    required this.price,
  });

  final String emoji;
  final String title;
  final String description;
  final String details;
  final bool canBuild;
  final bool isBusy;
  final bool isDemolition;
  final VoidCallback onPressed;
  final int price;

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    EmojiImage(emoji: emoji, size: 38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(title,
                          style: Theme.of(sheetContext).textTheme.titleLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppText(details,
                    style: Theme.of(sheetContext).textTheme.bodyMedium),
                if (!canBuild || isBusy) ...[
                  const SizedBox(height: 12),
                  AppText(
                      isBusy ? 'Construction in progress' : 'Not enough money',
                      style: TextStyle(color: colors.error)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: canBuild && !isBusy
                      ? () {
                          Navigator.of(sheetContext).pop();
                          onPressed();
                        }
                      : null,
                  child: AppText(isDemolition
                      ? 'Select building'
                      : 'Build for ${price.toCurrency()} 💵'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 156,
        child: Material(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showDetails(context),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    EmojiImage(emoji: emoji, size: 28),
                    const SizedBox(width: 7),
                    Expanded(
                      child: AppText(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Expanded(
                    child: AppText(description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: colors.onSurfaceVariant)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          isDemolition ? 'Select' : '${price.toCurrency()} 💵',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: canBuild
                                  ? colors.primary
                                  : colors.onSurfaceVariant),
                        ),
                      ),
                      Icon(Icons.info_outline_rounded,
                          size: 17, color: colors.onSurfaceVariant),
                    ],
                  ),
                  if (!canBuild || isBusy)
                    AppText(isBusy ? 'Building…' : 'Not enough money',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: colors.error)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
