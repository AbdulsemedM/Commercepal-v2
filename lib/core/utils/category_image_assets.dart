import 'package:flutter/material.dart';

class CategoryImageAssets {
  CategoryImageAssets._();

  // Exact-name mapping (case-insensitive after normalization).
  static const Map<String, String> _nameToAssetPath = {
    'accessories': 'assets/images/accessories.jpg',
    'bags': 'assets/images/accessories.jpg',
    'belts': 'assets/images/accessories.jpg',
    'sunglasses': 'assets/images/accessories.jpg',
    'hats': 'assets/images/accessories.jpg',
    'wallets': 'assets/images/accessories.jpg',
    'cosmetics': 'assets/images/cosmetics.jpg',
    'skincare': 'assets/images/cosmetics.jpg',
    'hair care': 'assets/images/cosmetics.jpg',
    'desktop': 'assets/images/desktop.jpg',
    'desktop pcs': 'assets/images/desktop.jpg',
    'monitors': 'assets/images/desktop.jpg',
    'electronics': 'assets/images/electronics.jpg',
    'smartphones': 'assets/images/electronics.jpg',
    'android phones': 'assets/images/electronics.jpg',
    'headphones': 'assets/images/electronics.jpg',
    'bluetooth earbuds': 'assets/images/electronics.jpg',
    'chargers': 'assets/images/electronics.jpg',
    'phone cases': 'assets/images/electronics.jpg',
    'power banks': 'assets/images/electronics.jpg',
    'speakers': 'assets/images/electronics.jpg',
    'fashion': 'assets/images/fashion.jpg',
    "women's clothing": 'assets/images/fashion.jpg',
    "men's clothing": 'assets/images/fashion.jpg',
    'dresses': 'assets/images/fashion.jpg',
    'shoes': 'assets/images/fashion.jpg',
    'sneakers': 'assets/images/fashion.jpg',
    'automotive': 'assets/images/automotive.jpg',
    'auto': 'assets/images/automotive.jpg',
    'vehicle': 'assets/images/automotive.jpg',
    'vehicles': 'assets/images/automotive.jpg',
    'car accessories': 'assets/images/automotive.jpg',
    'car chargers': 'assets/images/automotive.jpg',
    'dash cams': 'assets/images/automotive.jpg',
    'car covers': 'assets/images/automotive.jpg',
    'home appliances': 'assets/images/home appliances.jpg',
    'home appliance': 'assets/images/home appliances.jpg',
    'blenders': 'assets/images/home appliances.jpg',
    'irons': 'assets/images/home appliances.jpg',
    'vacuum cleaners': 'assets/images/home appliances.jpg',
    'air fryers': 'assets/images/home appliances.jpg',
    'rice cookers': 'assets/images/home appliances.jpg',
    'laptop': 'assets/images/laptop.jpg',
    'laptops': 'assets/images/laptop.jpg',
    'gaming laptops': 'assets/images/laptop.jpg',
    'laptop bags': 'assets/images/laptop.jpg',
    'laptop stands': 'assets/images/laptop.jpg',
    'laptop chargers': 'assets/images/laptop.jpg',
    'lotion': 'assets/images/lotion.jpg',
    'body lotion': 'assets/images/lotion.jpg',
    'hand cream': 'assets/images/lotion.jpg',
    'face cream': 'assets/images/lotion.jpg',
    'makeup': 'assets/images/makeup.jpg',
    'foundation': 'assets/images/makeup.jpg',
    'lipstick': 'assets/images/makeup.jpg',
    'mascara': 'assets/images/makeup.jpg',
    'eyeshadow': 'assets/images/makeup.jpg',
    "men's watch": "assets/images/men's watch.jpg",
    "men's watches": "assets/images/men's watch.jpg",
    'analog watches': "assets/images/men's watch.jpg",
    'digital watches': "assets/images/men's watch.jpg",
    'luxury watches': "assets/images/men's watch.jpg",
    'perfume': 'assets/images/perfume.jpg',
    "women's perfume": 'assets/images/perfume.jpg',
    "men's cologne": 'assets/images/perfume.jpg',
    'body mist': 'assets/images/perfume.jpg',
    'smart watch': 'assets/images/smart watch.jpg',
    'smartwatch': 'assets/images/smart watch.jpg',
    'smart watches': 'assets/images/smart watch.jpg',
    'fitness trackers': 'assets/images/smart watch.jpg',
    'smart watch bands': 'assets/images/smart watch.jpg',
    'sport': 'assets/images/sport.jpg',
    'sports': 'assets/images/sport.jpg',
    'sports shoes': 'assets/images/sport.jpg',
    'fitness equipment': 'assets/images/sport.jpg',
    'yoga mats': 'assets/images/sport.jpg',
    'dumbbells': 'assets/images/sport.jpg',
    'sportswear': 'assets/images/sport.jpg',
    'tablet': 'assets/images/tablet.jpg',
    'tablets': 'assets/images/tablet.jpg',
    'android tablets': 'assets/images/tablet.jpg',
    'tablet cases': 'assets/images/tablet.jpg',
    'technology': 'assets/images/technology.jpg',
    'watch': 'assets/images/watch.jpg',
    'watches': 'assets/images/watch.jpg',
    'watch straps': 'assets/images/watch.jpg',
    "women's watches": "assets/images/women's watches.jpg",
    "women's watch": "assets/images/women's watches.jpg",
    'fashion watches': "assets/images/women's watches.jpg",
    'jewelry watches': "assets/images/women's watches.jpg",
  };

  static String? assetPathForName(String name) {
    final normalized = _normalizeName(name);

    final exact = _nameToAssetPath[normalized];
    if (exact != null) return exact;

    // More forgiving matching for backend variations like "Sports" or "Sport & Fitness".
    if (normalized.contains('women') && normalized.contains('watch')) {
      return _nameToAssetPath["women's watches"];
    }
    if (normalized.contains('men') && normalized.contains('watch')) {
      return _nameToAssetPath["men's watch"];
    }
    if (normalized.contains('smart watch') ||
        normalized.contains('smartwatch')) {
      return _nameToAssetPath['smart watch'];
    }
    if (normalized.contains('home') && normalized.contains('appliance')) {
      return _nameToAssetPath['home appliances'];
    }
    if (normalized.contains('automobile') ||
        normalized.contains('automotive') ||
        (normalized.contains('auto') && !normalized.contains('autoradio'))) {
      return _nameToAssetPath['automotive'];
    }
    if (normalized.contains('vehicle') || normalized.contains('car ')) {
      return _nameToAssetPath['automotive'];
    }
    if (normalized.contains('accessor') ||
        normalized.contains('wallet') ||
        normalized.contains('belt') ||
        normalized.contains('sunglass')) {
      return _nameToAssetPath['accessories'];
    }
    if (normalized.contains('cosmetic') ||
        normalized.contains('beauty') ||
        normalized.contains('skincare')) {
      return _nameToAssetPath['cosmetics'];
    }
    if (normalized.contains('desktop')) {
      return _nameToAssetPath['desktop'];
    }
    if (normalized.contains('phone') ||
        normalized.contains('headphone') ||
        normalized.contains('earbud') ||
        normalized.contains('electronic') ||
        normalized.contains('charger') ||
        normalized.contains('speaker')) {
      return _nameToAssetPath['electronics'];
    }
    if (normalized.contains('fashion') ||
        normalized.contains('cloth') ||
        normalized.contains('dress') ||
        normalized.contains('shoe') ||
        normalized.contains('sneaker')) {
      return _nameToAssetPath['fashion'];
    }
    if (normalized.contains('laptop')) {
      return _nameToAssetPath['laptop'];
    }
    if (normalized.contains('lotion') || normalized.contains('cream')) {
      return _nameToAssetPath['lotion'];
    }
    if (normalized.contains('makeup') ||
        normalized.contains('lipstick') ||
        normalized.contains('mascara') ||
        normalized.contains('foundation')) {
      return _nameToAssetPath['makeup'];
    }
    if (normalized.contains('perfume') ||
        normalized.contains('cologne') ||
        normalized.contains('fragrance')) {
      return _nameToAssetPath['perfume'];
    }
    if (normalized.contains('sport') ||
        normalized.contains('fitness') ||
        normalized.contains('yoga') ||
        normalized.contains('dumbbell')) {
      return _nameToAssetPath['sport'];
    }
    if (normalized.contains('tablet')) {
      return _nameToAssetPath['tablet'];
    }
    if (normalized.contains('technology')) {
      return _nameToAssetPath['technology'];
    }
    if (normalized.contains('blender') ||
        normalized.contains('vacuum') ||
        normalized.contains('fryer') ||
        normalized.contains('cooker') ||
        normalized.contains('iron')) {
      return _nameToAssetPath['home appliances'];
    }
    if (normalized.contains('watch')) {
      return _nameToAssetPath['watch'];
    }

    return null;
  }

  /// Category/subcategory icon fallback used when we can't display an image.
  static IconData iconForName(String categoryName) {
    final name = _normalizeName(categoryName);
    if (name.contains('cosmetic') || name.contains('beauty')) {
      return Icons.face;
    } else if (name.contains('fashion') || name.contains('cloth')) {
      return Icons.checkroom;
    } else if (name.contains('comput') || name.contains('electronic')) {
      return Icons.laptop;
    } else if (name.contains('sport') || name.contains('fitness')) {
      return Icons.sports_soccer;
    } else if (name.contains('furniture') || name.contains('home')) {
      return Icons.chair;
    } else if (name.contains('food') || name.contains('grocery')) {
      return Icons.restaurant;
    } else if (name.contains('book') || name.contains('education')) {
      return Icons.book;
    } else if (name.contains('toy') || name.contains('game')) {
      return Icons.toys;
    } else if (name.contains('health') || name.contains('medical')) {
      return Icons.local_hospital;
    } else if (name.contains('auto') || name.contains('vehicle')) {
      return Icons.directions_car;
    } else if (name.contains('pet')) {
      return Icons.pets;
    } else if (name.contains('jewelry') || name.contains('watch')) {
      return Icons.watch;
    } else if (name.contains('phone') || name.contains('mobile')) {
      return Icons.phone_android;
    } else if (name.contains('garden')) {
      return Icons.yard;
    }
    return Icons.category;
  }

  static String _normalizeName(String name) {
    // Normalize casing/whitespace and flatten punctuation to spaces so matching
    // survives backend variations (e.g. "Sport & Fitness", "Smartwatch").
    return name
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[-_]+'), ' ')
        // Keep apostrophes for names like "men's watch", otherwise drop punctuation.
        .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
