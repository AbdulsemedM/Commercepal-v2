import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/features/profile/presentation/widgets/help_desk_modal.dart';
import 'package:commercepal/features/auth/change_password/presentation/widgets/change_password_dialog.dart';
import 'package:commercepal/features/profile/bloc/profile_bloc.dart';
import 'package:commercepal/features/profile/data/models/profile_data.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(ProfileLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWidget(
          cartCount: 2,
          userInitials: AuthService().userInitials ?? 'U',
          onSearchSubmitted: (String query) {
            // Handle search submission
            return null;
          },
          onProfileTap: () {
            // Already on profile page
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
                  context.read<ProfileBloc>().add(ProfileRefreshRequested());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Profile Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.lg,
                          Spacing.lg,
                          Spacing.lg,
                          Spacing.md,
                        ),
                        child: Text(
                          LocalizationService.t(context, 'profile.title'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                      ),
                      // Search Bar below title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                        ),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: LocalizationService.t(
                                context,
                                'profile.searchPlaceholder',
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade700,
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Spacing.xs,
                                vertical: Spacing.sm,
                              ),
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      // User Info Card
                      _buildUserInfoCard(context, profile),
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
      final lastName = profile.lastName.isNotEmpty
          ? profile.lastName[0].toUpperCase()
          : '';
      userInitials = '$firstName$lastName';
      if (userInitials.isEmpty) {
        userInitials = userEmail?.isNotEmpty == true
            ? userEmail![0].toUpperCase()
            : 'U';
      }
    } else {
      userInitials = authService.userInitials ?? 'U';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Profile Picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: Spacing.md),
          // User Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  userName ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  userEmail ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                if (profile?.phoneNumber != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(
                    profile!.phoneNumber,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final List<_MenuItem> menuItems = <_MenuItem>[
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
        icon: Icons.shopping_cart_outlined,
        title: LocalizationService.t(context, 'profile.orderHistory'),
        onTap: () {
          context.push('/order-history');
        },
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: LocalizationService.t(context, 'profile.faqs'),
        onTap: () {
          // TODO: Navigate to FAQs
        },
      ),
      _MenuItem(
        icon: Icons.lock_reset_outlined,
        title: LocalizationService.t(context, 'profile.changePassword'),
        onTap: () {
          ChangePasswordDialog.show(context);
        },
      ),
      _MenuItem(
        icon: Icons.flag_outlined,
        title: LocalizationService.t(context, 'profile.changeCountry'),
        onTap: () {
          // TODO: Navigate to change country
        },
      ),
      _MenuItem(
        icon: Icons.attach_money_outlined,
        title: LocalizationService.t(context, 'profile.changeCurrency'),
        onTap: () {
          // TODO: Navigate to change currency
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
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(LocalizationService.t(context, 'profile.logOut')),
        content: Text(LocalizationService.t(context, 'profile.logOutConfirm')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.t(context, 'profile.cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await AuthService().logout();
                // Navigation will be handled automatically by ProfilePage
                // which listens to AuthService changes
              } catch (e) {
                // Show error message if logout fails
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              LocalizationService.t(context, 'profile.logOut'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
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
                  color: item.isDestructive ? AppColors.error : Colors.black,
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
