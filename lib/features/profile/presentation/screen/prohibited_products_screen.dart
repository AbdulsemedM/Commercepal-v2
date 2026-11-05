import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// In-app copy of https://commercepal.com/prohibited-products.
///
/// Like the other policy screens, the policy body is kept in English so the
/// wording matches the published policy exactly.
class ProhibitedProductsScreen extends StatefulWidget {
  const ProhibitedProductsScreen({super.key});

  static const String reportEmail = 'customer@commercepal.com';

  @override
  State<ProhibitedProductsScreen> createState() =>
      _ProhibitedProductsScreenState();
}

class _ProhibitedProductsScreenState extends State<ProhibitedProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Category> get _visibleCategories {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return _categories;
    return _categories
        .where((_Category c) =>
            c.title.toLowerCase().contains(q) ||
            c.items.any((String i) => i.toLowerCase().contains(q)))
        .toList();
  }

  Future<void> _emailReport() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: ProhibitedProductsScreen.reportEmail,
      query: 'subject=${Uri.encodeComponent('Prohibited product report')}',
    );
    bool launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (_) {
      launched = false;
    }
    if (!launched && mounted) {
      AppSnackbars.error(
        context,
        '${LocalizationService.t(context, 'contactUs.couldNotLaunch')} '
        '${ProhibitedProductsScreen.reportEmail}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color pageBg = theme.scaffoldBackgroundColor;
    final List<_Category> visible = _visibleCategories;
    final bool searching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: scheme.onSurface,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.tr('profile.prohibitedProducts'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.xs,
                Spacing.gutter,
                Spacing.xxxl,
              ),
              children: <Widget>[
                const _Hero(),
                const SizedBox(height: Spacing.md),
                const _ImportantNotice(),
                const SizedBox(height: Spacing.md),
                const _PrinciplesRow(),
                const SizedBox(height: Spacing.xl),
                const _Eyebrow('What we restrict'),
                const _SectionTitle('Restricted product categories'),
                const SizedBox(height: Spacing.sm),
                TextField(
                  controller: _searchController,
                  onChanged: (String v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search prohibited product categories',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searching
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                if (visible.isEmpty)
                  _NoMatches(query: _query.trim())
                else
                  for (final _Category c in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.xs),
                      child: _CategoryCard(
                        // Re-key on the query so matches open automatically.
                        key: ValueKey<String>('${c.number}|$searching|$_query'),
                        category: c,
                        query: _query.trim().toLowerCase(),
                        initiallyExpanded: searching,
                      ),
                    ),
                const SizedBox(height: Spacing.xl),
                const _SectionTitle(
                    'What happens if you order a prohibited product?'),
                const SizedBox(height: Spacing.sm),
                const _Steps(),
                const SizedBox(height: Spacing.xl),
                const _SectionTitle('Supplier and customer responsibilities'),
                const SizedBox(height: Spacing.sm),
                _Responsibilities(onEmailTap: _emailReport),
                const SizedBox(height: Spacing.md),
                const _Callout(
                  icon: Icons.balance_outlined,
                  text:
                      'Products with uncertain religious or legal classifications may be referred for compliance or qualified Shariah review. CommercePal may apply restrictions stricter than local law, but does not claim that every prohibited product is illegal in every country.',
                ),
                const SizedBox(height: Spacing.xl),
                _HelpCard(
                  onContactTap: () => context.push(AppRoutes.contactUs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

class _Category {
  const _Category({
    required this.number,
    required this.title,
    required this.icon,
    required this.items,
    this.note,
  });

  final String number;
  final String title;
  final IconData icon;
  final List<String> items;
  final String? note;
}

const List<_Category> _categories = <_Category>[
  _Category(
    number: '01',
    title: 'Alcohol and intoxicating beverages',
    icon: Icons.local_bar_outlined,
    items: <String>[
      'Beer',
      'Wine',
      'Champagne',
      'Whiskey',
      'Vodka',
      'Rum',
      'Gin',
      'Liquor and spirits',
      'Alcoholic cocktails',
      'Alcoholic beverages',
      'Alcohol production kits intended for prohibited consumption',
      'Other intoxicating alcoholic drinks',
    ],
  ),
  _Category(
    number: '02',
    title: 'Pork and non-halal animal products',
    icon: Icons.no_food_outlined,
    items: <String>[
      'Pork meat',
      'Bacon',
      'Ham',
      'Pork sausages',
      'Pork fat',
      'Lard',
      'Pork gelatin used in food',
      'Food containing prohibited pork ingredients',
      'Non-halal meat where Islamic slaughter requirements apply',
      'Other prohibited animal-derived food products',
    ],
  ),
  _Category(
    number: '03',
    title: 'Gambling and betting',
    icon: Icons.casino_outlined,
    items: <String>[
      'Casino gambling equipment',
      'Slot machines',
      'Gambling machines',
      'Lottery tickets',
      'Betting products and services',
      'Online gambling services',
      'Sports betting services',
      'Products primarily intended for gambling activities',
    ],
  ),
  _Category(
    number: '04',
    title: 'Pornography and sexually explicit content',
    icon: Icons.no_adult_content_outlined,
    items: <String>[
      'Pornographic magazines',
      'Pornographic movies and videos',
      'Sexually explicit publications',
      'Pornographic digital content',
      'Adult entertainment subscriptions',
      'Products or services promoting prostitution',
      'Sexually exploitative materials',
    ],
  ),
  _Category(
    number: '05',
    title: 'Sex toys and artificial genital products',
    icon: Icons.block_outlined,
    items: <String>[
      'Plastic or artificial penises',
      'Dildos',
      'Artificial vaginas',
      'Male or female masturbation devices',
      'Vibrators',
      'Sex dolls',
      'Realistic artificial genital products',
      'Anal plugs',
      'BDSM equipment',
      'Sexual fetish accessories',
      'Other products primarily designed for sexual stimulation',
    ],
    note:
        'Legitimate medical devices, personal hygiene products, and reproductive healthcare products are assessed separately rather than automatically classified as prohibited.',
  ),
  _Category(
    number: '06',
    title: 'Drugs and intoxicating substances',
    icon: Icons.medication_outlined,
    items: <String>[
      'Marijuana and recreational cannabis',
      'Recreational THC products',
      'Cocaine',
      'Heroin',
      'Illegal narcotics',
      'Unauthorized controlled substances',
      'Recreational intoxicating drugs',
      'Products primarily intended for illegal drug consumption',
    ],
    note:
        'Legitimate medicines remain subject to applicable pharmacy regulations and medical authorization requirements.',
  ),
  _Category(
    number: '07',
    title: 'Tobacco and nicotine products',
    icon: Icons.smoke_free_outlined,
    items: <String>[
      'Cigarettes',
      'Cigars',
      'Tobacco',
      'Shisha tobacco',
      'Electronic cigarettes',
      'Vaping devices',
      'Vape liquids',
      'Nicotine pouches',
      'Other tobacco and nicotine consumption products',
    ],
  ),
  _Category(
    number: '08',
    title: 'Sorcery and occult products',
    icon: Icons.auto_fix_off_outlined,
    items: <String>[
      'Products specifically intended for black magic',
      'Sorcery equipment',
      'Occult ritual kits intended for prohibited practices',
      'Products explicitly marketed for prohibited magical rituals',
    ],
    note:
        'Educational books, ordinary cultural objects, and lawful religious materials are not automatically blocked merely because they discuss other beliefs.',
  ),
  _Category(
    number: '09',
    title: 'Illegal weapons and dangerous materials',
    icon: Icons.dangerous_outlined,
    items: <String>[
      'Illegal firearms',
      'Unauthorized ammunition',
      'Explosives',
      'Illegal weapons',
      'Prohibited hazardous chemicals',
      'Products designed for criminal activities',
      'Other dangerous items restricted by applicable law',
    ],
  ),
  _Category(
    number: '10',
    title: 'Counterfeit and illegal products',
    icon: Icons.gpp_bad_outlined,
    items: <String>[
      'Counterfeit branded products',
      'Stolen goods',
      'Pirated products',
      'Fraudulent identification documents',
      'Products violating intellectual property rights',
      'Goods prohibited by customs or import regulations',
      'Products linked to trafficking or exploitation',
    ],
  ),
  _Category(
    number: '11',
    title: 'Other Shariah-prohibited products',
    icon: Icons.report_gmailerrorred_outlined,
    items: <String>[
      "Other products that clearly violate CommercePal's adopted ethical and Shariah compliance standards",
    ],
    note:
        'For disputed classifications, CommercePal requires compliance review rather than automatically blocking products based on broad religious or cultural assumptions.',
  ),
];

const List<(String, String)> _steps = <(String, String)>[
  ('Order review', 'CommercePal reviews orders for restricted items.'),
  ('Order cancellation', 'We cancel the affected item or order.'),
  (
    'Refund processing',
    'If payment was collected, we issue the eligible item refund, including applicable item-specific shipping and service fees.'
  ),
  (
    'Customer notification',
    'You receive an explanation of the cancellation and refund.'
  ),
  (
    'Eligible items continue',
    'In a multi-item order, eligible items may continue while only prohibited products are cancelled.'
  ),
];

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

BoxDecoration _card(BuildContext context) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: scheme.surface,
    borderRadius: AppRadius.mdAll,
    border: Border.all(color: context.commerce.border),
  );
}

TextStyle? _body(BuildContext context) =>
    Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.55,
        );

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxs),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.verified_user_outlined,
                  size: AppSizes.iconMd, color: scheme.onPrimaryContainer),
              const SizedBox(width: Spacing.xs),
              Text(
                'CommercePal standards',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Prohibited & Restricted Products Policy',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            'Shopping responsibly with CommercePal.',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'CommercePal connects customers with international suppliers. Because supplier catalogues are automated, restricted items may occasionally appear in search results. A listing is not approval to purchase, process, import, or deliver the item.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportantNotice extends StatelessWidget {
  const _ImportantNotice();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommerceColors c = context.commerce;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: c.warningContainer,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: c.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.warning_amber_rounded,
              color: c.warning, size: AppSizes.iconLg),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Important notice',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: c.onWarningContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  'CommercePal is committed to ethical and Shariah-compliant shopping. We do not process purchases of alcohol, pork, gambling products, pornography, adult sex toys, illegal drugs, or other prohibited items. If a prohibited product is ordered, CommercePal will cancel the affected item and issue a full refund for that item, including any shipping or service charges collected specifically for it.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: c.onWarningContainer,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrinciplesRow extends StatelessWidget {
  const _PrinciplesRow();

  static const List<(IconData, String, String)> _items =
      <(IconData, String, String)>[
    (
      Icons.mosque_outlined,
      'Ethical review',
      'Our standards are informed by Islamic principles, applicable laws, customs rules, and destination-country restrictions.'
    ),
    (
      Icons.inventory_2_outlined,
      'Supplier catalogues',
      'Automated supplier feeds may contain items that CommercePal does not authorize for purchase.'
    ),
    (
      Icons.handshake_outlined,
      'Fair resolution',
      'Policy-based cancellations have no penalty and eligible refunds are returned through the original payment method where possible.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      decoration: _card(context),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < _items.length; i++) ...<Widget>[
            if (i > 0) Divider(height: 1, color: context.commerce.border),
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(Spacing.xs),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Icon(_items[i].$1,
                        size: AppSizes.iconMd, color: scheme.onSurface),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _items[i].$2,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(_items[i].$3, style: _body(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    super.key,
    required this.category,
    required this.query,
    required this.initiallyExpanded,
  });

  final _Category category;
  final String query;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors c = context.commerce;

    return Container(
      decoration: _card(context),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Drop ExpansionTile's default top/bottom dividers.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xxs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            Spacing.md,
            0,
            Spacing.md,
            Spacing.md,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(category.icon,
                size: AppSizes.iconMd, color: scheme.onErrorContainer),
          ),
          title: Text(
            category.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          subtitle: Text(
            '${category.number} · ${category.items.length} '
            '${category.items.length == 1 ? 'item' : 'items'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          children: <Widget>[
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: <Widget>[
                for (final String item in category.items)
                  _ItemChip(
                    label: item,
                    highlighted:
                        query.isNotEmpty && item.toLowerCase().contains(query),
                  ),
              ],
            ),
            if (category.note != null) ...<Widget>[
              const SizedBox(height: Spacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: c.infoContainer,
                  borderRadius: AppRadius.smAll,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.info_outline,
                        size: AppSizes.iconSm, color: c.info),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        category.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: c.onInfoContainer,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  const _ItemChip({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: highlighted ? scheme.primaryContainer : scheme.surfaceContainer,
        borderRadius: AppRadius.pillAll,
        border: highlighted ? Border.all(color: scheme.primary) : null,
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: highlighted ? scheme.onPrimaryContainer : scheme.onSurface,
          fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: _card(context),
      child: Column(
        children: <Widget>[
          Icon(Icons.search_off,
              size: 32, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: Spacing.xs),
          Text(
            'No restricted category matches "$query".',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            'If you are unsure whether an item is eligible, contact customer support before placing an order.',
            textAlign: TextAlign.center,
            style: _body(context),
          ),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < _steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (i < _steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: context.commerce.border,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 3,
                        bottom: i < _steps.length - 1 ? Spacing.md : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _steps[i].$1,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(_steps[i].$2, style: _body(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Spacing.md),
          Text(
            'Refund settlement times depend on the payment provider. We do not display a completed refund status until the payment system confirms it.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Responsibilities extends StatelessWidget {
  const _Responsibilities({required this.onEmailTap});
  final VoidCallback onEmailTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    Widget block(IconData icon, String title, Widget body) {
      return Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: AppSizes.iconLg, color: scheme.primary),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  body,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: _card(context),
      child: Column(
        children: <Widget>[
          block(
            Icons.storefront_outlined,
            'Suppliers',
            Text(
              'All CommercePal suppliers and purchasing partners must comply with this policy. CommercePal may reject prohibited transactions, remove restricted listings, suspend noncompliant suppliers, and terminate partnerships for repeated violations.',
              style: _body(context),
            ),
          ),
          Divider(height: 1, color: context.commerce.border),
          block(
            Icons.person_outline,
            'Customers',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Review product descriptions, ingredients, and specifications before ordering. Report a prohibited product to:',
                  style: _body(context),
                ),
                const SizedBox(height: Spacing.xxs),
                InkWell(
                  onTap: onEmailTap,
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.mail_outline,
                            size: AppSizes.iconSm, color: scheme.primary),
                        const SizedBox(width: Spacing.xxs),
                        Flexible(
                          child: Text(
                            ProhibitedProductsScreen.reportEmail,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: AppSizes.iconMd, color: scheme.onSurfaceVariant),
          const SizedBox(width: Spacing.sm),
          Expanded(child: Text(text, style: _body(context))),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onContactTap});
  final VoidCallback onContactTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.support_agent_outlined,
              size: 32, color: scheme.primary),
          const SizedBox(height: Spacing.xs),
          Text(
            'Need help with a product?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            'If you are unsure whether an item is eligible, contact customer support before placing an order. A policy review is better than an avoidable cancellation.',
            style: _body(context),
          ),
          const SizedBox(height: Spacing.md),
          AppButton.primary(
            label: 'Visit customer help',
            icon: Icons.headset_mic_outlined,
            onPressed: onContactTap,
          ),
        ],
      ),
    );
  }
}
