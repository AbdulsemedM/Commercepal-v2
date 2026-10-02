import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/locale/locale_controller.dart';
import 'package:commercepal/core/theme/theme_controller.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/biometric_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/profile/presentation/widgets/country_selection_bottom_sheet.dart';
import 'package:commercepal/features/profile/presentation/widgets/currency_selection_bottom_sheet.dart';
import 'package:commercepal/features/profile/presentation/widgets/language_selection_bottom_sheet.dart';
import 'package:commercepal/features/auth/change_password/presentation/widgets/change_password_bottom_sheet.dart';
import 'package:commercepal/features/profile/bloc/profile_bloc.dart';
import 'package:commercepal/features/profile/data/models/profile_data.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/features/affiliate_register/presentation/widgets/affiliate_registration_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Native names for the app languages (shown as the current value).
const Map<String, String> _languageNames = <String, String>{
  'en': 'English',
  'ar': 'العربية',
  'am': 'አማርኛ',
  'so': 'Af-Soomaali',
};

/// Leading inset of a [Divider] so it lines up with [ListTile] titles.
const double _tileDividerIndent = 56;

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(ProfileLoadRequested()),
      child: Scaffold(
        body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              AppSnackbars.error(context, state.message);
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading && state is! ProfileLoaded) {
                return const _ProfileLoadingView();
              }

              final profile = state is ProfileLoaded ? state.profile : null;
              final bool isAffiliate =
                  state is ProfileLoaded && state.affiliateProfile != null;

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Keep a readable column on tablets / foldables.
                  final double side = math.max(
                    Spacing.gutter,
                    (constraints.maxWidth - AppSizes.maxContentWidth) / 2,
                  );
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProfileBloc>().add(
                            ProfileRefreshRequested(),
                          );
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom:
                            Spacing.xxl + MediaQuery.paddingOf(context).bottom,
                      ),
                      children: <Widget>[
                        _buildUserInfoCard(context, profile),
                        Transform.translate(
                          // Quick tiles overlap the hero, Amazon-style.
                          offset: const Offset(0, -ProfileHero.overlap),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: side),
                            child: ProfileQuickTiles(
                              tiles: _quickTiles(context),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: side),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (profile != null &&
                                  (profile.referralCode ?? '').isNotEmpty) ...[
                                const SizedBox(height: Spacing.sm),
                                _buildReferralCodeCard(
                                  context,
                                  profile.referralCode!,
                                ),
                              ],
                              const SizedBox(height: Spacing.sm),
                              _MenuGroup(
                                title: context.tr('profile.sectionAccount'),
                                items: _accountItems(context, isAffiliate),
                              ),
                              const SizedBox(height: Spacing.xl),
                              _GroupHeader(
                                title: context.tr('profile.sectionPreferences'),
                              ),
                              const _PreferencesCard(),
                              const SizedBox(height: Spacing.xl),
                              _GroupHeader(
                                title: context.tr('profile.sectionSecurity'),
                              ),
                              _buildSecurityCard(context),
                              const SizedBox(height: Spacing.xl),
                              _MenuGroup(
                                title: context.tr('profile.sectionSupport'),
                                items: _supportItems(context),
                              ),
                              const SizedBox(height: Spacing.xxl),
                              _buildAccountActions(context),
                              const SizedBox(height: Spacing.lg),
                              _buildAppVersionFooter(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersionFooter(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final PackageInfo info = snapshot.data!;
        final String label = context.tr('profile.appVersion');
        final ThemeData theme = Theme.of(context);
        return Text(
          '$label ${info.version} (${info.buildNumber})',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFeatures: AppTypography.tabularFigures,
          ),
        );
      },
    );
  }

  void _openEditProfile(BuildContext context) {
    final state = context.read<ProfileBloc>().state;
    ProfileData? profile;
    if (state is ProfileLoaded) {
      profile = state.profile;
    }
    context.push('/edit-profile', extra: profile).then((_) {
      if (context.mounted) {
        context.read<ProfileBloc>().add(ProfileRefreshRequested());
      }
    });
  }

  Widget _buildUserInfoCard(BuildContext context, ProfileData? profile) {
    final AuthService authService = AuthService();
    final String? userName = profile?.fullName ?? authService.userName;
    final String? userEmail = profile?.emailAddress ?? authService.userEmail;
    final String? userImageUrl = authService.userImageUrl;
    final String? phone = (profile?.phoneNumber.isNotEmpty ?? false)
        ? profile!.phoneNumber
        : null;

    String userInitials = 'U';
    if (profile != null) {
      final firstName = profile.firstName.isNotEmpty
          ? profile.firstName[0].toUpperCase()
          : '';
      final lastName =
          profile.lastName.isNotEmpty ? profile.lastName[0].toUpperCase() : '';
      userInitials = '$firstName$lastName';
      if (userInitials.isEmpty) {
        userInitials =
            userEmail?.isNotEmpty == true ? userEmail![0].toUpperCase() : 'U';
      }
    } else {
      userInitials = authService.userInitials ?? 'U';
    }

    return ProfileHero(
      title: userName ?? context.tr('profile.user'),
      lines: <String>[
        if ((userEmail ?? '').isNotEmpty) userEmail!,
        if (phone != null) phone,
      ],
      initials: userInitials,
      imageUrl: userImageUrl,
      action: _HeroChip(
        icon: Icons.edit_outlined,
        label: context.tr('profile.editProfile'),
        onTap: () => _openEditProfile(context),
      ),
    );
  }

  List<ProfileQuickTile> _quickTiles(BuildContext context) {
    return <ProfileQuickTile>[
      ProfileQuickTile(
        icon: Icons.receipt_long_outlined,
        label: context.tr('profile.orderHistory'),
        onTap: () => context.push('/order-history'),
      ),
      ProfileQuickTile(
        icon: Icons.favorite_border_rounded,
        label: context.tr('profile.wishlist'),
        onTap: () => context.push(AppRoutes.wishlist),
      ),
      ProfileQuickTile(
        icon: Icons.location_on_outlined,
        label: context.tr('profile.myAddresses'),
        onTap: () => context.push(AppRoutes.addresses),
      ),
      ProfileQuickTile(
        icon: Icons.support_agent_outlined,
        label: context.tr('profile.help'),
        onTap: () => context.push(AppRoutes.supportChat),
      ),
    ];
  }

  Widget _buildReferralCodeCard(BuildContext context, String referralCode) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(Icons.card_giftcard_outlined, color: scheme.primary),
        title: Text(
          context.tr('profile.referralCode'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        subtitle: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SelectableText(
              referralCode,
              maxLines: 1,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
                letterSpacing: 1.2,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),
        ),
        trailing: IconButton(
          tooltip: context.tr('profile.copyCode'),
          icon: const Icon(Icons.copy_rounded),
          color: scheme.primary,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: referralCode));
            AppSnackbars.success(
              context,
              context.tr('profile.referralCodeCopied'),
            );
          },
        ),
      ),
    );
  }

  List<_MenuItem> _accountItems(BuildContext context, bool isAffiliate) {
    return <_MenuItem>[
      _MenuItem(
        icon: Icons.person_outline,
        title: context.tr('profile.personalDetails'),
        onTap: () => _openEditProfile(context),
      ),
      if (isAffiliate)
        _MenuItem(
          icon: Icons.dashboard_outlined,
          title: context.tr('affiliate.affiliateDashboard'),
          trailingIcon: Icons.open_in_new,
          onTap: () async {
            final uri = Uri.parse(
              'https://affiliate.commercepal.com/auth/login',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        )
      else
        _MenuItem(
          icon: Icons.storefront_outlined,
          title: context.tr('affiliate.becomeAffiliate'),
          subtitle: context.tr('affiliate.registerSubtitle'),
          onTap: () {
            AffiliateRegistrationModal.show(
              context,
              onRegistrationComplete: () {
                context.read<ProfileBloc>().add(ProfileRefreshRequested());
              },
            );
          },
        ),
    ];
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          _MenuTile(
            item: _MenuItem(
              icon: Icons.lock_reset_outlined,
              title: context.tr('profile.changePassword'),
              onTap: () {
                ChangePasswordBottomSheet.show(context);
              },
            ),
          ),
          const Divider(height: 1, indent: _tileDividerIndent),
          const _BiometricTile(),
        ],
      ),
    );
  }

  List<_MenuItem> _supportItems(BuildContext context) {
    return <_MenuItem>[
      _MenuItem(
        icon: Icons.support_agent_outlined,
        title: context.tr('profile.helpDesk'),
        subtitle: context.tr('profile.helpDeskSubtitle'),
        onTap: () {
          context.push(AppRoutes.supportChat);
        },
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: context.tr('profile.faqs'),
        onTap: () {
          context.push(AppRoutes.faqs);
        },
      ),
      _MenuItem(
        icon: Icons.contact_support_outlined,
        title: context.tr('profile.contactUs'),
        onTap: () {
          context.push(AppRoutes.contactUs);
        },
      ),
      _MenuItem(
        icon: Icons.description_outlined,
        title: context.tr('profile.termsConditions'),
        onTap: () {
          context.push('/terms-conditions');
        },
      ),
      _MenuItem(
        icon: Icons.assignment_return_outlined,
        title: context.tr('profile.refundPolicy'),
        onTap: () {
          context.push('/refund-policy');
        },
      ),
    ];
  }

  Widget _buildAccountActions(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppButton(
          label: context.tr('profile.logOut'),
          icon: Icons.logout_rounded,
          variant: AppButtonVariant.destructive,
          size: AppButtonSize.medium,
          onPressed: () {
            _showLogoutDialog(context);
          },
        ),
        const SizedBox(height: Spacing.xs),
        Center(
          child: TextButton.icon(
            onPressed: () {
              context.push(AppRoutes.accountDeletionRequest);
            },
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurfaceVariant,
              minimumSize: const Size(
                AppSizes.minTouchTarget,
                AppSizes.minTouchTarget,
              ),
            ),
            icon: const Icon(Icons.person_off_outlined, size: AppSizes.iconMd),
            label: Text(context.tr('profile.accountDeletionRequest')),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AppDialog.show<void>(
      context,
      title: context.tr('profile.logOut'),
      message: context.tr('profile.logOutConfirm'),
      icon: const Icon(Icons.logout_rounded),
      actions: <AppDialogAction>[
        AppDialogAction(label: context.tr('profile.cancel')),
        AppDialogAction(
          label: context.tr('profile.logOut'),
          isDestructive: true,
          onPressed: () async {
            try {
              await AuthService().logout();
            } catch (e) {
              if (context.mounted) {
                AppSnackbars.error(
                  context,
                  context.tr('profile.logoutFailed'),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

/// Skeleton shown while the profile loads for the first time.
class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Spacing.gutter),
      children: const <Widget>[
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.xs),
            child: ListTileShimmer(),
          ),
        ),
        SizedBox(height: Spacing.xl),
        ShimmerLoading(height: 180, width: double.infinity),
        SizedBox(height: Spacing.xl),
        ShimmerLoading(height: 180, width: double.infinity),
      ],
    );
  }
}

/// Sentence-case group title above a settings card.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: Spacing.xxs,
        bottom: Spacing.xs,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A titled card of navigation rows separated by inset dividers.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.items});

  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _GroupHeader(title: title),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < items.length; i++) ...[
                _MenuTile(item: items[i]),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: _tileDividerIndent),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Language, country, currency and theme. Owns the current-value labels so
/// they refresh after a picker closes.
class _PreferencesCard extends StatefulWidget {
  const _PreferencesCard();

  @override
  State<_PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<_PreferencesCard> {
  final Storage _storage = Storage();
  late Future<String> _country = _storage.getSelectedCountry();
  late Future<String> _currency = _storage.getSelectedCurrency();

  void _reloadValues() {
    if (!mounted) return;
    setState(() {
      _country = _storage.getSelectedCountry();
      _currency = _storage.getSelectedCurrency();
    });
  }

  Widget _futureLabel(Future<String> future, String Function(String) name) {
    return FutureBuilder<String>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        final String? code = snapshot.data;
        return Text(code == null || code.isEmpty ? '' : name(code));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String languageCode =
        LocaleControllerScope.of(context).locale.languageCode;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          _MenuTile(
            item: _MenuItem(
              icon: Icons.language_outlined,
              title: context.tr('profile.changeLanguage'),
              subtitle: _languageNames[languageCode] ?? languageCode,
              onTap: () {
                LanguageSelectionBottomSheet.show(context);
              },
            ),
          ),
          const Divider(height: 1, indent: _tileDividerIndent),
          _MenuTile(
            item: _MenuItem(
              icon: Icons.flag_outlined,
              title: context.tr('profile.changeCountry'),
              onTap: () async {
                final selectedCountry = await CountrySelectionBottomSheet.show(
                  context,
                );
                if (selectedCountry != null && context.mounted) {
                  AppSnackbars.success(
                    context,
                    '${context.tr('profile.countryChangedTo')} ${CountryCurrencyConstants.getCountryName(selectedCountry)}',
                  );
                }
                _reloadValues();
              },
            ),
            subtitle: _futureLabel(
              _country,
              CountryCurrencyConstants.getCountryName,
            ),
          ),
          const Divider(height: 1, indent: _tileDividerIndent),
          _MenuTile(
            item: _MenuItem(
              icon: Icons.payments_outlined,
              title: context.tr('profile.changeCurrency'),
              onTap: () async {
                final selectedCurrency =
                    await CurrencySelectionBottomSheet.show(context);
                if (selectedCurrency != null && context.mounted) {
                  AppSnackbars.success(
                    context,
                    '${context.tr('profile.currencyChangedTo')} ${CountryCurrencyConstants.getCurrencyName(selectedCurrency)}',
                  );
                }
                _reloadValues();
              },
            ),
            subtitle: _futureLabel(
              _currency,
              (String code) =>
                  '${CountryCurrencyConstants.getCurrencyName(code)} ($code)',
            ),
          ),
          const Divider(height: 1, indent: _tileDividerIndent),
          const _ThemeSelector(),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final ThemeController controller = ThemeControllerScope.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.brightness_6_outlined,
                color: scheme.onSurfaceVariant,
              ),
              title: Text(context.tr('profile.theme')),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                Spacing.md,
                0,
                Spacing.md,
                Spacing.md,
              ),
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                expandedInsets: EdgeInsets.zero,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.standard,
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                segments: <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(
                      context.tr('profile.themeLight'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(
                      context.tr('profile.themeDark'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(
                      context.tr('profile.themeSystem'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                selected: <ThemeMode>{controller.themeMode},
                onSelectionChanged: (Set<ThemeMode> modes) {
                  controller.setThemeMode(modes.first);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BiometricTile extends StatefulWidget {
  const _BiometricTile();

  @override
  State<_BiometricTile> createState() => _BiometricTileState();
}

class _BiometricTileState extends State<_BiometricTile> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bool enabled = await Storage().getBiometricEnabled();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _onChanged(bool value) async {
    if (_loading) return;
    final Storage storage = Storage();
    final BiometricService biometricService = BiometricService();

    if (!value) {
      await storage.setBiometricEnabled(false);
      if (mounted) setState(() => _enabled = false);
      return;
    }

    final bool hasBiometrics = await biometricService.hasEnrolledBiometrics;
    if (!mounted) return;
    if (!hasBiometrics) {
      AppSnackbars.error(context, context.tr('profile.biometricUnavailable'));
      return;
    }

    final BiometricAuthResult authResult = await biometricService.authenticate(
      reason: context.tr('auth.biometric.signInReason'),
    );
    if (!mounted) return;

    if (authResult != BiometricAuthResult.success) {
      if (authResult == BiometricAuthResult.cancel) return;
      AppSnackbars.error(context, context.tr('auth.biometric.signInFailed'));
      return;
    }

    await storage.setBiometricEnabled(true);
    if (mounted) {
      setState(() => _enabled = true);
      AppSnackbars.success(
        context,
        context.tr('profile.biometricEnabledSuccess'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      secondary: Icon(
        Icons.fingerprint,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(context.tr('profile.enableBiometric')),
      value: _enabled,
      onChanged: _loading ? null : _onChanged,
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingIcon,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Defaults to a chevron (mirrors automatically in RTL).
  final IconData? trailingIcon;
  final VoidCallback onTap;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, this.subtitle});

  final _MenuItem item;

  /// Overrides [item.subtitle] with a custom widget (e.g. async value).
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget? sub = subtitle ??
        (item.subtitle != null && item.subtitle!.isNotEmpty
            ? Text(item.subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis)
            : null);
    return ListTile(
      leading: Icon(item.icon, color: scheme.onSurfaceVariant),
      title: Text(item.title),
      subtitle: sub,
      trailing: Icon(
        item.trailingIcon ?? Icons.chevron_right,
        color: scheme.onSurfaceVariant,
        size: AppSizes.iconMd + 2,
      ),
      onTap: item.onTap,
    );
  }
}

/// Full-bleed brand header for the account tab.
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.title,
    this.lines = const <String>[],
    this.initials,
    this.imageUrl,
    this.action,
    this.icon,
  });

  /// How far the quick tiles below overlap the hero.
  static const double overlap = 36;

  final String title;
  final List<String> lines;
  final String? initials;
  final String? imageUrl;
  final Widget? action;

  /// Shown instead of an avatar (guest hero).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommerceColors c = context.commerce;
    final Color on = c.onHeader;

    final Widget initialsAvatar = ColoredBox(
      color: on.withValues(alpha: 0.18),
      child: Center(
        child: icon != null
            ? Icon(icon, color: on, size: 34)
            : Text(
                initials ?? '',
                style: theme.textTheme.headlineSmall?.copyWith(color: on),
              ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Brand gradient in both themes (dark: deep maroon to near-black).
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: theme.brightness == Brightness.dark
                ? const <Color>[AppColors.maroonDark, Color(0xFF240818)]
                : <Color>[
                    c.header,
                    Color.lerp(c.header, Colors.black, 0.28)!,
                  ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.lg,
              Spacing.gutter,
              Spacing.lg + overlap,
            ),
            child: Row(
              children: <Widget>[
                ExcludeSemantics(
                  child: Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: on.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: (imageUrl != null && imageUrl!.isNotEmpty)
                          ? AppNetworkImage(
                              url: imageUrl!,
                              width: 68,
                              height: 68,
                              placeholder: initialsAvatar,
                              errorWidget: initialsAvatar,
                            )
                          : initialsAvatar,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: MergeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Semantics(
                          header: true,
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: on,
                            ),
                          ),
                        ),
                        for (final String line in lines)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              line,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: on.withValues(alpha: 0.82),
                              ),
                            ),
                          ),
                        if (action != null) ...<Widget>[
                          const SizedBox(height: Spacing.sm),
                          action!,
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
    );
  }
}

/// Outlined pill on the brand hero.
class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color on = context.commerce.onHeader;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: on,
        side: BorderSide(color: on.withValues(alpha: 0.6)),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        visualDensity: VisualDensity.compact,
        textStyle: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class ProfileQuickTile {
  const ProfileQuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Row of big shortcut tiles (orders, wishlist, …) on a raised card.
class ProfileQuickTiles extends StatelessWidget {
  const ProfileQuickTiles({super.key, required this.tiles});

  final List<ProfileQuickTile> tiles;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: context.commerce.border),
      ),
      shadowColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadows.md(scheme.brightness),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final ProfileQuickTile t in tiles)
                Expanded(
                  child: Semantics(
                    button: true,
                    label: t.label,
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        t.onTap();
                      },
                      borderRadius: AppRadius.mdAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.xs,
                          horizontal: Spacing.xxs,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                t.icon,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.label,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Account tab for signed-out shoppers: welcome hero with sign-in /
/// create-account, plus settings that work without an account.
class GuestProfileContent extends StatelessWidget {
  const GuestProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommerceColors c = context.commerce;
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double side = math.max(
            Spacing.gutter,
            (constraints.maxWidth - AppSizes.maxContentWidth) / 2,
          );
          return ListView(
            padding: EdgeInsets.only(
              bottom: Spacing.xxl + MediaQuery.paddingOf(context).bottom,
            ),
            children: <Widget>[
              ProfileHero(
                icon: Icons.person_outline_rounded,
                title: context.tr('profile.guestTitle'),
                lines: <String>[context.tr('profile.guestSubtitle')],
              ),
              Transform.translate(
                offset: const Offset(0, -ProfileHero.overlap),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: side),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (final (IconData icon, String key)
                              in <(IconData, String)>[
                            (
                              Icons.local_shipping_outlined,
                              'profile.guestPerkOrders'
                            ),
                            (
                              Icons.favorite_border_rounded,
                              'profile.guestPerkWishlist'
                            ),
                            (Icons.bolt_rounded, 'profile.guestPerkCheckout'),
                          ])
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: Spacing.xs,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(icon, size: 20, color: c.success),
                                  const SizedBox(width: Spacing.sm),
                                  Expanded(
                                    child: Text(
                                      context.tr(key),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: Spacing.sm),
                          AppButton.primary(
                            label: context.tr('auth.login.loginButton'),
                            onPressed: () => context.push(AppRoutes.login),
                          ),
                          const SizedBox(height: Spacing.xs),
                          AppButton.secondary(
                            label:
                                context.tr('auth.signup.createAccountButton'),
                            onPressed: () => context.push(AppRoutes.signup),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: side),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _GroupHeader(
                      title: context.tr('profile.sectionPreferences'),
                    ),
                    const _PreferencesCard(),
                    const SizedBox(height: Spacing.xl),
                    _MenuGroup(
                      title: context.tr('profile.sectionSupport'),
                      items: <_MenuItem>[
                        _MenuItem(
                          icon: Icons.help_outline,
                          title: context.tr('profile.faqs'),
                          onTap: () => context.push(AppRoutes.faqs),
                        ),
                        _MenuItem(
                          icon: Icons.contact_support_outlined,
                          title: context.tr('profile.contactUs'),
                          onTap: () => context.push(AppRoutes.contactUs),
                        ),
                        _MenuItem(
                          icon: Icons.description_outlined,
                          title: context.tr('profile.termsConditions'),
                          onTap: () => context.push('/terms-conditions'),
                        ),
                        _MenuItem(
                          icon: Icons.assignment_return_outlined,
                          title: context.tr('profile.refundPolicy'),
                          onTap: () => context.push('/refund-policy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
