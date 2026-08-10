import '../data_provider/payment_methods_data_provider.dart';
import '../models/payment_constants.dart';
import '../models/payment_method.dart';
import '../models/payment_method_item.dart';
import '../models/payment_methods_response.dart';
import '../models/public_payment_method.dart';

class PaymentMethodsRepository {
  PaymentMethodsRepository({PaymentMethodsDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? PaymentMethodsDataProvider();

  final PaymentMethodsDataProvider _dataProvider;

  /// Flat provider list from public API, falling back to legacy nested API.
  Future<List<PublicPaymentMethod>> getSelectableProviders({
    String? cartCurrency,
  }) async {
    try {
      final List<PublicPaymentMethod> public =
          await _dataProvider.getPublicPaymentMethods();
      if (public.isNotEmpty) {
        return _filterPublicMethods(public, cartCurrency);
      }
    } catch (_) {
      // Fall through to legacy endpoint.
    }

    final PaymentMethodsResponse legacy = await getPaymentMethods();
    return _flatFromLegacy(legacy, cartCurrency);
  }

  List<PublicPaymentMethod> _filterPublicMethods(
    List<PublicPaymentMethod> methods,
    String? cartCurrency,
  ) {
    final List<PublicPaymentMethod> filtered = methods
        .where((PublicPaymentMethod m) {
          if (!m.isEnabled) return false;
          if (PaymentConstants.isHiddenPaymentProvider(
            m.providerCode,
            displayName: m.displayName,
          )) {
            return false;
          }
          if (cartCurrency == null || cartCurrency.isEmpty) return true;
          if (m.supportedCurrencies.isEmpty) return true;
          return m.supportedCurrencies
              .map((String c) => c.toUpperCase())
              .contains(cartCurrency.toUpperCase());
        })
        .toList();

    // API often returns CASH + COD (+ CASH_ON_DELIVERY); show one COD entry.
    return _dedupeCashOnDelivery(filtered)
      ..sort(
        (PublicPaymentMethod a, PublicPaymentMethod b) =>
            a.sortOrder.compareTo(b.sortOrder),
      );
  }

  /// Prefer `COD`, then `CASH_ON_DELIVERY`, then `CASH`.
  List<PublicPaymentMethod> _dedupeCashOnDelivery(
    List<PublicPaymentMethod> methods,
  ) {
    final List<PublicPaymentMethod> codMethods = methods
        .where(
          (PublicPaymentMethod m) =>
              PaymentConstants.isCashOnDelivery(m.providerCode),
        )
        .toList();
    if (codMethods.length <= 1) return methods;

    const List<String> preference = <String>[
      'COD',
      'CASH_ON_DELIVERY',
      'CASH',
    ];
    PublicPaymentMethod preferred = codMethods.first;
    for (final String code in preference) {
      final PublicPaymentMethod match = codMethods.firstWhere(
        (PublicPaymentMethod m) => m.providerCode.toUpperCase() == code,
        orElse: () => preferred,
      );
      if (match.providerCode.toUpperCase() == code) {
        preferred = match;
        break;
      }
    }

    final String preferredCode = preferred.providerCode.toUpperCase();
    var keptCod = false;
    final List<PublicPaymentMethod> result = <PublicPaymentMethod>[];
    for (final PublicPaymentMethod m in methods) {
      if (!PaymentConstants.isCashOnDelivery(m.providerCode)) {
        result.add(m);
        continue;
      }
      if (!keptCod && m.providerCode.toUpperCase() == preferredCode) {
        result.add(m);
        keptCod = true;
      }
    }
    return result;
  }

  List<PublicPaymentMethod> _flatFromLegacy(
    PaymentMethodsResponse response,
    String? cartCurrency,
  ) {
    final List<PublicPaymentMethod> flat = <PublicPaymentMethod>[];
    final Set<String> nestedItemCodes = <String>{
      for (final PaymentMethod method in response.data)
        for (final PaymentMethodItem item in method.paymentMethodItemResponses)
          item.itemCode,
    };

    for (final PaymentMethod paymentMethod in response.data) {
      if (paymentMethod.paymentMethodItemResponses.isEmpty) {
        if (nestedItemCodes.contains(paymentMethod.code)) continue;
        flat.add(
          PublicPaymentMethod(
            providerCode: paymentMethod.code,
            displayName: paymentMethod.displayName,
            iconUrl: paymentMethod.iconUrl,
            requiresAccount: _legacyRequiresAccount(
              paymentMethod.code,
              displayName: paymentMethod.displayName,
            ),
          ),
        );
        continue;
      }

      for (final PaymentMethodItem item
          in paymentMethod.paymentMethodItemResponses) {
        if (item.hasVariants) {
          for (final variant in item.paymentMethodItemResponses) {
            flat.add(
              PublicPaymentMethod(
                providerCode: variant.variantCode,
                displayName: variant.displayName,
                iconUrl: variant.iconUrl ?? item.iconUrl,
                requiresAccount: item.requireAccountNumberOnInitiation ?? false,
              ),
            );
          }
        } else {
          flat.add(
            PublicPaymentMethod(
              providerCode: item.itemCode,
              displayName: item.displayName,
              iconUrl: item.iconUrl,
              requiresAccount: item.requireAccountNumberOnInitiation ?? false,
            ),
          );
        }
      }
    }

    return _filterPublicMethods(flat, cartCurrency);
  }

  bool _legacyRequiresAccount(String code, {String? displayName}) {
    return PaymentConstants.requiresPaymentAccount(
      code,
      displayName: displayName,
    );
  }

  Future<PaymentMethodsResponse> getPaymentMethods() async {
    final response = await _dataProvider.getPaymentMethods();
    return PaymentMethodsResponse(
      status: response.status,
      message: response.message,
      data: response.data
          .where(
            (m) => !PaymentConstants.isHiddenPaymentProvider(
              m.code,
              displayName: m.displayName,
            ),
          )
          .map(_withoutHiddenItems)
          .toList(),
    );
  }

  PaymentMethod _withoutHiddenItems(PaymentMethod method) {
    return PaymentMethod(
      displayName: method.displayName,
      code: method.code,
      iconUrl: method.iconUrl,
      paymentMethodItemResponses: method.paymentMethodItemResponses
          .where(
            (item) => !PaymentConstants.isHiddenPaymentProvider(
              item.itemCode,
              displayName: item.displayName,
            ),
          )
          .map(_withoutHiddenVariants)
          .toList(),
    );
  }

  PaymentMethodItem _withoutHiddenVariants(PaymentMethodItem item) {
    if (item.paymentMethodItemResponses.isEmpty) return item;

    return PaymentMethodItem(
      displayName: item.displayName,
      itemCode: item.itemCode,
      currency: item.currency,
      iconUrl: item.iconUrl,
      paymentInstruction: item.paymentInstruction,
      requireAccountNumberOnInitiation: item.requireAccountNumberOnInitiation,
      paymentMethodItemResponses: item.paymentMethodItemResponses
          .where(
            (v) => !PaymentConstants.isHiddenPaymentProvider(
              v.variantCode,
              displayName: v.displayName,
            ),
          )
          .toList(),
    );
  }
}
