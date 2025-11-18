import 'package:flutter/material.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import '../widgets/product_image_section.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_specifications.dart';
import '../widgets/share_section.dart';
import '../widgets/special_offer_section.dart';
import '../widgets/color_selector.dart';
import '../widgets/product_details_button.dart';
import '../widgets/add_to_cart_section.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    this.productId,
    this.productName,
    this.productPrice,
  });

  final String? productId;
  final String? productName;
  final String? productPrice;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _selectedColorIndex = 1; // Default to grey
  int _quantity = 1;
  bool _isInCart = false;

  // Sample data - in real app, this would come from API
  final List<String> _images = <String>['', '', ''];
  final List<Color> _colors = <Color>[
    Colors.white,
    Colors.grey,
    Colors.pink,
    Colors.yellow,
    Colors.lightBlue,
  ];

  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState = context
        .findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sample product data
    final String productName = widget.productName ??
        'Apple iPad Pro 11" (2020) Wifi 128Gb (Silver)- 128Gb/ 11Inch/ Wifi';
    final String productPrice = widget.productPrice ?? '\$904.18';
    final Map<String, String> specifications = <String, String>{
      'Destop': 'LED-Backlit, 11Inch',
      'Chipset/ CPU': 'Apple A12Z Bionic 2.3Ghz',
      'RAM': '128Gb',
      'Operating System': 'iOS 13',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        cartCount: 2,
        userInitials: 'AW',
        onSearchSubmitted: (String query) {
          debugPrint('Search query: $query');
          return null;
        },
        onLogoTap: () {
          Navigator.of(context).pop();
        },
        onCartTap: () {
          _navigateToTab(context, 2);
        },
        onProfileTap: () {
          _navigateToTab(context, 3);
        },
        hasNotification: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: Spacing.sm),
                  // Product images
                  ProductImageSection(
                    images: _images,
                    selectedImageIndex: _selectedImageIndex,
                    onImageSelected: (int index) {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: Spacing.md),
                  // Product info
                  ProductInfoSection(
                    title: productName,
                    price: productPrice,
                    rating: 4.5,
                    reviewCount: 832,
                    code: 'Apple iPad Pro 11" (2020) Wifi 128Gb Silver',
                    category: 'Technology',
                    keywords: 'Apple, Technology, Tablet',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Specifications
                  ProductSpecifications(specifications: specifications),
                  const SizedBox(height: Spacing.lg),
                  // Share section
                  const ShareSection(),
                  const SizedBox(height: Spacing.lg),
                  // Special offer
                  SpecialOfferSection(
                    sold: 700,
                    inStock: 300,
                    initialDuration: const Duration(
                      days: 10,
                      hours: 42,
                      minutes: 0,
                      seconds: 8,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Color selector
                  ColorSelector(
                    colors: _colors,
                    selectedColorIndex: _selectedColorIndex,
                    onColorSelected: (int index) {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Product details button
                  const ProductDetailsButton(),
                  const SizedBox(height: Spacing.xl),
                ],
              ),
            ),
          ),
          // Add to cart section (fixed at bottom)
          AddToCartSection(
            isInCart: _isInCart,
            quantity: _quantity,
            unitPrice: productPrice,
            onAddToCart: () {
              setState(() {
                _isInCart = true;
                _quantity = 1;
              });
            },
            onQuantityChanged: (int newQuantity) {
              setState(() {
                _quantity = newQuantity;
              });
            },
            onToggleFavorite: () {
              // TODO: Handle favorite toggle
            },
          ),
        ],
      ),
    );
  }
}

