import 'package:flutter/material.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

class PersistentBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PersistentBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home,
                label: AppStrings.navHome,
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.favorite,
                label: AppStrings.navFavorites,
                index: 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.collections_bookmark,
                label: AppStrings.navCollections,
                index: 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.settings,
                label: AppStrings.navSettings,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
