import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../services/localization_service.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../bloc/payment_status_cubit.dart';

/// Starts payment status polling and shows waiting / success / failed UI.
class PaymentStatusPollingBanner extends StatefulWidget {
  const PaymentStatusPollingBanner({
    super.key,
    required this.orderNumber,
    this.onSuccess,
    this.onFailed,
    this.clearCartOnSuccess = false,
  });

  final String orderNumber;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailed;
  final bool clearCartOnSuccess;

  @override
  State<PaymentStatusPollingBanner> createState() =>
      _PaymentStatusPollingBannerState();
}

class _PaymentStatusPollingBannerState extends State<PaymentStatusPollingBanner>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<PaymentStatusCubit>().startPolling(widget.orderNumber);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    context.read<PaymentStatusCubit>().checkNow();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentStatusCubit, PaymentStatusState>(
      listener: (BuildContext context, PaymentStatusState state) {
        if (state is PaymentStatusSuccess) {
          if (widget.clearCartOnSuccess) {
            context.read<CartBloc>().add(CartClearRequested());
          }
          widget.onSuccess?.call();
        } else if (state is PaymentStatusFailed ||
            state is PaymentStatusTimeout) {
          widget.onFailed?.call();
        }
      },
      builder: (BuildContext context, PaymentStatusState state) {
        if (state is PaymentStatusSuccess) {
          return _StatusBanner(
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            title: LocalizationService.t(
              context,
              'checkout.paymentStatusSuccessTitle',
            ),
            body: LocalizationService.t(
              context,
              'checkout.paymentStatusSuccessBody',
            ),
          );
        }
        if (state is PaymentStatusFailed) {
          return _StatusBanner(
            icon: Icons.error_outline,
            color: AppColors.error,
            title: LocalizationService.t(
              context,
              'checkout.paymentStatusFailedTitle',
            ),
            body: LocalizationService.t(
              context,
              'checkout.paymentStatusFailedBody',
            ),
          );
        }
        if (state is PaymentStatusTimeout) {
          return _StatusBanner(
            icon: Icons.schedule_outlined,
            color: AppColors.warning,
            title: LocalizationService.t(
              context,
              'checkout.paymentStatusTimeoutTitle',
            ),
            body: LocalizationService.t(
              context,
              'checkout.paymentStatusTimeoutBody',
            ),
          );
        }
        if (state is PaymentStatusPolling) {
          return _StatusBanner(
            icon: Icons.sync,
            color: AppColors.primary,
            title: LocalizationService.t(
              context,
              'checkout.paymentStatusPollingTitle',
            ),
            body: LocalizationService.t(
              context,
              'checkout.paymentStatusPollingBody',
            ),
            showProgress: true,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.showProgress = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: color, size: 22),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: Spacing.sm),
            const LinearProgressIndicator(minHeight: 3),
          ],
        ],
      ),
    );
  }
}

void navigateOnPaymentStatusSuccess(
  BuildContext context, {
  bool clearCart = false,
}) {
  if (clearCart) {
    try {
      context.read<CartBloc>().add(CartClearRequested());
    } catch (_) {
      // CartBloc may not be in scope on some routes.
    }
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        LocalizationService.t(context, 'checkout.paymentStatusSuccessBody'),
      ),
    ),
  );
  context.go(AppRoutes.orderHistory);
}
