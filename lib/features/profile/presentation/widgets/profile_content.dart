import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
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
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/affiliate_register/presentation/widgets/affiliate_registration_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState =
        context.findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(ProfileLoadRequested()),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          int cartCount = 0;
          if (cartState is CartLoaded ||
              cartState is CartItemAdded ||
              cartState is CartItemUpdated ||
              cartState is CartItemDeleted) {
            final cart = cartState is CartLoaded
                ? cartState.cart
                : cartState is CartItemAdded
                    ? cartState.cart
                    : cartState is CartItemUpdated
                        ? cartState.cart
                        : (cartState as CartItemDeleted).cart;
            cartCount = cart.totalItems;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBarWidget(
              cartCount: cartCount,
              userInitials: AuthService().userInitials ?? 'U',
              onSearchTap: () {
                // Navigate to search screen when search bar is tapped
                context.push(AppRoutes.productSearch);
              },
              onSearchSubmitted: (String query) {
                // Navigate to search screen with query
                context.push(
                  '${AppRoutes.productSearch}?query=${Uri.encodeComponent(query)}',
                );
                return null;
              },
              onCartTap: () {
                // Navigate to cart tab
                _navigateToTab(context, 2);
              },
              onProfileTap: () {
                // Navigate to profile tab
                _navigateToTab(context, 3);
              },
              hasNotification: false,
              searchPlaceholder: LocalizationService.t(
                context,
                'profile.searchPlaceholder',
              ),
            ),
            body: BlocListener<ProfileBloc, ProfileState>(
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
                          // User Info Card
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
                          // Profile Menu Items
                          _buildMenuItems(context),
                          const SizedBox(height: Spacing.xl),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, ProfileData? profile) {
    final AuthService authService = AuthService();
    final String? userName = profile?.fullName ?? authService.userName;
    final String? userEmail = profile?.emailAddress ?? authService.userEmail;
    final String? userImageUrl = authService.userImageUrl;

    // Generate initials from profile or auth service
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
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Profile picture with subtle ring
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.25),
                width: 1.5,
              ),
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
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: Spacing.sm),
          // Name, email, phone
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  userName ?? LocalizationService.t(context, 'profile.user'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 12,
                      color: Colors.grey[500],
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.phoneNumber,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
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

  Widget _buildReferralCodeCard(BuildContext context, String referralCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.card_giftcard_rounded,
            size: 20,
            color: AppColors.primary,
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
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocalizationService.t(context, 'profile.referralCodeCopied')),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            tooltip: LocalizationService.t(context, 'profile.copyCode'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final state = context.read<ProfileBloc>().state;
    final isAffiliate =
        state is ProfileLoaded && state.affiliateProfile != null;

    final List<_MenuItem> menuItems = <_MenuItem>[
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
            // Refresh profile after returning from edit screen
            context.read<ProfileBloc>().add(ProfileRefreshRequested());
          });
        },
      ),
      _MenuItem(
        icon: Icons.lock_outline,
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
      _MenuItem(
        icon: Icons.location_on_outlined,
        title: LocalizationService.t(context, 'profile.myAddresses'),
        onTap: () {
          context.push(AppRoutes.addresses);
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
        icon: Icons.lock_reset_outlined,
        title: LocalizationService.t(context, 'profile.changePassword'),
        onTap: () {
          ChangePasswordBottomSheet.show(context);
        },
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
      _MenuItem(
        icon: Icons.logout_outlined,
        title: LocalizationService.t(context, 'profile.logOut'),
        onTap: () {
          _showLogoutDialog(context);
        },
        isDestructive: true,
      ),
    ];

    return Column(
      children: menuItems.map((_MenuItem item) {
        return _MenuItemWidget(item: item);
      }).toList(),
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
              // Navigation will be handled automatically by ProfilePage
              // which listens to AuthService changes
            } catch (e) {
              // Show error message if logout fails
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(LocalizationService.t(context, 'profile.logoutFailed')),
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

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
}

class _MenuItemWidget extends StatelessWidget {
  const _MenuItemWidget({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              item.icon,
              color: item.isDestructive ? AppColors.error : AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          item.isDestructive ? AppColors.error : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
