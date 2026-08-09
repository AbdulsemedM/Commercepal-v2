import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/features/products/bloc/price_alert_cubit.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/localization_service.dart';

class PriceAlertButton extends StatelessWidget {
  const PriceAlertButton({
    super.key,
    required this.productId,
    required this.currentPrice,
    required this.currency,
  });

  final String productId;
  final double currentPrice;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PriceAlertCubit(productId: productId)..load(),
      child: BlocConsumer<PriceAlertCubit, PriceAlertState>(
        listener: (BuildContext context, PriceAlertState state) {
          if (state is PriceAlertError) {
            final String message = state.localizationKey != null
                ? LocalizationService.t(context, state.localizationKey!)
                : state.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (BuildContext context, PriceAlertState state) {
          final bool isActive = state is PriceAlertActive;
          final bool isLoading = state is PriceAlertLoading;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _onPressed(context, isActive, state),
              icon: Icon(
                isActive
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_outlined,
                size: 20,
              ),
              label: Text(
                isActive
                    ? LocalizationService.t(context, 'priceAlert.active')
                    : LocalizationService.t(context, 'priceAlert.set'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: BorderSide(
                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                  width: isActive ? 2 : 1,
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPressed(
    BuildContext context,
    bool isActive,
    PriceAlertState state,
  ) async {
    if (!AuthService().isLoggedIn) {
      final bool? goLogin = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: Text(LocalizationService.t(ctx, 'priceAlert.loginRequired')),
          content: Text(
            LocalizationService.t(ctx, 'priceAlert.loginRequiredBody'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(LocalizationService.t(ctx, 'profile.cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(LocalizationService.t(ctx, 'auth.login.loginButton')),
            ),
          ],
        ),
      );
      if (goLogin == true && context.mounted) {
        context.push(AppRoutes.login);
      }
      return;
    }

    if (isActive && state is PriceAlertActive) {
      await context.read<PriceAlertCubit>().removeAlert();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.t(context, 'priceAlert.removed'),
            ),
          ),
        );
      }
      return;
    }

    final double defaultTarget = currentPrice > 0
        ? (currentPrice * 0.9)
        : 0;
    final double? target = await _showTargetPriceSheet(
      context,
      initialTarget: defaultTarget,
    );
    if (target == null || !context.mounted) return;
    await context.read<PriceAlertCubit>().setAlert(target);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.t(context, 'priceAlert.saved'),
          ),
        ),
      );
    }
  }

  Future<double?> _showTargetPriceSheet(
    BuildContext context, {
    required double initialTarget,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initialTarget > 0
          ? initialTarget.toStringAsFixed(2)
          : '',
    );
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: Spacing.lg,
            right: Spacing.lg,
            top: Spacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                LocalizationService.t(ctx, 'priceAlert.targetTitle'),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: LocalizationService.t(
                    ctx,
                    'priceAlert.targetLabel',
                  ),
                  prefixText: currency.isNotEmpty ? '$currency ' : null,
                ),
              ),
              const SizedBox(height: Spacing.md),
              FilledButton(
                onPressed: () {
                  final double? value = double.tryParse(controller.text.trim());
                  Navigator.of(ctx).pop(value);
                },
                child: Text(LocalizationService.t(ctx, 'priceAlert.confirm')),
              ),
            ],
          ),
        );
      },
    );
  }
}
