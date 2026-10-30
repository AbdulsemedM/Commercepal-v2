import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/affiliate/data/models/affiliate_dashboard_models.dart';
import 'package:commercepal/features/affiliate/presentation/bloc/affiliate_dashboard_cubit.dart';
import 'package:commercepal/features/affiliate_register/presentation/widgets/affiliate_registration_modal.dart';
import 'package:commercepal/services/localization_service.dart';

/// In-app affiliate dashboard — same data and actions as
/// commercepal.com/affiliate: earnings, referral link, orders, payouts.
class AffiliateDashboardScreen extends StatelessWidget {
  const AffiliateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AffiliateDashboardCubit>(
      create: (_) => AffiliateDashboardCubit()..load(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: context.tr('common.goBack'),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboard);
              }
            },
          ),
          title: Semantics(
            header: true,
            child: Text(context.tr('affiliate.affiliateDashboard')),
          ),
        ),
        body: BlocBuilder<AffiliateDashboardCubit, AffiliateDashboardState>(
          builder: (BuildContext context, AffiliateDashboardState state) {
            if (!state.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!state.isAffiliate) {
              return AppEmptyState(
                icon: Icons.storefront_outlined,
                title: context.tr('affiliate.joinTitle'),
                subtitle: context.tr('affiliate.notAffiliateSubtitle'),
                primaryLabel: context.tr('affiliate.joinButton'),
                onPrimary: () => AffiliateRegistrationModal.show(
                  context,
                  onRegistrationComplete:
                      context.read<AffiliateDashboardCubit>().load,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: context.read<AffiliateDashboardCubit>().load,
              child: _DashboardBody(state: state),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state});

  final AffiliateDashboardState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String firstName =
        (state.profile?.fullName ?? '').trim().split(' ').first;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        Spacing.gutter,
        Spacing.md,
        Spacing.gutter,
        Spacing.xxl + MediaQuery.paddingOf(context).bottom,
      ),
      children: <Widget>[
        Text(
          firstName.isEmpty
              ? context.tr('affiliate.welcomeBack')
              : context.tr('affiliate.welcomeBackName', {'name': firstName}),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          context.tr('affiliate.dashboardSubtitle'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        _StatsGrid(state: state),
        if (state.reserved > 0) ...<Widget>[
          const SizedBox(height: Spacing.xs),
          Text(
            context.tr('affiliate.reservedNote', {
              'amount': MoneyFormatter.format(state.reserved, 'ETB'),
            }),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: Spacing.lg),
        _ReferralLinkCard(link: state.referralLink),
        const SizedBox(height: Spacing.md),
        _WithdrawCard(available: state.availableBalance),
        const SizedBox(height: Spacing.xl),
        _SectionTitle(
          title: context.tr('affiliate.earningsTitle'),
          subtitle: context.tr('affiliate.earningsSubtitle'),
        ),
        const SizedBox(height: Spacing.sm),
        if (state.earnings.isEmpty)
          _EmptyNote(text: context.tr('affiliate.earningsEmpty'))
        else
          for (final AffiliateOrderEarning e in state.earnings)
            _EarningTile(earning: e),
        const SizedBox(height: Spacing.xl),
        _SectionTitle(
          title: context.tr('affiliate.withdrawalsTitle'),
          subtitle: context.tr('affiliate.withdrawalsSubtitle'),
        ),
        const SizedBox(height: Spacing.sm),
        if (state.withdrawals.isEmpty)
          _EmptyNote(text: context.tr('affiliate.withdrawalsEmpty'))
        else
          for (final AffiliateWithdrawal w in state.withdrawals)
            _WithdrawalTile(withdrawal: w),
      ],
    );
  }
}

String _formatDate(String? iso) {
  if (iso == null) return '—';
  final DateTime? date = DateTime.tryParse(iso);
  return date == null ? iso : DateFormat('d MMM y').format(date.toLocal());
}

/// `PENDING_PAYMENT` → `Pending Payment`.
String _humanize(String value) => value
    .toLowerCase()
    .split('_')
    .where((String w) => w.isNotEmpty)
    .map((String w) => '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.state});

  final AffiliateDashboardState state;

  @override
  Widget build(BuildContext context) {
    String money(num v) =>
        state.loading ? '…' : MoneyFormatter.format(v, 'ETB');
    final List<Widget> tiles = <Widget>[
      _StatTile(
        icon: Icons.trending_up_rounded,
        label: context.tr('affiliate.statTotalEarned'),
        value: money(state.totalEarned),
      ),
      _StatTile(
        icon: Icons.account_balance_wallet_outlined,
        label: context.tr('affiliate.statAvailable'),
        value: money(state.availableBalance),
        highlight: true,
      ),
      _StatTile(
        icon: Icons.payments_outlined,
        label: context.tr('affiliate.statWithdrawn'),
        value: money(state.withdrawn),
      ),
      _StatTile(
        icon: Icons.shopping_bag_outlined,
        label: context.tr('affiliate.statTotalOrders'),
        value: state.loading ? '…' : '${state.totalOrders}',
      ),
    ];
    return Column(
      children: <Widget>[
        for (int i = 0; i < tiles.length; i += 2) ...<Widget>[
          if (i > 0) const SizedBox(height: Spacing.xs),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: tiles[i]),
                const SizedBox(width: Spacing.xs),
                Expanded(child: tiles[i + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: AppSizes.iconMd, color: scheme.primary),
            const SizedBox(height: Spacing.xs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xxs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlight ? context.commerce.success : null,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralLinkCard extends StatelessWidget {
  const _ReferralLinkCard({required this.link});

  final String link;

  Future<void> _open(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool ready = link.isNotEmpty;
    final String message = context.tr('affiliate.shareMessage', {'link': link});
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              context.tr('affiliate.yourReferralLink'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: AppRadius.smAll,
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(
                  ready ? link : context.tr('affiliate.linkUnavailable'),
                  maxLines: 2,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton.primary(
                    label: context.tr('affiliate.copyLink'),
                    icon: Icons.copy_rounded,
                    size: AppButtonSize.medium,
                    onPressed: !ready
                        ? null
                        : () {
                            Clipboard.setData(ClipboardData(text: link));
                            AppSnackbars.success(
                              context,
                              context.tr('affiliate.linkCopied'),
                            );
                          },
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: AppButton.secondary(
                    label: context.tr('affiliate.shareLink'),
                    icon: Icons.share_outlined,
                    size: AppButtonSize.medium,
                    onPressed: !ready ? null : () => Share.share(message),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.tonal,
                    label: 'WhatsApp',
                    icon: Icons.chat_outlined,
                    size: AppButtonSize.medium,
                    onPressed: !ready
                        ? null
                        : () => _open(
                              Uri.parse(
                                'https://wa.me/?text=${Uri.encodeComponent(message)}',
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.tonal,
                    label: 'Telegram',
                    icon: Icons.send_outlined,
                    size: AppButtonSize.medium,
                    onPressed: !ready
                        ? null
                        : () => _open(
                              Uri.parse(
                                'https://t.me/share/url?url=${Uri.encodeComponent(link)}',
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawCard extends StatelessWidget {
  const _WithdrawCard({required this.available});

  final num available;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              context.tr('affiliate.withdrawTitle'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              context.tr('affiliate.withdrawSubtitle'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            AppButton.secondary(
              label: context.tr('affiliate.requestWithdrawal'),
              icon: Icons.account_balance_outlined,
              size: AppButtonSize.medium,
              onPressed: () => _WithdrawalSheet.show(context, available),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EarningTile extends StatelessWidget {
  const _EarningTile({required this.earning});

  final AffiliateOrderEarning earning;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle? muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        earning.customerName.isEmpty
                            ? earning.orderRef
                            : earning.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        context.tr('affiliate.placedOn', {
                          'date': _formatDate(
                            earning.orderedAt ?? earning.earnedAt,
                          ),
                        }),
                        style: muted,
                      ),
                    ],
                  ),
                ),
                AppBadge(
                  label: earning.orderStatus == null
                      ? context.tr('affiliate.orderUnavailable')
                      : _humanize(earning.orderStatus!),
                  tone: AppBadgeTone.info,
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: _LabeledValue(
                    label: context.tr('affiliate.orderValue'),
                    value: MoneyFormatter.format(
                      earning.orderAmount,
                      earning.currency,
                    ),
                  ),
                ),
                Expanded(
                  child: _LabeledValue(
                    label: context.tr('affiliate.youEarned'),
                    value: MoneyFormatter.format(
                      earning.commissionAmount,
                      earning.currency,
                    ),
                    valueColor: context.commerce.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                if (earning.earningStatus != null)
                  AppBadge(
                    label: _humanize(earning.earningStatus!),
                    tone: AppBadgeTone.warning,
                  ),
                Text(
                  context.tr('affiliate.paymentStatus', {
                    'status': earning.paymentStatus == null
                        ? context.tr('affiliate.unavailable')
                        : _humanize(earning.paymentStatus!),
                  }),
                  style: muted,
                ),
              ],
            ),
            if (earning.remainingUnpaidAmount > 0) ...<Widget>[
              const SizedBox(height: Spacing.xxs),
              Text(
                context.tr('affiliate.availableAmount', {
                  'amount': MoneyFormatter.format(
                    earning.remainingUnpaidAmount,
                    earning.currency,
                  ),
                }),
                style: muted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  const _WithdrawalTile({required this.withdrawal});

  final AffiliateWithdrawal withdrawal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final AffiliateWithdrawal w = withdrawal;
    final (AppBadgeTone tone, String note) = switch (w.status) {
      'PAID' => (
          AppBadgeTone.success,
          context.tr('affiliate.statusPaidNote', {
            'date': w.paidAt == null ? '' : _formatDate(w.paidAt),
          }).trim(),
        ),
      'APPROVED' => (
          AppBadgeTone.info,
          context.tr('affiliate.statusApprovedNote'),
        ),
      'REJECTED' => (
          AppBadgeTone.error,
          w.rejectionReason ?? context.tr('affiliate.statusRejectedNote'),
        ),
      _ => (AppBadgeTone.warning, context.tr('affiliate.statusPendingNote')),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        MoneyFormatter.format(w.amount, 'ETB'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: AppTypography.tabularFigures,
                        ),
                      ),
                      Text(
                        context.tr('affiliate.requestedOn', {
                          'date': _formatDate(w.requestedAt),
                        }),
                        style: muted,
                      ),
                    ],
                  ),
                ),
                AppBadge(label: _humanize(w.status), tone: tone),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              context.tr('affiliate.payoutDestination', {
                'method': w.paymentMethod == null
                    ? '—'
                    : _humanize(w.paymentMethod!),
                'account': w.maskedAccount.isEmpty ? '—' : w.maskedAccount,
              }),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.xxs),
            Text(note, style: muted),
            if (w.payoutReference != null)
              Text(
                context.tr('affiliate.payoutReference', {
                  'ref': w.payoutReference,
                }),
                style: muted,
              ),
            if (w.adminNotes != null)
              Text(
                context.tr('affiliate.financeNote', {'note': w.adminNotes}),
                style: muted,
              ),
          ],
        ),
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
      ],
    );
  }
}

class _WithdrawalSheet extends StatefulWidget {
  const _WithdrawalSheet({required this.cubit, required this.available});

  final AffiliateDashboardCubit cubit;
  final num available;

  static Future<void> show(BuildContext context, num available) {
    final AffiliateDashboardCubit cubit =
        context.read<AffiliateDashboardCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => _WithdrawalSheet(cubit: cubit, available: available),
    );
  }

  @override
  State<_WithdrawalSheet> createState() => _WithdrawalSheetState();
}

class _WithdrawalSheetState extends State<_WithdrawalSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  AffiliatePayoutMethod _method = AffiliatePayoutMethod.telebirr;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final String? error = await widget.cubit.requestWithdrawal(
      amount: num.parse(_amountController.text.trim()),
      method: _method,
      accountNumber: _accountController.text,
    );
    if (!mounted) return;
    if (error == null) {
      AppSnackbars.success(context, context.tr('affiliate.withdrawSuccess'));
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _submitting = false;
      _error = error.isEmpty ? context.tr('affiliate.withdrawFailed') : error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.gutter,
        right: Spacing.gutter,
        top: Spacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                context.tr('affiliate.requestWithdrawal'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xxs),
              Text(
                context.tr('affiliate.availableAmount', {
                  'amount': MoneyFormatter.format(widget.available, 'ETB'),
                }),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: context.tr('affiliate.amountLabel'),
                  prefixText: 'ETB ',
                ),
                validator: (String? v) {
                  final num? amount = num.tryParse((v ?? '').trim());
                  return (amount == null || amount <= 0)
                      ? context.tr('affiliate.amountInvalid')
                      : null;
                },
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                context.tr('affiliate.payoutMethod'),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: Spacing.xs),
              Wrap(
                spacing: Spacing.xs,
                children: <Widget>[
                  for (final AffiliatePayoutMethod m
                      in AffiliatePayoutMethod.values)
                    ChoiceChip(
                      label: Text(context.tr(m.labelKey)),
                      selected: _method == m,
                      onSelected: (_) => setState(() => _method = m),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _accountController,
                keyboardType: _method == AffiliatePayoutMethod.cbe
                    ? TextInputType.number
                    : TextInputType.phone,
                decoration: InputDecoration(
                  labelText: context.tr('affiliate.accountLabel'),
                  hintText: '0912345678',
                ),
                validator: (String? v) => (v ?? '').trim().length < 5
                    ? context.tr('affiliate.accountInvalid')
                    : null,
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: Spacing.sm),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                  ),
                ),
              ],
              const SizedBox(height: Spacing.xl),
              AppButton.primary(
                label: context.tr('affiliate.submitWithdrawal'),
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
