import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/localization_service.dart';

/// Header extension under the search bar on Home: "Deliver to …" line and a
/// scrolling strip of quick links (deals, promos).
///
/// Sits on the same brand band as [AppBarWidget], so the two read as one
/// header, Amazon-style.
class HomeHeaderExtras extends StatefulWidget {
  const HomeHeaderExtras({super.key});

  /// Height below the search bar (delivery line + quick links).
  static const double height = 88;

  @override
  State<HomeHeaderExtras> createState() => _HomeHeaderExtrasState();
}

class _HomeHeaderExtrasState extends State<HomeHeaderExtras> {
  String _countryCode = 'ET';

  @override
  void initState() {
    super.initState();
    Storage().getSelectedCountry().then((String code) {
      if (mounted) setState(() => _countryCode = code);
    }).catchError((Object _) {});
  }

  void _onDeliverTap() {
    HapticFeedback.selectionClick();
    if (AuthService().isLoggedIn) {
      context.push(AppRoutes.addresses);
    } else {
      context.push(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CommerceColors c = context.commerce;
    final ThemeData theme = Theme.of(context);
    final String country =
        CountryCurrencyConstants.getCountryName(_countryCode);

    return ColoredBox(
      color: c.header,
      child: SizedBox(
        height: HomeHeaderExtras.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Deliver to …
            Semantics(
              button: true,
              label: context.tr('home.deliverTo', <String, Object?>{
                'place': country,
              }),
              excludeSemantics: true,
              child: InkWell(
                onTap: _onDeliverTap,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    Spacing.gutter,
                    Spacing.xxs,
                    Spacing.gutter,
                    Spacing.xs,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: c.onHeader,
                      ),
                      const SizedBox(width: Spacing.xxs),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: '${context.tr('home.deliverToLabel')} ',
                                style: TextStyle(
                                  color: c.onHeader.withValues(alpha: 0.8),
                                ),
                              ),
                              TextSpan(
                                text: country,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: c.onHeader,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: c.onHeader,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(child: _QuickLinks()),
          ],
        ),
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    final List<Widget> links = <Widget>[
      _HeaderPill(
        icon: Icons.local_offer_outlined,
        label: context.tr('home.discover.todays_deals'),
        onTap: () => context.push(
          '${AppRoutes.productSearch}?query=${Uri.encodeComponent('sale discount deal')}',
        ),
      ),
      _HeaderPill(
        icon: Icons.bolt_rounded,
        label: context.tr('home.banner.megaSale'),
        onTap: () => context.push(AppRoutes.megaSale),
      ),
      _HeaderPill(
        icon: Icons.new_releases_outlined,
        label: context.tr('home.banner.newArrivals'),
        onTap: () => context.push(AppRoutes.salePromotion),
      ),
      _HeaderPill(
        icon: Icons.grid_view_rounded,
        label: context.tr('home.categories.title'),
        onTap: () => context
            .findAncestorStateOfType<DashboardScreenState>()
            ?.changeTab(1),
      ),
    ];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter,
        0,
        Spacing.gutter,
        Spacing.sm,
      ),
      itemCount: links.length,
      separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
      itemBuilder: (_, int i) => links[i],
    );
  }
}

/// Pill on the brand header: translucent white background.
class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CommerceColors c = context.commerce;
    final ThemeData theme = Theme.of(context);
    final Color fg = c.onHeader;

    return Semantics(
      button: true,
      child: Material(
        color: c.onHeader.withValues(alpha: 0.14),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
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
