import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'product_card.dart';

class DealOfDaySection extends StatefulWidget {
  const DealOfDaySection({super.key});

  @override
  State<DealOfDaySection> createState() => _DealOfDaySectionState();
}

class _DealOfDaySectionState extends State<DealOfDaySection> {
  Duration _remainingTime = const Duration(hours: 22, minutes: 55, seconds: 20);

  @override
  void initState() {
    super.initState();
    // Update timer every second
    Future<void>.delayed(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (!mounted) return;
    setState(() {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        Future<void>.delayed(const Duration(seconds: 1), _updateTimer);
      }
    });
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    return '${hours}h ${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Dark purple header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'home.dealOfDay.title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              InkWell(
                onTap: () {
                  // TODO: Navigate to all deals
                },
                child: Row(
                  children: <Widget>[
                    Text(
                      LocalizationService.t(context, 'home.dealOfDay.viewAll'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Timer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.access_time,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                '${_formatDuration(_remainingTime)} ${LocalizationService.t(context, 'home.dealOfDay.remaining')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
        // Product cards
        Padding(
          padding: const EdgeInsets.only(
            top: Spacing.md,
            bottom: Spacing.md,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ProductCard(
                  imageUrl: '',
                  description: 'Apple Macbook Air MQD32SA/A Silver (2017)',
                  price: '\$904.18',
                  sold: 700,
                  inStock: 300,
                  showProgressBar: true,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: ProductCard(
                  imageUrl: '',
                  description: 'Apple Macbook Air MQD32SA/A Silver (2017)',
                  price: '\$904.18',
                  sold: 700,
                  inStock: 300,
                  showProgressBar: true,
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

