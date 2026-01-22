import 'package:flutter/material.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:quote_vault/core/widgets/shimmer.dart';

class QuoteOfTheDayShimmer extends StatelessWidget {
  const QuoteOfTheDayShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.lightTeal.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack.withValues(alpha: 0.08),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 12, width: 120, borderRadius: 8),
          SizedBox(height: 14),
          ShimmerBox(height: 18, width: double.infinity, borderRadius: 10),
          SizedBox(height: 10),
          ShimmerBox(height: 18, width: 260, borderRadius: 10),
          SizedBox(height: 16),
          ShimmerBox(height: 14, width: 140, borderRadius: 10),
          SizedBox(height: 20),
          ShimmerBox(height: 40, width: 120, borderRadius: 16),
        ],
      ),
    );
  }
}

class QuoteCardShimmer extends StatelessWidget {
  const QuoteCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        children: [
          SizedBox(height: 10),
          ShimmerBox(height: 16, width: double.infinity, borderRadius: 10),
          SizedBox(height: 10),
          ShimmerBox(height: 16, width: 280, borderRadius: 10),
          SizedBox(height: 10),
          ShimmerBox(height: 16, width: 220, borderRadius: 10),
          SizedBox(height: 18),
          Row(
            children: [
              ShimmerBox(height: 32, width: 32, borderRadius: 16),
              SizedBox(width: 10),
              Expanded(
                child: ShimmerBox(
                  height: 14,
                  width: double.infinity,
                  borderRadius: 10,
                ),
              ),
              SizedBox(width: 14),
              ShimmerBox(height: 20, width: 20, borderRadius: 6),
              SizedBox(width: 12),
              ShimmerBox(height: 20, width: 20, borderRadius: 6),
              SizedBox(width: 12),
              ShimmerBox(height: 20, width: 20, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryChipsShimmer extends StatelessWidget {
  const CategoryChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final width = switch (index) {
            0 => 56.0,
            1 => 82.0,
            2 => 72.0,
            3 => 92.0,
            4 => 66.0,
            5 => 86.0,
            _ => 74.0,
          };
          return ShimmerBox(height: 36, width: width, borderRadius: 24);
        },
      ),
    );
  }
}
