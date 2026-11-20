import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

import 'express_checkout_repository.dart';

/// Market → (country code, dial code, local length, example).
class _Market {
  const _Market(this.country, this.dial, this.localLength, this.example);
  final String country;
  final String dial;
  final int localLength;
  final String example;
}

const Map<String, _Market> _markets = <String, _Market>{
  'ET': _Market('ET', '251', 9, '911 234 567'),
  'KE': _Market('KE', '254', 9, '712 345 678'),
  'SO': _Market('SO', '252', 8, '6123 4567'),
  'AE': _Market('AE', '971', 9, '50 123 4567'),
};

/// Shopping market from the cart currency (KES → Kenya, …); Ethiopia otherwise.
String marketForCurrency(String? currency) {
  switch ((currency ?? '').toUpperCase()) {
    case 'KES':
      return 'KE';
    case 'SOS':
      return 'SO';
    case 'AED':
      return 'AE';
    default:
      return 'ET';
  }
}

/// Bottom sheet: "Checkout with your phone" (name + phone, no code).
/// Returns `true` when the express session started, or `'signIn'` when the
/// shopper chose to sign in instead.
Future<Object?> showExpressCheckoutSheet(
  BuildContext context, {
  required String currency,
}) {
  return showModalBottomSheet<Object?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: _ExpressCheckoutForm(market: _markets[marketForCurrency(currency)]!),
    ),
  );
}

class _ExpressCheckoutForm extends StatefulWidget {
  const _ExpressCheckoutForm({required this.market});

  final _Market market;

  @override
  State<_ExpressCheckoutForm> createState() => _ExpressCheckoutFormState();
}

class _ExpressCheckoutFormState extends State<_ExpressCheckoutForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  String get _localDigits {
    String digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(widget.market.dial)) {
      digits = digits.substring(widget.market.dial.length);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  bool get _canSubmit =>
      !_submitting &&
      _name.text.trim().isNotEmpty &&
      _localDigits.length == widget.market.localLength;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ExpressCheckoutRepository().start(
        firstName: _name.text,
        phoneNumber: '+${widget.market.dial}$_localDigits',
        countryCode: widget.market.country,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (e) {
      final Object? data = e.response?.data;
      final String? serverMessage =
          data is Map<String, dynamic> ? data['message'] as String? : null;
      setState(() => _error = serverMessage ??
          LocalizationService.t(context, 'expressCheckout.failed'));
    } catch (_) {
      setState(
        () => _error = LocalizationService.t(context, 'expressCheckout.failed'),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.lg,
        Spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocalizationService.t(context, 'expressCheckout.title'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            LocalizationService.t(context, 'expressCheckout.subtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            autofillHints: const <String>[AutofillHints.givenName],
            maxLength: 60,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: LocalizationService.t(context, 'expressCheckout.name'),
              counterText: '',
            ),
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            autofillHints: const <String>[AutofillHints.telephoneNumberNational],
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s+]')),
              LengthLimitingTextInputFormatter(16),
            ],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText:
                  LocalizationService.t(context, 'expressCheckout.phone'),
              prefixText: '+${widget.market.dial} ',
              hintText: widget.market.example,
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: Spacing.sm),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: Spacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canSubmit ? _submit : null,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      LocalizationService.t(context, 'expressCheckout.continue'),
                    ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Center(
            child: TextButton(
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).pop('signIn'),
              child: Text(
                LocalizationService.t(context, 'expressCheckout.signInInstead'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
