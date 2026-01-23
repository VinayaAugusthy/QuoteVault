import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const CollectionCard({super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ) ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}
