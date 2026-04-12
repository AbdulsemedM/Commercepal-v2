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
    id: 'fashion',
    title: 'Fashion',
    searchQuery: 'fashion',
  ),
];
