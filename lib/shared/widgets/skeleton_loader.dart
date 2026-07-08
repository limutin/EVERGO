import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Skeleton loader widget for loading states
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.cardDark,
                Color(0xFF2A2D3A),
                AppColors.cardDark,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for text lines
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsets? margin;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: 4,
      margin: margin,
    );
  }
}

/// Skeleton loader for circular avatars
class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({
    super.key,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

/// Skeleton loader for cards
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsets? margin;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 100,
    this.margin,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
    );
  }
}

/// Skeleton for profile stats
class SkeletonProfileStats extends StatelessWidget {
  const SkeletonProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SkeletonCard(
            height: 85,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        Expanded(
          child: SkeletonCard(
            height: 85,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        Expanded(
          child: SkeletonCard(
            height: 85,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ],
    );
  }
}

/// Skeleton for bus card
class SkeletonBusCard extends StatelessWidget {
  const SkeletonBusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Row(
        children: [
          const SkeletonLoader(width: 48, height: 48, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 100, height: 16),
                const SizedBox(height: 6),
                SkeletonText(width: 150, height: 12),
                const SizedBox(height: 8),
                SkeletonText(width: 120, height: 10),
              ],
            ),
          ),
          const SkeletonLoader(width: 60, height: 32, borderRadius: 8),
        ],
      ),
    );
  }
}
/// Skeleton for list items
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const SkeletonLoader(width: 20, height: 20, borderRadius: 4),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 150, height: 14),
                const SizedBox(height: 4),
                SkeletonText(width: 100, height: 11),
              ],
            ),
          ),
          const SkeletonLoader(width: 14, height: 14, borderRadius: 2),
        ],
      ),
    );
  }
}
