class HomeWholesaleSectionConfig {
  const HomeWholesaleSectionConfig({
    required this.id,
    required this.titleKey,
    required this.searchQuery,
    required this.pageSize,
    required this.accountType,
  });

  final String id;
  final String titleKey;
  final String searchQuery;
  final int pageSize;
  final String accountType;
}

const List<HomeWholesaleSectionConfig> kHomeWholesaleSections = [
  HomeWholesaleSectionConfig(
    id: 'bulk',
    titleKey: 'home.wholesale.bulk',
    searchQuery: 'bulk',
    pageSize: 8,
    accountType: 'BUSINESS',
  ),
  HomeWholesaleSectionConfig(
    id: 'manufacturer',
    titleKey: 'home.wholesale.manufacturer',
    searchQuery: 'manufacturer',
    pageSize: 8,
    accountType: 'BUSINESS',
  ),
  HomeWholesaleSectionConfig(
    id: 'wholesale',
    titleKey: 'home.wholesale.wholesale',
    searchQuery: 'wholesale',
    pageSize: 16,
    accountType: 'BUSINESS',
  ),
];
