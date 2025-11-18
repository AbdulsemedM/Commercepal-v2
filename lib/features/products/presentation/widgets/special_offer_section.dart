import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class SpecialOfferSection extends StatefulWidget {
  const SpecialOfferSection({
    super.key,
    required this.sold,
    required this.inStock,
    required this.initialDuration,
  });

  final int sold;
  final int inStock;
  final Duration initialDuration;

  @override
  State<SpecialOfferSection> createState() => _SpecialOfferSectionState();
}

class _SpecialOfferSectionState extends State<SpecialOfferSection> {
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;
    _startTimer();
  }

  void _startTimer() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
          _startTimer();
        }
      });
    });
  }

  String _formatTimerValue(int value) {
    return value.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final int days = _remainingTime.inDays;
    final int hours = _remainingTime.inHours.remainder(24);
    final int minutes = _remainingTime.inMinutes.remainder(60);
    final int seconds = _remainingTime.inSeconds.remainder(60);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Text(
            '${LocalizationService.t(context, 'productDetail.specialOffer')}:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.sold / (widget.sold + widget.inStock),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.success,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          // Sold/In Stock info
          Text(
            '${LocalizationService.t(context, 'home.dealOfDay.sold')}: ${widget.sold} ${LocalizationService.t(context, 'home.dealOfDay.inStock')}: ${widget.inStock}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: Spacing.md),
          // Countdown timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTimerSegment(
                context,
                _formatTimerValue(days),
                LocalizationService.t(context, 'productDetail.day'),
              ),
              const Text(' : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildTimerSegment(
                context,
                _formatTimerValue(hours),
                LocalizationService.t(context, 'productDetail.hours'),
              ),
              const Text(' : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildTimerSegment(
                context,
                _formatTimerValue(minutes),
                LocalizationService.t(context, 'productDetail.min'),
              ),
              const Text(' : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildTimerSegment(
                context,
                _formatTimerValue(seconds),
                LocalizationService.t(context, 'productDetail.sec'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSegment(BuildContext context, String value, String label) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

