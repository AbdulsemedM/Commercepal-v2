import 'package:flutter/material.dart';
import 'package:commercepal/features/categories/data/models/subcategory_asset_catalog.dart';

class CategoryImageAssets {
  CategoryImageAssets._();

  /// Parent-category assets for sidebar / parent chips.
  static const Map<String, String> _nameToAssetPath = {
    'accessories': 'assets/images/accessories.jpg',
    'cosmetics': 'assets/images/cosmetics.jpg',
    'desktop': 'assets/images/desktop.jpg',
    'electronics': 'assets/images/electronics.jpg',
    'fashion': 'assets/images/fashion.jpg',
    'automotive': 'assets/images/automotive.jpg',
    'auto': 'assets/images/automotive.jpg',
    'vehicle': 'assets/images/automotive.jpg',
    'vehicles': 'assets/images/automotive.jpg',
    'home appliances': 'assets/images/home appliances.jpg',
    'home appliance': 'assets/images/home appliances.jpg',
    'laptop': 'assets/images/laptop.jpg',
    'lotion': 'assets/images/lotion.jpg',
    'makeup': 'assets/images/makeup.jpg',
    "men's watch": "assets/images/men's watch.jpg",
    "men's watches": "assets/images/men's watch.jpg",
    'perfume': 'assets/images/perfume.jpg',
    'smart watch': 'assets/images/smart watch.jpg',
    'smartwatch': 'assets/images/smart watch.jpg',
    'sport': 'assets/images/sport.jpg',
    'tablet': 'assets/images/tablet.jpg',
    'technology': 'assets/images/technology.jpg',
    'watch': 'assets/images/watch.jpg',
    "women's watches": "assets/images/women's watches.jpg",
    "women's watch": "assets/images/women's watches.jpg",
  };

  static String? assetPathForName(String name) {
    final normalized = _normalizeName(name);

    // Nested folder-backed subcategory images first.
    final String? subAsset =
        SubcategoryAssetCatalog.assetPathForSubcategory(name);
    if (subAsset != null) return subAsset;

    final exact = _nameToAssetPath[normalized];
    if (exact != null) return exact;

    // Parent-category soft matching only.
    if (normalized.contains('women') && normalized.contains('watch')) {
      return _nameToAssetPath["women's watches"];
    }
    if (normalized.contains('men') && normalized.contains('watch')) {
      return _nameToAssetPath["men's watch"];
    }
    if (normalized == 'smart watch' || normalized == 'smartwatch') {
      return _nameToAssetPath['smart watch'];
    }
    if (normalized.contains('home') && normalized.contains('appliance')) {
      return _nameToAssetPath['home appliances'];
    }
    if (normalized.contains('automobile') ||
        normalized.contains('automotive') ||
        normalized == 'auto' ||
        normalized == 'vehicle' ||
        normalized == 'vehicles') {
      return _nameToAssetPath['automotive'];
    }
    if (normalized == 'accessories') {
      return _nameToAssetPath['accessories'];
    }
    if (normalized == 'cosmetics' || normalized == 'beauty') {
      return _nameToAssetPath['cosmetics'];
    }
    if (normalized == 'desktop') {
      return _nameToAssetPath['desktop'];
    }
    if (normalized == 'electronics') {
      return _nameToAssetPath['electronics'];
    }
    if (normalized == 'fashion') {
      return _nameToAssetPath['fashion'];
    }
    if (normalized == 'laptop' || normalized == 'laptops') {
      return _nameToAssetPath['laptop'];
    }
    if (normalized == 'lotion') {
      return _nameToAssetPath['lotion'];
    }
    if (normalized == 'makeup') {
      return _nameToAssetPath['makeup'];
    }
    if (normalized == 'perfume') {
      return _nameToAssetPath['perfume'];
    }
    if (normalized == 'sport' || normalized == 'sports') {
      return _nameToAssetPath['sport'];
    }
    if (normalized == 'tablet' || normalized == 'tablets') {
      return _nameToAssetPath['tablet'];
    }
    if (normalized == 'technology') {
      return _nameToAssetPath['technology'];
    }
    if (normalized == 'watch' || normalized == 'watches') {
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
    return name
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
