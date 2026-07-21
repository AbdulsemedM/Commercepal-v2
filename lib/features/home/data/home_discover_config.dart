/// Curated home discover sections: search keywords can be tuned against the API.
class HomeDiscoverSectionConfig {
  const HomeDiscoverSectionConfig({
    required this.id,
    required this.title,
    required this.searchQuery,
  });

  final String id;
  final String title;
  final String searchQuery;
}

/// Queries tuned to match commercepal.com search phrasing so the API returns
/// affiliate catalog items (with originalPrice / discount% / ratings), not
/// Alibaba wholesale rows that omit those fields.
const List<HomeDiscoverSectionConfig> kHomeDiscoverSections = [
  HomeDiscoverSectionConfig(
    id: 'smart_phones',
    title: 'Smart phones',
    searchQuery: 'global firmware phone',
  ),
  HomeDiscoverSectionConfig(
    id: 'watches',
    title: 'Watches',
    searchQuery: 'wrist watch',
  ),
  HomeDiscoverSectionConfig(
    id: 'cosmetics',
    title: 'Cosmetics',
    searchQuery: 'makeup',
  ),
  HomeDiscoverSectionConfig(
    id: 'computers',
    title: 'Computers',
    searchQuery: 'laptop',
  ),
  HomeDiscoverSectionConfig(
    id: 'womens_fashion',
    title: "Women's Fashion",
    searchQuery: 'women dress clothing',
  ),
  HomeDiscoverSectionConfig(
    id: 'abayas',
    title: 'Abayas',
    searchQuery: 'islamic abaya',
  ),
  HomeDiscoverSectionConfig(
    id: 'mens_fashion',
    title: "Men's Fashion",
    searchQuery: 'mens fashion',
  ),
  HomeDiscoverSectionConfig(
    id: 'audio',
    title: 'Audio',
    searchQuery: 'earbuds',
  ),
];
