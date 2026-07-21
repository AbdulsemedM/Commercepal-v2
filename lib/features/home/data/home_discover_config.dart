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

const List<HomeDiscoverSectionConfig> kHomeDiscoverSections = [
  HomeDiscoverSectionConfig(
    id: 'smart_phones',
    title: 'Smart phones',
    searchQuery: 'smart phones',
  ),
  HomeDiscoverSectionConfig(
    id: 'watches',
    title: 'Watches',
    searchQuery: 'watch',
  ),
  HomeDiscoverSectionConfig(
    id: 'cosmetics',
    title: 'Cosmetics',
    searchQuery: 'cosmetics',
  ),
  HomeDiscoverSectionConfig(
    id: 'computers',
    title: 'Computers',
    searchQuery: 'laptop computer',
  ),
  HomeDiscoverSectionConfig(
    id: 'womens_fashion',
    title: "Women's Fashion",
    searchQuery: "women's fashion",
  ),
  HomeDiscoverSectionConfig(
    id: 'abayas',
    title: 'Abayas',
    searchQuery: 'abaya',
  ),
  HomeDiscoverSectionConfig(
    id: 'mens_fashion',
    title: "Men's Fashion",
    searchQuery: "men's fashion",
  ),
  HomeDiscoverSectionConfig(
    id: 'audio',
    title: 'Audio',
    searchQuery: 'earpods and headsets',
  ),
];
