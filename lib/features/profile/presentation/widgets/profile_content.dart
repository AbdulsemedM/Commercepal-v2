import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/theme_controller.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/biometric_service.dart';
import 'package:commercepal/core/widgets/app_dialog.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/profile/presentation/widgets/help_desk_modal.dart';
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

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(ProfileLoadRequested()),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading && state is! ProfileLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final profile = state is ProfileLoaded ? state.profile : null;
                final bool isAffiliate =
                    state is ProfileLoaded && state.affiliateProfile != null;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProfileBloc>().add(
                          ProfileRefreshRequested(),
                        );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: Spacing.md),
                        _buildUserInfoCard(context, profile),
                        if (profile != null &&
                            (profile.referralCode ?? '').isNotEmpty) ...[
                          const SizedBox(height: Spacing.md),
                          _buildReferralCodeCard(
                            context,
                            profile.referralCode!,
                          ),
                        ],
                        const SizedBox(height: Spacing.lg),
                        _buildThemeSection(context),
                        const SizedBox(height: Spacing.lg),
                        _buildSection(
                          context,
                          title: 'ACCOUNT',
                          items: _accountItems(context, isAffiliate),
                        ),
                        const SizedBox(height: Spacing.md),
                        _buildSection(
                          context,
                          title: 'SECURITY & SETTINGS',
                          items: _securityItems(context),
                          trailingBuilders:
                              <String, Widget Function(BuildContext)>{
                            'biometric': (_) => const _BiometricToggle(),
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                        _buildSection(
                          context,
                          title: 'LEGAL & SUPPORT',
                          items: _legalItems(context),
                        ),
                        const SizedBox(height: Spacing.md),
                        _buildDangerZone(context),
                        const SizedBox(height: Spacing.md),
                        _buildAppVersionFooter(context),
                        const SizedBox(height: Spacing.xl),
                      ],
                    ),
                  ),
                );
              },
            ),
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
        final String label = LocalizationService.t(
          context,
          'profile.appVersion',
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Center(
            child: Text(
              '$label ${info.version} (${info.buildNumber})',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoCard(BuildContext context, ProfileData? profile) {
    final AuthService authService = AuthService();
    final String? userName = profile?.fullName ?? authService.userName;
    final String? userEmail = profile?.emailAddress ?? authService.userEmail;
    final String? userImageUrl = authService.userImageUrl;

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppDecorations.softCardShadow(),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppDecorations.primaryCtaGradient,
              image: userImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(userImageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: userImageUrl == null
                ? Center(
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  userName ?? LocalizationService.t(context, 'profile.user'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        fontSize: 17,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userEmail ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (profile?.phoneNumber != null &&
                    profile!.phoneNumber.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.phoneNumber,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocalizationService.t(context, 'profile.theme').toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600],
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          ListenableBuilder(
            listenable: ThemeControllerScope.of(context),
            builder: (BuildContext context, Widget? child) {
              final ThemeController controller =
                  ThemeControllerScope.of(context);
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppDecorations.softCardShadow(),
                ),
                child: Row(
                  children: <Widget>[
                    _ThemePill(
                      label: LocalizationService.t(
                        context,
                        'profile.themeLight',
                      ),
                      icon: Icons.light_mode_outlined,
                      selected: controller.themeMode == ThemeMode.light,
                      onTap: () => controller.setThemeMode(ThemeMode.light),
                    ),
                    _ThemePill(
                      label: LocalizationService.t(
                        context,
                        'profile.themeDark',
                      ),
                      icon: Icons.dark_mode_outlined,
                      selected: controller.themeMode == ThemeMode.dark,
                      onTap: () => controller.setThemeMode(ThemeMode.dark),
                    ),
                    _ThemePill(
                      label: LocalizationService.t(
                        context,
                        'profile.themeSystem',
                      ),
                      icon: Icons.brightness_auto_outlined,
                      selected: controller.themeMode == ThemeMode.system,
                      onTap: () => controller.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(BuildContext context, String referralCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pink.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.card_giftcard_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  LocalizationService.t(context, 'profile.referralCode'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  referralCode,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                        fontSize: 15,
                      ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: referralCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      LocalizationService.t(
                        context,
                        'profile.referralCodeCopied',
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.copy_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_MenuItem> _accountItems(BuildContext context, bool isAffiliate) {
    return <_MenuItem>[
      if (isAffiliate)
        _MenuItem(
          icon: Icons.dashboard_outlined,
          title: LocalizationService.t(context, 'affiliate.affiliateDashboard'),
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
          icon: Icons.star_outline,
          title: LocalizationService.t(context, 'affiliate.becomeAffiliate'),
          onTap: () {
            AffiliateRegistrationModal.show(
              context,
              onRegistrationComplete: () {
                context.read<ProfileBloc>().add(ProfileRefreshRequested());
              },
            );
          },
        ),
      _MenuItem(
        icon: Icons.person_outline,
        title: LocalizationService.t(context, 'profile.personalDetails'),
        onTap: () {
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
        },
      ),
      _MenuItem(
        icon: Icons.location_on_outlined,
        title: LocalizationService.t(context, 'profile.myAddresses'),
        onTap: () {
          context.push(AppRoutes.addresses);
        },
      ),
      _MenuItem(
        icon: Icons.shopping_cart_outlined,
        title: LocalizationService.t(context, 'profile.orderHistory'),
        onTap: () {
          context.push('/order-history');
        },
      ),
      _MenuItem(
        icon: Icons.favorite_border,
        title: LocalizationService.t(context, 'profile.wishlist'),
        onTap: () {
          context.push(AppRoutes.wishlist);
        },
      ),
    ];
  }

  List<_MenuItem> _securityItems(BuildContext context) {
    return <_MenuItem>[
      _MenuItem(
        icon: Icons.lock_reset_outlined,
        title: LocalizationService.t(context, 'profile.changePassword'),
        onTap: () {
          ChangePasswordBottomSheet.show(context);
        },
      ),
      _MenuItem(
        id: 'biometric',
        icon: Icons.fingerprint,
        title: LocalizationService.t(context, 'profile.enableBiometric'),
        onTap: () {},
        hideChevron: true,
      ),
      _MenuItem(
        icon: Icons.flag_outlined,
        title: LocalizationService.t(context, 'profile.changeCountry'),
        onTap: () async {
          final selectedCountry = await CountrySelectionBottomSheet.show(
            context,
          );
          if (selectedCountry != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${LocalizationService.t(context, 'profile.countryChangedTo')} ${CountryCurrencyConstants.getCountryName(selectedCountry)}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      _MenuItem(
        icon: Icons.attach_money_outlined,
        title: LocalizationService.t(context, 'profile.changeCurrency'),
        onTap: () async {
          final selectedCurrency = await CurrencySelectionBottomSheet.show(
            context,
          );
          if (selectedCurrency != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${LocalizationService.t(context, 'profile.currencyChangedTo')} ${CountryCurrencyConstants.getCurrencyName(selectedCurrency)}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      _MenuItem(
        icon: Icons.language_outlined,
        title: LocalizationService.t(context, 'profile.changeLanguage'),
        onTap: () {
          LanguageSelectionBottomSheet.show(context);
        },
      ),
    ];
  }

  List<_MenuItem> _legalItems(BuildContext context) {
    return <_MenuItem>[
      _MenuItem(
        icon: Icons.description_outlined,
        title: LocalizationService.t(context, 'profile.termsConditions'),
        onTap: () {
          context.push('/terms-conditions');
        },
      ),
      _MenuItem(
        icon: Icons.receipt_outlined,
        title: LocalizationService.t(context, 'profile.refundPolicy'),
        onTap: () {
          context.push('/refund-policy');
        },
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: LocalizationService.t(context, 'profile.faqs'),
        onTap: () {
          context.push(AppRoutes.faqs);
        },
      ),
      _MenuItem(
        icon: Icons.contact_support_outlined,
        title: LocalizationService.t(context, 'profile.contactUs'),
        onTap: () {
          context.push(AppRoutes.contactUs);
        },
      ),
      _MenuItem(
        icon: Icons.info_outline,
        title: LocalizationService.t(context, 'profile.helpDesk'),
        onTap: () {
          HelpDeskModal.show(context);
        },
      ),
    ];
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
    Map<String, Widget Function(BuildContext)>? trailingBuilders,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600],
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppDecorations.softCardShadow(),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < items.length; i++) ...[
                  _MenuItemWidget(
                    item: items[i],
                    trailing: items[i].id != null &&
                            trailingBuilders?[items[i].id!] != null
                        ? trailingBuilders![items[i].id!]!(context)
                        : null,
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 68,
                      color: Colors.grey.shade200,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    final List<_MenuItem> dangerItems = <_MenuItem>[
      _MenuItem(
        icon: Icons.person_off_outlined,
        title: LocalizationService.t(context, 'profile.accountDeletionRequest'),
        onTap: () {
          context.push(AppRoutes.accountDeletionRequest);
        },
        isDestructive: true,
      ),
      _MenuItem(
        icon: Icons.logout_outlined,
        title: LocalizationService.t(context, 'profile.logOut'),
        onTap: () {
          _showLogoutDialog(context);
        },
        isDestructive: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            for (int i = 0; i < dangerItems.length; i++) ...[
              _MenuItemWidget(item: dangerItems[i]),
              if (i < dangerItems.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 68,
                  color: AppColors.error.withValues(alpha: 0.12),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AppDialog.show<void>(
      context,
      title: LocalizationService.t(context, 'profile.logOut'),
      message: LocalizationService.t(context, 'profile.logOutConfirm'),
      icon: const Icon(Icons.logout_rounded),
      actions: <AppDialogAction>[
        AppDialogAction(label: LocalizationService.t(context, 'profile.cancel')),
        AppDialogAction(
          label: LocalizationService.t(context, 'profile.logOut'),
          isDestructive: true,
          onPressed: () async {
            try {
              await AuthService().logout();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      LocalizationService.t(context, 'profile.logoutFailed'),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class _ThemePill extends StatelessWidget {
  const _ThemePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: selected ? AppDecorations.primaryCtaGradient : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: AppColors.pink.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.grey[600],
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

class _BiometricToggle extends StatefulWidget {
  const _BiometricToggle();

  @override
  State<_BiometricToggle> createState() => _BiometricToggleState();
}

class _BiometricToggleState extends State<_BiometricToggle> {
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
    if (!hasBiometrics) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.t(context, 'profile.biometricUnavailable'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final BiometricAuthResult authResult = await biometricService.authenticate(
      reason: LocalizationService.t(context, 'auth.biometric.signInReason'),
    );
    if (!mounted) return;

    if (authResult != BiometricAuthResult.success) {
      if (authResult == BiometricAuthResult.cancel) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.t(context, 'auth.biometric.signInFailed'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await storage.setBiometricEnabled(true);
    if (mounted) {
      setState(() => _enabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.t(context, 'profile.biometricEnabledSuccess'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Switch.adaptive(
      value: _enabled,
      activeTrackColor: AppColors.primary,
      onChanged: _onChanged,
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.id,
    this.isDestructive = false,
    this.hideChevron = false,
  });

  final String? id;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool hideChevron;
}

class _MenuItemWidget extends StatelessWidget {
  const _MenuItemWidget({
    required this.item,
    this.trailing,
  });

  final _MenuItem item;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        item.isDestructive ? AppColors.error : AppColors.pink;
    final Color labelColor =
        item.isDestructive ? AppColors.error : AppColors.navy;

    return InkWell(
      onTap: item.hideChevron && trailing != null ? null : item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm + 4,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, color: accent, size: 20),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (!item.hideChevron)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
