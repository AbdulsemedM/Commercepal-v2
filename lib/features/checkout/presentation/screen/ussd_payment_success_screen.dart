import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter/material.dart';

/// Full-screen confirmation pushed after successful USSD initiation
/// (Telebirr, eBirr Coopay/Kaffi, Sahay Pay, Pesapal).
/// Pushed on the nav stack so the user always sees the confirmation on success.
class UssdPaymentSuccessScreen extends StatelessWidget {
  const UssdPaymentSuccessScreen({
    super.key,
    this.orderNumber,
  });

  final String? orderNumber;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors commerce = context.commerce;
    final bool hasOrderNumber = orderNumber != null && orderNumber!.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            CheckoutScreenHeader(
              title: context.tr('checkout.payment'),
              showBack: false,
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
                                color: commerce.successContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.phone_iphone_rounded,
                                size: 44,
                                color: commerce.success,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        Semantics(
                          header: true,
                          child: Text(
                            context.tr('checkout.ussdSuccessTitle'),
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          context.tr('checkout.ussdSuccessMessage'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.xl),
                        Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Semantics(
                                  liveRegion: true,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: AppSizes.iconMd,
                                        color: commerce.success,
                                      ),
                                      const SizedBox(width: Spacing.xs),
                                      Expanded(
                                        child: Text(
                                          context.tr(
                                            'checkout.ussdSuccessOrderPlaced',
                                          ),
                                          style: theme.textTheme.titleSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasOrderNumber) ...<Widget>[
                                  const Divider(height: Spacing.xl),
                                  Text(
                                    context
                                        .tr('checkout.orderPlaced.orderNumber'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.xxs),
                                  SelectableText(
                                    orderNumber!,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontFeatures:
                                          AppTypography.tabularFigures,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
                      child: AppButton.primary(
                        label: context.tr('checkout.ussdSuccessContinue'),
                        onPressed: () => Navigator.of(context).pop(),
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
