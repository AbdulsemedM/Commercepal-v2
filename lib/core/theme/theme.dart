import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'commerce_colors.dart';
import 'tokens.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.maroon,
    onPrimary: Colors.white,
    primaryContainer: AppColors.maroonSoft,
    onPrimaryContainer: Color(0xFF4A0430),
    primaryFixed: AppColors.maroonSoft,
    onPrimaryFixed: Color(0xFF4A0430),
    secondary: AppColors.ink2,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE8EBEF),
    onSecondaryContainer: AppColors.ink,
    tertiary: AppColors.deal,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.dealSoft,
    onTertiaryContainer: Color(0xFF7A2A00),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorSoft,
    onErrorContainer: Color(0xFF7F1D1D),
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkMuted,
    surfaceDim: Color(0xFFE2E5E9),
    surfaceBright: AppColors.surface,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: Color(0xFFF8F9FA),
    surfaceContainer: AppColors.canvas,
    surfaceContainerHigh: AppColors.surfaceMuted,
    surfaceContainerHighest: Color(0xFFE8EBEF),
    outline: AppColors.borderStrong,
    outlineVariant: AppColors.border,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF8FAFC),
    inversePrimary: Color(0xFFF7A8CF),
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF7A8CF),
    onPrimary: Color(0xFF4A0430),
    primaryContainer: Color(0xFF6E0844),
    onPrimaryContainer: Color(0xFFFFD8EA),
    secondary: Color(0xFFCBD5E1),
    onSecondary: AppColors.ink,
    secondaryContainer: Color(0xFF334155),
    onSecondaryContainer: Color(0xFFE2E8F0),
    tertiary: Color(0xFFFF9A5C),
    onTertiary: Color(0xFF3D1400),
    tertiaryContainer: Color(0xFF6B2600),
    onTertiaryContainer: Color(0xFFFFDCC7),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFECACA),
    surface: Color(0xFF171A21),
    onSurface: Color(0xFFE8EAED),
    onSurfaceVariant: Color(0xFFA3ABB8),
    surfaceDim: Color(0xFF0E1116),
    surfaceBright: Color(0xFF2B313D),
    surfaceContainerLowest: Color(0xFF0B0D11),
    surfaceContainerLow: Color(0xFF171A21),
    surfaceContainer: Color(0xFF1B1F27),
    surfaceContainerHigh: Color(0xFF232833),
    surfaceContainerHighest: Color(0xFF2B313D),
    outline: Color(0xFF4B5563),
    outlineVariant: Color(0xFF2D333D),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE8EAED),
    onInverseSurface: Color(0xFF171A21),
    inversePrimary: AppColors.maroon,
    surfaceTint: Colors.transparent,
  );

  static ThemeData get light => _build(lightScheme, CommerceColors.light);

  static ThemeData get dark => _build(darkScheme, CommerceColors.dark);

  static ThemeData _build(ColorScheme scheme, CommerceColors commerce) {
    final bool isLight = scheme.brightness == Brightness.light;
    final TextTheme text = AppTypography.textTheme(scheme.onSurface);

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: BorderSide(color: scheme.outline),
    );

    const Size buttonSize = Size.fromHeight(AppSizes.buttonLg);
    final TextStyle? buttonText =
        text.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      primaryColor: scheme.primary,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      textTheme: text,
      primaryTextTheme: AppTypography.textTheme(scheme.onPrimary),
      scaffoldBackgroundColor: commerce.canvas,
      canvasColor: scheme.surface,
      splashFactory:
          isLight ? InkSparkle.splashFactory : InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[commerce],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: scheme.outlineVariant,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        titleTextStyle: text.titleLarge,
        toolbarTextStyle: text.bodyMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          // Bordered in both modes so cards stay defined on any background.
          side: BorderSide(color: commerce.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => text.labelSmall?.copyWith(
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? scheme.surface : scheme.surfaceContainerHigh,
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (Set<WidgetState> s) =>
              (text.bodyMedium ?? const TextStyle()).copyWith(
            color: s.contains(WidgetState.error)
                ? scheme.error
                : s.contains(WidgetState.focused)
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
          ),
        ),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        helperStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          backgroundColor: commerce.cta,
          foregroundColor: commerce.onCta,
          shape: const StadiumBorder(),
          textStyle: buttonText,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.1),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          shape: const StadiumBorder(),
          elevation: 0,
          backgroundColor: commerce.cta,
          foregroundColor: commerce.onCta,
          textStyle: buttonText,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.1),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: const StadiumBorder(),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: buttonText,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.square(AppSizes.minTouchTarget),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: commerce.cta,
        foregroundColor: commerce.onCta,
        elevation: 2,
        highlightElevation: 4,
        shape: const StadiumBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHigh,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: text.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: text.labelLarge?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        checkmarkColor: scheme.onPrimaryContainer,
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: text.labelLarge,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: scheme.outlineVariant,
        labelStyle: text.titleSmall,
        unselectedLabelStyle:
            text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? scheme.onPrimary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? scheme.primary : null,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? scheme.primary : null,
        ),
        checkColor: WidgetStatePropertyAll<Color>(scheme.onPrimary),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: commerce.deal,
        textColor: commerce.onDeal,
        textStyle: text.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: text.bodyMedium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        collapsedIconColor: scheme.onSurfaceVariant,
        shape: const Border(),
        collapsedShape: const Border(),
      ),
    );
  }
}
