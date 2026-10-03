import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design_system.dart';
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
        final _BannerTone? tone = switch (state) {
          PaymentStatusSuccess() => _BannerTone.success,
          PaymentStatusFailed() => _BannerTone.error,
          PaymentStatusTimeout() => _BannerTone.warning,
          PaymentStatusPolling() => _BannerTone.info,
          _ => null,
        };
        final Widget child = switch (tone) {
          _BannerTone.success => _StatusBanner(
              key: const ValueKey<String>('success'),
              tone: _BannerTone.success,
              icon: Icons.check_circle_outline_rounded,
              title: context.tr('checkout.paymentStatusSuccessTitle'),
              body: context.tr('checkout.paymentStatusSuccessBody'),
            ),
          _BannerTone.error => _StatusBanner(
              key: const ValueKey<String>('failed'),
              tone: _BannerTone.error,
              icon: Icons.error_outline_rounded,
              title: context.tr('checkout.paymentStatusFailedTitle'),
              body: context.tr('checkout.paymentStatusFailedBody'),
            ),
          _BannerTone.warning => _StatusBanner(
              key: const ValueKey<String>('timeout'),
              tone: _BannerTone.warning,
              icon: Icons.schedule_rounded,
              title: context.tr('checkout.paymentStatusTimeoutTitle'),
              body: context.tr('checkout.paymentStatusTimeoutBody'),
            ),
          _BannerTone.info => _StatusBanner(
              key: const ValueKey<String>('polling'),
              tone: _BannerTone.info,
              icon: Icons.sync_rounded,
              title: context.tr('checkout.paymentStatusPollingTitle'),
              body: context.tr('checkout.paymentStatusPollingBody'),
              showProgress: true,
            ),
          null => const SizedBox.shrink(key: ValueKey<String>('idle')),
        };
        return AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.medium,
          switchInCurve: AppMotion.standard,
          switchOutCurve: AppMotion.exit,
          child: child,
        );
      },
    );
  }
}

enum _BannerTone { info, success, warning, error }

/// Tone-coloured status row: icon, title, body and an optional progress bar.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.body,
    this.showProgress = false,
  });

  final _BannerTone tone;
  final IconData icon;
  final String title;
  final String body;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    final (Color accent, Color container, Color onContainer) = switch (tone) {
      _BannerTone.info => (
          commerce.info,
          commerce.infoContainer,
          commerce.onInfoContainer,
        ),
      _BannerTone.success => (
          commerce.success,
          commerce.successContainer,
          commerce.onSuccessContainer,
        ),
      _BannerTone.warning => (
          commerce.warning,
          commerce.warningContainer,
          commerce.onWarningContainer,
        ),
      _BannerTone.error => (
          scheme.error,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
    };

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: container,
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, color: accent, size: AppSizes.iconMd),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: onContainer,
                        ),
                      ),
                      const SizedBox(height: Spacing.xxs),
                      Text(
                        body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showProgress) ...[
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: AppRadius.pillAll,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: accent,
                  backgroundColor: accent.withValues(alpha: 0.16),
                ),
              ),
            ],
          ],
        ),
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
  AppSnackbars.success(
    context,
    context.tr('checkout.paymentStatusSuccessBody'),
  );
  context.go(AppRoutes.orderHistory);
}
