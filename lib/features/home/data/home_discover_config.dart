/// Curated home discover sections — queries aligned with commercepal.com.
///
/// The website merges multiple search queries for carousel rows (Today's deals,
/// More to love, …). Prefer those exact phrases: the API often routes them to
/// the affiliate catalog (with discount % + ratings). Nearby phrasings fall
/// back to Alibaba wholesale rows that omit that metadata.
class HomeDiscoverSectionConfig {
  const HomeDiscoverSectionConfig({
    required this.id,
    required this.title,
    required this.searchQuery,
    this.searchQueries = const <String>[],
  });

  final String id;
  final String title;

  /// Primary query used for "See more" navigation.
  final String searchQuery;

  /// Extra queries merged into this section (same strategy as the website).
  /// When empty, only [searchQuery] is fetched.
  final List<String> searchQueries;

  /// All queries to fetch for this section.
  /// When [searchQueries] is set (web-style multi-query), those alone are
  /// fetched; [searchQuery] is only used for "See more" navigation.
  List<String> get allQueries {
    final source =
        searchQueries.isNotEmpty ? searchQueries : <String>[searchQuery];
    final seen = <String>{};
    final out = <String>[];
    for (final q in source) {
      final trimmed = q.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) continue;
      out.add(trimmed);
    }
    return out;
  }
}

/// Matches commercepal.com homepage section search phrasing.
const List<HomeDiscoverSectionConfig> kHomeDiscoverSections = [
  // Web carousel: Today's deals (multi-query merge).
  HomeDiscoverSectionConfig(
    id: 'todays_deals',
    title: "Today's Deals",
    searchQuery: 'sale discount deal',
    searchQueries: <String>[
      'phone sale',
      'smart watch discount',
      'women dress deal',
      'bluetooth earbuds offer',
      'laptop computer sale',
    ],
  ),
  // Web grid: Phones & Accessories
  HomeDiscoverSectionConfig(
    id: 'smart_phones',
    title: 'Smart phones',
    searchQuery: 'smartphone mobile phone',
  ),
  // Web "More to love" uses "watch" (affiliate); "smart watch" falls back to Alibaba.
  HomeDiscoverSectionConfig(
    id: 'watches',
    title: 'Watches',
    searchQuery: 'watch',
  ),
  // Web: skincare beauty
  HomeDiscoverSectionConfig(
    id: 'cosmetics',
    title: 'Cosmetics',
    searchQuery: 'skincare beauty',
  ),
  // "laptop computer sale" keeps affiliate inventory; plain "laptop computer" often does not.
  HomeDiscoverSectionConfig(
    id: 'computers',
    title: 'Computers',
    searchQuery: 'laptop computer sale',
  ),
  // Web: Women's Fashion
  HomeDiscoverSectionConfig(
    id: 'womens_fashion',
    title: "Women's Fashion",
    searchQuery: 'women dress clothing',
  ),
  // Web: Abayas
  HomeDiscoverSectionConfig(
    id: 'abayas',
    title: 'Abayas',
    searchQuery: 'abaya women islamic dress',
  ),
  // Web: Men's Fashion
  HomeDiscoverSectionConfig(
    id: 'mens_fashion',
    title: "Men's Fashion",
    searchQuery: 'men shirt jeans',
  ),
  HomeDiscoverSectionConfig(
    id: 'shoes',
    title: 'Shoes',
    searchQuery: 'shoe discount',
  ),
  // Web: Audio
  HomeDiscoverSectionConfig(
    id: 'audio',
    title: 'Audio',
    searchQuery: 'bluetooth earbuds headphones',
  ),
];
