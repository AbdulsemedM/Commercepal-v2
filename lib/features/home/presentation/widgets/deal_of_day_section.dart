import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/widgets/app_dialog.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:commercepal/services/localization_service.dart';

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

  Widget _buildDealDialogContent(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'We are curating today\'s best offers for you.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _DialogFeatureRow(
                icon: Icons.bolt,
                text: 'Flash discounts from trusted stores',
              ),
              const SizedBox(height: Spacing.xs),
              _DialogFeatureRow(
                icon: Icons.schedule,
                text: 'Fresh picks updated every day',
              ),
              const SizedBox(height: Spacing.xs),
              _DialogFeatureRow(
                icon: Icons.auto_awesome,
                text: 'Personalized deal recommendations',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openDealDialog() {
    AppDialog.show<void>(
      context,
      icon: const Icon(Icons.workspace_premium_outlined),
      title: 'Deal of the Day is almost ready',
      content: _buildDealDialogContent(context),
      actions: const <AppDialogAction>[
        AppDialogAction(label: 'Not now'),
        AppDialogAction(label: 'Close', isPrimary: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomeSectionHeader(
            title: LocalizationService.t(context, 'home.dealOfDay.title'),
            actionLabel:
                LocalizationService.t(context, 'home.dealOfDay.viewAll'),
            onAction: _openDealDialog,
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              gradient: AppDecorations.heroGradient,
              borderRadius: AppDecorations.cardBorderRadius,
              boxShadow: AppDecorations.softCardShadow(),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    '${_formatDuration(_remainingTime)} ${LocalizationService.t(context, 'home.dealOfDay.remaining')}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: _openDealDialog,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    LocalizationService.t(context, 'home.dealOfDay.viewAll'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
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

class _DialogFeatureRow extends StatelessWidget {
  const _DialogFeatureRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.3,
                ),
          ),
        ),
      ],
    );
  }
}
