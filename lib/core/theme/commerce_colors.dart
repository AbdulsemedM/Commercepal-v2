import 'package:flutter/material.dart';

import 'colors.dart';

/// Commerce-specific colour roles that [ColorScheme] does not model.
///
/// Read with `context.commerce` (see [CommerceColorsX]) so every screen gets
/// the right value in light and dark mode.
@immutable
class CommerceColors extends ThemeExtension<CommerceColors> {
  const CommerceColors({
    required this.canvas,
    required this.border,
    required this.price,
    required this.priceOriginal,
    required this.deal,
    required this.onDeal,
    required this.dealContainer,
    required this.onDealContainer,
    required this.rating,
    required this.ratingEmpty,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.header,
    required this.onHeader,
    required this.cta,
    required this.onCta,
  });

  /// Page background behind cards.
  final Color canvas;

  /// Hairline border for cards and dividers on [canvas].
  final Color border;

  /// Selling price.
  final Color price;

  /// Struck-through list price.
  final Color priceOriginal;

  /// Discount / flash-deal signal.
  final Color deal;
  final Color onDeal;
  final Color dealContainer;
  final Color onDealContainer;

  /// Filled rating star and the empty track.
  final Color rating;
  final Color ratingEmpty;

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color skeletonBase;
  final Color skeletonHighlight;

  /// Top brand header (search bar band).
  final Color header;
  final Color onHeader;

  /// Primary call-to-action fill. Stays a deep maroon with white text in
  /// dark mode (the scheme's primary there is a light pink for links).
  final Color cta;
  final Color onCta;

  static const CommerceColors light = CommerceColors(
    canvas: AppColors.canvas,
    border: AppColors.border,
    price: AppColors.ink,
    priceOriginal: AppColors.inkMuted,
    deal: AppColors.deal,
    onDeal: Colors.white,
    dealContainer: AppColors.dealSoft,
    onDealContainer: Color(0xFF9A3412),
    rating: AppColors.star,
    ratingEmpty: Color(0xFFD9DDE3),
    success: AppColors.success,
    successContainer: AppColors.successSoft,
    onSuccessContainer: Color(0xFF0B5A40),
    warning: AppColors.warning,
    warningContainer: AppColors.warningSoft,
    onWarningContainer: Color(0xFF7C3A06),
    info: AppColors.info,
    infoContainer: AppColors.infoSoft,
    onInfoContainer: Color(0xFF084C91),
    skeletonBase: Color(0xFFE9ECEF),
    skeletonHighlight: Color(0xFFF6F7F9),
    header: AppColors.maroon,
    onHeader: Colors.white,
    cta: AppColors.maroon,
    onCta: Colors.white,
  );

  static const CommerceColors dark = CommerceColors(
    canvas: Color(0xFF0E1116),
    border: Color(0xFF2A303A),
    price: Color(0xFFF1F3F5),
    priceOriginal: Color(0xFF98A1AE),
    deal: Color(0xFFFF8A4C),
    onDeal: Color(0xFF2B0E00),
    dealContainer: Color(0xFF4A1E06),
    onDealContainer: Color(0xFFFFD2B8),
    rating: Color(0xFFFFB627),
    ratingEmpty: Color(0xFF3A414C),
    success: Color(0xFF4CC497),
    successContainer: Color(0xFF0E3B2C),
    onSuccessContainer: Color(0xFFB4EBD5),
    warning: Color(0xFFF5B25B),
    warningContainer: Color(0xFF452A08),
    onWarningContainer: Color(0xFFFDE0B8),
    info: Color(0xFF6CB2F5),
    infoContainer: Color(0xFF0D2E50),
    onInfoContainer: Color(0xFFC8E2FC),
    skeletonBase: Color(0xFF1F242C),
    skeletonHighlight: Color(0xFF2A303A),
    header: Color(0xFF171A21),
    onHeader: Color(0xFFF1F3F5),
    cta: Color(0xFFA8226B),
    onCta: Colors.white,
  );

  @override
  CommerceColors copyWith({
    Color? canvas,
    Color? border,
    Color? price,
    Color? priceOriginal,
    Color? deal,
    Color? onDeal,
    Color? dealContainer,
    Color? onDealContainer,
    Color? rating,
    Color? ratingEmpty,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? header,
    Color? onHeader,
    Color? cta,
    Color? onCta,
  }) {
    return CommerceColors(
      canvas: canvas ?? this.canvas,
      border: border ?? this.border,
      price: price ?? this.price,
      priceOriginal: priceOriginal ?? this.priceOriginal,
      deal: deal ?? this.deal,
      onDeal: onDeal ?? this.onDeal,
      dealContainer: dealContainer ?? this.dealContainer,
      onDealContainer: onDealContainer ?? this.onDealContainer,
      rating: rating ?? this.rating,
      ratingEmpty: ratingEmpty ?? this.ratingEmpty,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      header: header ?? this.header,
      onHeader: onHeader ?? this.onHeader,
      cta: cta ?? this.cta,
      onCta: onCta ?? this.onCta,
    );
  }

  @override
  CommerceColors lerp(ThemeExtension<CommerceColors>? other, double t) {
    if (other is! CommerceColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return CommerceColors(
      canvas: l(canvas, other.canvas),
      border: l(border, other.border),
      price: l(price, other.price),
      priceOriginal: l(priceOriginal, other.priceOriginal),
      deal: l(deal, other.deal),
      onDeal: l(onDeal, other.onDeal),
      dealContainer: l(dealContainer, other.dealContainer),
      onDealContainer: l(onDealContainer, other.onDealContainer),
      rating: l(rating, other.rating),
      ratingEmpty: l(ratingEmpty, other.ratingEmpty),
      success: l(success, other.success),
      successContainer: l(successContainer, other.successContainer),
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
      info: l(info, other.info),
      infoContainer: l(infoContainer, other.infoContainer),
      onInfoContainer: l(onInfoContainer, other.onInfoContainer),
      skeletonBase: l(skeletonBase, other.skeletonBase),
      skeletonHighlight: l(skeletonHighlight, other.skeletonHighlight),
      header: l(header, other.header),
      onHeader: l(onHeader, other.onHeader),
      cta: l(cta, other.cta),
      onCta: l(onCta, other.onCta),
    );
  }
}

extension CommerceColorsX on BuildContext {
  /// Commerce colour roles for the current theme.
  CommerceColors get commerce =>
      Theme.of(this).extension<CommerceColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? CommerceColors.dark
          : CommerceColors.light);
}
