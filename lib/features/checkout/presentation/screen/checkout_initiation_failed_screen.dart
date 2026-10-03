import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../services/localization_service.dart';

/// Full-screen error when checkout returns without a valid [paymentInitiation]
/// and there is no [paymentReference] to send the user to retry payment.
class CheckoutInitiationFailedScreen extends StatelessWidget {
  const CheckoutInitiationFailedScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    // Mirror AppBar's implied leading: only show back when we can pop.
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            CheckoutScreenHeader(
              title: context.tr('checkout.checkout'),
              showBack: canPop,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    Spacing.gutter,
                    Spacing.md,
                    Spacing.gutter,
                    Spacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(
                          child: ExcludeSemantics(
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: scheme.errorContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                size: 44,
                                color: scheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        Semantics(
                          header: true,
                          child: Text(
                            context.tr('checkout.paymentCouldNotStartTitle'),
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: commerce.border)),
              ),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        Spacing.gutter,
                        Spacing.sm,
                        Spacing.gutter,
                        Spacing.sm,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AppButton.primary(
                            label: context.tr('checkout.tryAgain'),
                            icon: Icons.refresh_rounded,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: Spacing.xs),
                          AppButton.secondary(
                            label: context.tr('checkout.backToCart'),
                            size: AppButtonSize.medium,
                            onPressed: () =>
                                context.go('${AppRoutes.dashboard}?tab=2'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
