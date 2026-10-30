import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/device_id_utils.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/features/affiliate/data/models/affiliate_dashboard_models.dart';
import 'package:commercepal/features/affiliate/data/repository/affiliate_repository.dart';
import 'package:commercepal/features/affiliate/presentation/bloc/affiliate_dashboard_cubit.dart';
import 'package:commercepal/services/localization_service.dart';

/// "Join the partner program" sheet for a signed-in customer — same fields as
/// commercepal.com/affiliate (name, phone, how you will promote).
class AffiliateRegistrationModal extends StatefulWidget {
  const AffiliateRegistrationModal({
    super.key,
    required this.onRegistrationComplete,
    this.initialName = '',
    this.initialPhone = '',
  });

  final VoidCallback onRegistrationComplete;
  final String initialName;
  final String initialPhone;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRegistrationComplete,
    String initialName = '',
    String initialPhone = '',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (BuildContext context) => AffiliateRegistrationModal(
        onRegistrationComplete: onRegistrationComplete,
        initialName: initialName,
        initialPhone: initialPhone,
      ),
    );
  }

  @override
  State<AffiliateRegistrationModal> createState() =>
      _AffiliateRegistrationModalState();
}

class _AffiliateRegistrationModalState
    extends State<AffiliateRegistrationModal> {
  static final RegExp _etPhone = RegExp(r'^(\+?251|0)?[79]\d{8}$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.initialPhone.replaceFirst(RegExp(r'^\+251'), '0'),
  );
  final AffiliateRepository _repository = AffiliateRepository();
  AffiliatePromotionMethod _method = AffiliatePromotionMethod.socialMedia;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// 09XXXXXXXX / 9XXXXXXXX / 2519XXXXXXXX → +2519XXXXXXXX (web rules).
  static String _normalizePhone(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('251')) return '+$digits';
    if (digits.startsWith('0')) return '+251${digits.substring(1)}';
    if (digits.length == 9) return '+251$digits';
    return '+$digits';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _repository.registerAsCustomer(
        name: _nameController.text,
        phoneNumber: _normalizePhone(_phoneController.text),
        promotionMethod: _method.apiValue,
        registrationChannel: PlatformUtils.getChannel(),
        deviceId: await DeviceIdUtils.getDeviceId(),
      );

      if (!mounted) return;
      AppSnackbars.success(context, context.tr('affiliate.joinSuccess'));
      widget.onRegistrationComplete();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            apiErrorMessage(e) ?? context.tr('affiliate.joinFailed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.gutter,
        right: Spacing.gutter,
        top: Spacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                context.tr('affiliate.joinTitle'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xxs),
              Text(
                context.tr('affiliate.joinSubtitle'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.name],
                decoration: InputDecoration(
                  labelText: context.tr('affiliate.nameLabel'),
                  hintText: context.tr('affiliate.nameHint'),
                ),
                validator: (String? v) => (v ?? '').trim().length < 2
                    ? context.tr('affiliate.nameRequired')
                    : null,
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                autofillHints: const <String>[AutofillHints.telephoneNumber],
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                decoration: InputDecoration(
                  labelText: context.tr('affiliate.phoneLabel'),
                  hintText: '0912345678',
                ),
                validator: (String? v) =>
                    _etPhone.hasMatch((v ?? '').replaceAll(' ', ''))
                        ? null
                        : context.tr('affiliate.phoneInvalid'),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                context.tr('affiliate.promotionQuestion'),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: Spacing.xs),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: <Widget>[
                  for (final AffiliatePromotionMethod m
                      in AffiliatePromotionMethod.values)
                    ChoiceChip(
                      label: Text(context.tr(m.labelKey)),
                      selected: _method == m,
                      onSelected: (_) => setState(() => _method = m),
                    ),
                ],
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: Spacing.sm),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                  ),
                ),
              ],
              const SizedBox(height: Spacing.xl),
              AppButton.primary(
                label: context.tr('affiliate.joinButton'),
                loading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
