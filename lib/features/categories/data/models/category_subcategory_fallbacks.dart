import 'category.dart';
import 'sub_category.dart';

/// Minimum number of subcategories every parent category should expose in the UI.
const int kMinSubCategoriesPerCategory = 4;

/// Client-side catalog of thoughtful, searchable subcategory names keyed by
/// normalized parent-category aliases.
///
/// Tapping a subcategory opens product search with the subcategory [name], so
/// phrases should be concrete product search terms rather than vague labels.
class CategorySubcategoryFallbacks {
  CategorySubcategoryFallbacks._();

  /// Known parent groups → curated searchable subcategory names.
  static const Map<String, List<String>> _catalog = {
    // Electronics / Technology
    'electronics': [
      'Smartphones',
      'Laptops',
      'Headphones',
      'Smart Watches',
      'Tablets',
      'Chargers',
    ],
    'technology': [
      'Smartphones',
      'Laptops',
      'Headphones',
      'Smart Watches',
      'Tablets',
      'Chargers',
    ],
    'tech': [
      'Smartphones',
      'Laptops',
      'Headphones',
      'Smart Watches',
    ],

    // Phones / Tablets
    'phones': [
      'Smartphones',
      'Phone Cases',
      'Chargers',
      'Screen Protectors',
      'Power Banks',
    ],
    'mobile': [
      'Smartphones',
      'Phone Cases',
      'Chargers',
      'Screen Protectors',
    ],
    'smartphone': [
      'Android Phones',
      'Phone Cases',
      'Chargers',
      'Power Banks',
    ],
    'tablets': [
      'Android Tablets',
      'Tablet Cases',
      'Stylus Pens',
      'Tablet Keyboards',
    ],
    'tablet': [
      'Android Tablets',
      'Tablet Cases',
      'Stylus Pens',
      'Tablet Keyboards',
    ],

    // Computers
    'computers': [
      'Laptops',
      'Desktop PCs',
      'Monitors',
      'Keyboards',
      'Computer Mice',
    ],
    'computer': [
      'Laptops',
      'Desktop PCs',
      'Monitors',
      'Keyboards',
    ],
    'laptop': [
      'Gaming Laptops',
      'Laptop Bags',
      'Laptop Stands',
      'Laptop Chargers',
    ],
    'laptops': [
      'Gaming Laptops',
      'Laptop Bags',
      'Laptop Stands',
      'Laptop Chargers',
    ],
    'desktop': [
      'Desktop PCs',
      'Monitors',
      'Keyboards',
      'Webcams',
    ],

    // Fashion
    'fashion': [
      "Women's Clothing",
      "Men's Clothing",
      'Shoes',
      'Bags',
      'Accessories',
    ],
    'clothing': [
      "Women's Clothing",
      "Men's Clothing",
      'Shoes',
      'Bags',
    ],
    'clothes': [
      "Women's Clothing",
      "Men's Clothing",
      'Shoes',
      'Bags',
    ],
    "women's fashion": [
      'Dresses',
      'Tops',
      'Handbags',
      'Women Shoes',
    ],
    'womens fashion': [
      'Dresses',
      'Tops',
      'Handbags',
      'Women Shoes',
    ],
    "men's fashion": [
      'Men Shirts',
      'Men Jeans',
      'Men Shoes',
      'Men Jackets',
    ],
    'mens fashion': [
      'Men Shirts',
      'Men Jeans',
      'Men Shoes',
      'Men Jackets',
    ],
    'shoes': [
      'Sneakers',
      'Sandals',
      'Boots',
      'Formal Shoes',
    ],
    'abaya': [
      'Abayas',
      'Hijabs',
      'Modest Dresses',
      'Prayer Clothes',
    ],
    'abayas': [
      'Abayas',
      'Hijabs',
      'Modest Dresses',
      'Prayer Clothes',
    ],

    // Beauty / Cosmetics
    'cosmetics': [
      'Makeup',
      'Skincare',
      'Perfume',
      'Hair Care',
      'Lotion',
    ],
    'beauty': [
      'Makeup',
      'Skincare',
      'Perfume',
      'Hair Care',
    ],
    'makeup': [
      'Foundation',
      'Lipstick',
      'Mascara',
      'Eyeshadow',
    ],
    'perfume': [
      "Women's Perfume",
      "Men's Cologne",
      'Body Mist',
      'Gift Sets',
    ],
    'skincare': [
      'Moisturizer',
      'Face Wash',
      'Serum',
      'Sunscreen',
    ],
    'lotion': [
      'Body Lotion',
      'Hand Cream',
      'Face Cream',
      'Sunscreen',
    ],

    // Home / Appliances
    'home appliances': [
      'Blenders',
      'Irons',
      'Vacuum Cleaners',
      'Air Fryers',
      'Rice Cookers',
    ],
    'home appliance': [
      'Blenders',
      'Irons',
      'Vacuum Cleaners',
      'Air Fryers',
    ],
    'appliances': [
      'Blenders',
      'Irons',
      'Vacuum Cleaners',
      'Air Fryers',
    ],
    'home': [
      'Kitchen Tools',
      'Bedding',
      'Lighting',
      'Storage',
    ],
    'home and life': [
      'Kitchen Tools',
      'Bedding',
      'Lighting',
      'Storage',
    ],
    'furniture': [
      'Sofas',
      'Tables',
      'Chairs',
      'Shelves',
    ],

    // Automotive
    'automotive': [
      'Car Accessories',
      'Car Chargers',
      'Dash Cams',
      'Car Covers',
      'Phone Holders',
    ],
    'auto': [
      'Car Accessories',
      'Car Chargers',
      'Dash Cams',
      'Car Covers',
    ],
    'vehicles': [
      'Car Accessories',
      'Car Chargers',
      'Dash Cams',
      'Car Covers',
    ],
    'vehicle': [
      'Car Accessories',
      'Car Chargers',
      'Dash Cams',
      'Car Covers',
    ],

    // Sports
    'sport': [
      'Sports Shoes',
      'Fitness Equipment',
      'Yoga Mats',
      'Water Bottles',
      'Sportswear',
    ],
    'sports': [
      'Sports Shoes',
      'Fitness Equipment',
      'Yoga Mats',
      'Water Bottles',
    ],
    'sporting': [
      'Sports Shoes',
      'Fitness Equipment',
      'Yoga Mats',
      'Water Bottles',
    ],
    'fitness': [
      'Dumbbells',
      'Yoga Mats',
      'Resistance Bands',
      'Sportswear',
    ],

    // Watches / Jewelry
    'watch': [
      'Smart Watches',
      "Men's Watches",
      "Women's Watches",
      'Watch Straps',
    ],
    'watches': [
      'Smart Watches',
      "Men's Watches",
      "Women's Watches",
      'Watch Straps',
    ],
    'smart watch': [
      'Fitness Trackers',
      'Smart Watch Bands',
      'Chargers',
      'Protective Cases',
    ],
    'smartwatch': [
      'Fitness Trackers',
      'Smart Watch Bands',
      'Chargers',
      'Protective Cases',
    ],
    "men's watch": [
      'Analog Watches',
      'Digital Watches',
      'Watch Straps',
      'Luxury Watches',
    ],
    "men's watches": [
      'Analog Watches',
      'Digital Watches',
      'Watch Straps',
      'Luxury Watches',
    ],
    "women's watches": [
      'Analog Watches',
      'Fashion Watches',
      'Watch Straps',
      'Jewelry Watches',
    ],
    "women's watch": [
      'Analog Watches',
      'Fashion Watches',
      'Watch Straps',
      'Jewelry Watches',
    ],
    'jewelry': [
      'Necklaces',
      'Earrings',
      'Bracelets',
      'Rings',
    ],

    // Accessories
    'accessories': [
      'Bags',
      'Belts',
      'Sunglasses',
      'Hats',
      'Wallets',
    ],

    // Children / Baby
    'baby': [
      'Baby Clothes',
      'Diapers',
      'Baby Toys',
      'Feeding Bottles',
    ],
    'baby products': [
      'Baby Clothes',
      'Diapers',
      'Baby Toys',
      'Feeding Bottles',
    ],
    'kids': [
      'Kids Clothes',
      'Toys',
      'School Bags',
      'Kids Shoes',
    ],
    'toys': [
      'Educational Toys',
      'Action Figures',
      'Board Games',
      'Soft Toys',
    ],

    // Grocery / Food
    'grocery': [
      'Snacks',
      'Beverages',
      'Cooking Oil',
      'Spices',
    ],
    'food': [
      'Snacks',
      'Beverages',
      'Cooking Oil',
      'Spices',
    ],

    // Health
    'health': [
      'Vitamins',
      'First Aid',
      'Thermometers',
      'Face Masks',
    ],
    'medical': [
      'First Aid',
      'Thermometers',
      'Face Masks',
      'Hand Sanitizer',
    ],

    // Books / Education
    'books': [
      'Novels',
      'Children Books',
      'Educational Books',
      'Notebooks',
    ],
    'education': [
      'Notebooks',
      'Stationery',
      'Educational Books',
      'Backpacks',
    ],

    // Pets
    'pets': [
      'Pet Food',
      'Pet Toys',
      'Pet Beds',
      'Pet Collars',
    ],
    'pet': [
      'Pet Food',
      'Pet Toys',
      'Pet Beds',
      'Pet Collars',
    ],

    // Garden
    'garden': [
      'Garden Tools',
      'Plant Pots',
      'Seeds',
      'Watering Cans',
    ],

    // Audio
    'audio': [
      'Headphones',
      'Bluetooth Earbuds',
      'Speakers',
      'Microphones',
    ],

    // Real estate (locale key; keep useful shoppable terms)
    'real estate': [
      'Home Decor',
      'Lighting',
      'Storage',
      'Furniture',
    ],
  };

  /// Generic searchable fillers when the parent category is unknown.
  static const List<String> _genericFallbacks = [
    'Best Sellers',
    'New Arrivals',
    'Top Deals',
    'Popular Picks',
  ];

  /// Curated Unsplash product/lifestyle images for fallback subcategory names.
  /// Keys are normalized via [_normalizeKey].
  static const Map<String, String> _imageBySubcategoryName = {
    // Electronics
    'smartphones':
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=400&h=400&q=80',
    'android phones':
        'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?auto=format&fit=crop&w=400&h=400&q=80',
    'laptops':
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=400&h=400&q=80',
    'gaming laptops':
        'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?auto=format&fit=crop&w=400&h=400&q=80',
    'headphones':
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=400&h=400&q=80',
    'bluetooth earbuds':
        'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&w=400&h=400&q=80',
    'smart watches':
        'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&w=400&h=400&q=80',
    'tablets':
        'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=400&h=400&q=80',
    'android tablets':
        'https://images.unsplash.com/photo-1561154464-82e9adf32764?auto=format&fit=crop&w=400&h=400&q=80',
    'chargers':
        'https://images.unsplash.com/photo-1583863788434-e58a3638745c?auto=format&fit=crop&w=400&h=400&q=80',
    'phone cases':
        'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?auto=format&fit=crop&w=400&h=400&q=80',
    'screen protectors':
        'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=400&h=400&q=80',
    'power banks':
        'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?auto=format&fit=crop&w=400&h=400&q=80',
    'tablet cases':
        'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=400&h=400&q=80',
    'stylus pens':
        'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?auto=format&fit=crop&w=400&h=400&q=80',
    'tablet keyboards':
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=400&h=400&q=80',
    'desktop pcs':
        'https://images.unsplash.com/photo-1587831990711-23ca6441447b?auto=format&fit=crop&w=400&h=400&q=80',
    'monitors':
        'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=400&h=400&q=80',
    'keyboards':
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=400&h=400&q=80',
    'computer mice':
        'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&w=400&h=400&q=80',
    'laptop bags':
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=400&h=400&q=80',
    'laptop stands':
        'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&w=400&h=400&q=80',
    'laptop chargers':
        'https://images.unsplash.com/photo-1583863788434-e58a3638745c?auto=format&fit=crop&w=400&h=400&q=80',
    'webcams':
        'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?auto=format&fit=crop&w=400&h=400&q=80',
    'speakers':
        'https://images.unsplash.com/photo-1545454675-5371b7be7a0f?auto=format&fit=crop&w=400&h=400&q=80',
    'microphones':
        'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=400&h=400&q=80',
    'protective cases':
        'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?auto=format&fit=crop&w=400&h=400&q=80',
    'smart watch bands':
        'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&w=400&h=400&q=80',
    'fitness trackers':
        'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?auto=format&fit=crop&w=400&h=400&q=80',

    // Fashion
    "women's clothing":
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=400&h=400&q=80',
    "men's clothing":
        'https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?auto=format&fit=crop&w=400&h=400&q=80',
    'shoes':
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=400&h=400&q=80',
    'bags':
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=400&h=400&q=80',
    'accessories':
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=400&h=400&q=80',
    'dresses':
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=400&h=400&q=80',
    'tops':
        'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&w=400&h=400&q=80',
    'handbags':
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=400&h=400&q=80',
    'women shoes':
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=400&h=400&q=80',
    'men shirts':
        'https://images.unsplash.com/photo-1596755094514-f87e34085b85?auto=format&fit=crop&w=400&h=400&q=80',
    'men jeans':
        'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=400&h=400&q=80',
    'men shoes':
        'https://images.unsplash.com/photo-1614252234970-2f4a2b2c0e0a?auto=format&fit=crop&w=400&h=400&q=80',
    'men jackets':
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=400&h=400&q=80',
    'sneakers':
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=400&h=400&q=80',
    'sandals':
        'https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=400&h=400&q=80',
    'boots':
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?auto=format&fit=crop&w=400&h=400&q=80',
    'formal shoes':
        'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=400&h=400&q=80',
    'abayas':
        'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?auto=format&fit=crop&w=400&h=400&q=80',
    'hijabs':
        'https://images.unsplash.com/photo-1594737625785-c62885e0b2e5?auto=format&fit=crop&w=400&h=400&q=80',
    'modest dresses':
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=400&h=400&q=80',
    'prayer clothes':
        'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?auto=format&fit=crop&w=400&h=400&q=80',
    'belts':
        'https://images.unsplash.com/photo-1624222247344-550fb60583fd?auto=format&fit=crop&w=400&h=400&q=80',
    'sunglasses':
        'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=400&h=400&q=80',
    'hats':
        'https://images.unsplash.com/photo-1521369909029-2afed882baee?auto=format&fit=crop&w=400&h=400&q=80',
    'wallets':
        'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=400&h=400&q=80',

    // Beauty
    'makeup':
        'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=400&h=400&q=80',
    'skincare':
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=400&h=400&q=80',
    'perfume':
        'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=400&h=400&q=80',
    'hair care':
        'https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?auto=format&fit=crop&w=400&h=400&q=80',
    'lotion':
        'https://images.unsplash.com/photo-1570194065650-d99fb4b38b17?auto=format&fit=crop&w=400&h=400&q=80',
    'foundation':
        'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=400&h=400&q=80',
    'lipstick':
        'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=400&h=400&q=80',
    'mascara':
        'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=400&h=400&q=80',
    'eyeshadow':
        'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=400&h=400&q=80',
    "women's perfume":
        'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=400&h=400&q=80',
    "men's cologne":
        'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=400&h=400&q=80',
    'body mist':
        'https://images.unsplash.com/photo-1615634260167-c8cdede054de?auto=format&fit=crop&w=400&h=400&q=80',
    'gift sets':
        'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?auto=format&fit=crop&w=400&h=400&q=80',
    'moisturizer':
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=400&h=400&q=80',
    'face wash':
        'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=400&h=400&q=80',
    'serum':
        'https://images.unsplash.com/photo-1620916569885-8bb45f0c0f0e?auto=format&fit=crop&w=400&h=400&q=80',
    'sunscreen':
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=400&h=400&q=80',
    'body lotion':
        'https://images.unsplash.com/photo-1570194065650-d99fb4b38b17?auto=format&fit=crop&w=400&h=400&q=80',
    'hand cream':
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=400&h=400&q=80',
    'face cream':
        'https://images.unsplash.com/photo-1620916569885-8bb45f0c0f0e?auto=format&fit=crop&w=400&h=400&q=80',

    // Home / appliances
    'blenders':
        'https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=400&h=400&q=80',
    'irons':
        'https://images.unsplash.com/photo-1582735689369-4fe89db7110c?auto=format&fit=crop&w=400&h=400&q=80',
    'vacuum cleaners':
        'https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=400&h=400&q=80',
    'air fryers':
        'https://images.unsplash.com/photo-1585515320310-259814833e62?auto=format&fit=crop&w=400&h=400&q=80',
    'rice cookers':
        'https://images.unsplash.com/photo-1585515320310-259814833e62?auto=format&fit=crop&w=400&h=400&q=80',
    'kitchen tools':
        'https://images.unsplash.com/photo-1556910103-1c02745aae4d?auto=format&fit=crop&w=400&h=400&q=80',
    'bedding':
        'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=400&h=400&q=80',
    'lighting':
        'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?auto=format&fit=crop&w=400&h=400&q=80',
    'storage':
        'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&w=400&h=400&q=80',
    'sofas':
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=400&h=400&q=80',
    'tables':
        'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?auto=format&fit=crop&w=400&h=400&q=80',
    'chairs':
        'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?auto=format&fit=crop&w=400&h=400&q=80',
    'shelves':
        'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&w=400&h=400&q=80',
    'home decor':
        'https://images.unsplash.com/photo-1513519245088-0e12902e35a6?auto=format&fit=crop&w=400&h=400&q=80',
    'furniture':
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=400&h=400&q=80',

    // Automotive
    'car accessories':
        'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=400&h=400&q=80',
    'car chargers':
        'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?auto=format&fit=crop&w=400&h=400&q=80',
    'dash cams':
        'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?auto=format&fit=crop&w=400&h=400&q=80',
    'car covers':
        'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=400&h=400&q=80',
    'phone holders':
        'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=400&h=400&q=80',

    // Sports
    'sports shoes':
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=400&h=400&q=80',
    'fitness equipment':
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=400&h=400&q=80',
    'yoga mats':
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=400&h=400&q=80',
    'water bottles':
        'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=400&h=400&q=80',
    'sportswear':
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=400&h=400&q=80',
    'dumbbells':
        'https://images.unsplash.com/photo-1576678927484-cc907957088c?auto=format&fit=crop&w=400&h=400&q=80',
    'resistance bands':
        'https://images.unsplash.com/photo-1598289431512-b97b0917acc7?auto=format&fit=crop&w=400&h=400&q=80',

    // Watches / jewelry
    "men's watches":
        'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=400&h=400&q=80',
    "women's watches":
        'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=400&h=400&q=80',
    'watch straps':
        'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=400&h=400&q=80',
    'analog watches':
        'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=400&h=400&q=80',
    'digital watches':
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=400&h=400&q=80',
    'luxury watches':
        'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=400&h=400&q=80',
    'fashion watches':
        'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=400&h=400&q=80',
    'jewelry watches':
        'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=400&h=400&q=80',
    'necklaces':
        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=400&h=400&q=80',
    'earrings':
        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=400&h=400&q=80',
    'bracelets':
        'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?auto=format&fit=crop&w=400&h=400&q=80',
    'rings':
        'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=400&h=400&q=80',

    // Kids / baby
    'baby clothes':
        'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=400&h=400&q=80',
    'diapers':
        'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=400&h=400&q=80',
    'baby toys':
        'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=400&h=400&q=80',
    'feeding bottles':
        'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=400&h=400&q=80',
    'kids clothes':
        'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=400&h=400&q=80',
    'toys':
        'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=400&h=400&q=80',
    'school bags':
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=400&h=400&q=80',
    'kids shoes':
        'https://images.unsplash.com/photo-1514989940723-e8e51635b782?auto=format&fit=crop&w=400&h=400&q=80',
    'educational toys':
        'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=400&h=400&q=80',
    'action figures':
        'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=400&h=400&q=80',
    'board games':
        'https://images.unsplash.com/photo-1632501641765-e568d28b0015?auto=format&fit=crop&w=400&h=400&q=80',
    'soft toys':
        'https://images.unsplash.com/photo-1530325553241-4f6e7690cf36?auto=format&fit=crop&w=400&h=400&q=80',

    // Grocery / health
    'snacks':
        'https://images.unsplash.com/photo-1621939514649-38399d33ef0f?auto=format&fit=crop&w=400&h=400&q=80',
    'beverages':
        'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=400&h=400&q=80',
    'cooking oil':
        'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=400&h=400&q=80',
    'spices':
        'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=400&h=400&q=80',
    'vitamins':
        'https://images.unsplash.com/photo-1550572017-edd951aa8f72?auto=format&fit=crop&w=400&h=400&q=80',
    'first aid':
        'https://images.unsplash.com/photo-1603398938378-e54eab446dde?auto=format&fit=crop&w=400&h=400&q=80',
    'thermometers':
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&h=400&q=80',
    'face masks':
        'https://images.unsplash.com/photo-1584634731339-252c65282f1e?auto=format&fit=crop&w=400&h=400&q=80',
    'hand sanitizer':
        'https://images.unsplash.com/photo-1584483762360-1377d7d4e0c0?auto=format&fit=crop&w=400&h=400&q=80',

    // Books / education
    'novels':
        'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&h=400&q=80',
    'children books':
        'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&h=400&q=80',
    'educational books':
        'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=400&h=400&q=80',
    'notebooks':
        'https://images.unsplash.com/photo-1531346878377-a5be20888e57?auto=format&fit=crop&w=400&h=400&q=80',
    'stationery':
        'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?auto=format&fit=crop&w=400&h=400&q=80',
    'backpacks':
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=400&h=400&q=80',

    // Pets
    'pet food':
        'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=400&h=400&q=80',
    'pet toys':
        'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?auto=format&fit=crop&w=400&h=400&q=80',
    'pet beds':
        'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=400&h=400&q=80',
    'pet collars':
        'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=400&h=400&q=80',

    // Garden
    'garden tools':
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=400&h=400&q=80',
    'plant pots':
        'https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&w=400&h=400&q=80',
    'seeds':
        'https://images.unsplash.com/photo-1466692476866-aef1dfb1e735?auto=format&fit=crop&w=400&h=400&q=80',
    'watering cans':
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=400&h=400&q=80',

    // Generic
    'best sellers':
        'https://images.unsplash.com/photo-1607083206869-4c79715e2278?auto=format&fit=crop&w=400&h=400&q=80',
    'new arrivals':
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=400&h=400&q=80',
    'top deals':
        'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&w=400&h=400&q=80',
    'popular picks':
        'https://images.unsplash.com/photo-1472851294608-062f824d29cc?auto=format&fit=crop&w=400&h=400&q=80',
  };

  /// Returns a curated HTTPS image URL for a fallback subcategory name.
  static String? imageUrlFor(String subcategoryName) {
    return _imageBySubcategoryName[_normalizeKey(subcategoryName)];
  }

  /// Ensures [category] has at least [kMinSubCategoriesPerCategory] unique
  /// subcategories. Preserves existing API entries (order and content) and
  /// appends curated fillers only as needed.
  static Category enrich(Category category) {
    final existing = List<SubCategory>.from(category.subCategories);
    final seen = <String>{
      for (final sub in existing) _normalizeKey(sub.name),
    };

    if (existing.length >= kMinSubCategoriesPerCategory) {
      return category;
    }

    final fallbackNames = fallbackNamesFor(category.name);
    var nextOrder = existing.isEmpty
        ? 1
        : existing
                .map((s) => s.displayOrder)
                .fold<int>(0, (a, b) => a > b ? a : b) +
            1;

    for (final name in fallbackNames) {
      if (existing.length >= kMinSubCategoriesPerCategory) break;
      final key = _normalizeKey(name);
      if (key.isEmpty || !seen.add(key)) continue;

      existing.add(
        SubCategory(
          name: name,
          slug: slugify(name),
          description: null,
          imageUrl: imageUrlFor(name),
          displayOrder: nextOrder++,
          categoryName: category.name,
          providerId: category.providerId,
        ),
      );
    }

    // Absolute safety net if curated list was too short after dedupe.
    var genericIndex = 0;
    while (existing.length < kMinSubCategoriesPerCategory &&
        genericIndex < _genericFallbacks.length) {
      final name = _genericFallbacks[genericIndex++];
      final key = _normalizeKey(name);
      if (!seen.add(key)) continue;
      existing.add(
        SubCategory(
          name: name,
          slug: slugify(name),
          description: null,
          imageUrl: imageUrlFor(name),
          displayOrder: nextOrder++,
          categoryName: category.name,
          providerId: category.providerId,
        ),
      );
    }

    return Category(
      id: category.id,
      name: category.name,
      slug: category.slug,
      code: category.code,
      description: category.description,
      imageUrl: category.imageUrl,
      displayOrder: category.displayOrder,
      providerId: category.providerId,
      subCategories: existing,
    );
  }

  /// Enriches every category in [categories].
  static List<Category> enrichAll(List<Category> categories) {
    return categories.map(enrich).toList(growable: false);
  }

  /// Resolves curated subcategory names for a parent [categoryName].
  static List<String> fallbackNamesFor(String categoryName) {
    final normalized = _normalizeKey(categoryName);
    if (normalized.isEmpty) return List<String>.from(_genericFallbacks);

    final exact = _catalog[normalized];
    if (exact != null) return List<String>.from(exact);

    // Alias / contains matching for backend naming variations.
    for (final entry in _catalog.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return List<String>.from(entry.value);
      }
    }

    // Keyword heuristics for compound names.
    if (_containsAny(normalized, const ['electronic', 'technolog', 'gadget'])) {
      return List<String>.from(_catalog['electronics']!);
    }
    if (_containsAny(normalized, const ['phone', 'mobile'])) {
      return List<String>.from(_catalog['phones']!);
    }
    if (_containsAny(normalized, const ['laptop', 'computer', 'pc'])) {
      return List<String>.from(_catalog['computers']!);
    }
    if (_containsAny(normalized, const ['fashion', 'cloth', 'apparel'])) {
      return List<String>.from(_catalog['fashion']!);
    }
    if (_containsAny(normalized, const ['cosmetic', 'beauty', 'makeup'])) {
      return List<String>.from(_catalog['cosmetics']!);
    }
    if (_containsAny(normalized, const ['appliance'])) {
      return List<String>.from(_catalog['home appliances']!);
    }
    if (_containsAny(normalized, const ['auto', 'vehicle', 'car'])) {
      return List<String>.from(_catalog['automotive']!);
    }
    if (_containsAny(normalized, const ['sport', 'fitness'])) {
      return List<String>.from(_catalog['sports']!);
    }
    if (_containsAny(normalized, const ['watch', 'jewelry', 'jewellery'])) {
      return List<String>.from(_catalog['watches']!);
    }
    if (_containsAny(normalized, const ['accessor'])) {
      return List<String>.from(_catalog['accessories']!);
    }
    if (_containsAny(normalized, const ['baby', 'kid', 'child', 'toy'])) {
      return List<String>.from(_catalog['baby']!);
    }
    if (_containsAny(normalized, const ['garden', 'outdoor'])) {
      return List<String>.from(_catalog['garden']!);
    }
    if (_containsAny(normalized, const ['pet'])) {
      return List<String>.from(_catalog['pets']!);
    }
    if (_containsAny(normalized, const ['food', 'grocery'])) {
      return List<String>.from(_catalog['grocery']!);
    }
    if (_containsAny(normalized, const ['health', 'medical'])) {
      return List<String>.from(_catalog['health']!);
    }
    if (_containsAny(normalized, const ['book', 'education', 'stationery'])) {
      return List<String>.from(_catalog['books']!);
    }
    if (_containsAny(normalized, const ['audio', 'headphone', 'speaker'])) {
      return List<String>.from(_catalog['audio']!);
    }
    if (_containsAny(normalized, const ['home', 'furniture', 'kitchen'])) {
      return List<String>.from(_catalog['home']!);
    }

    return List<String>.from(_genericFallbacks);
  }

  static String slugify(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r"[^a-z0-9\s-]"), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static String _normalizeKey(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final needle in needles) {
      if (haystack.contains(needle)) return true;
    }
    return false;
  }
}
