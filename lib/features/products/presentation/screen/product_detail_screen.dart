import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/profile/bloc/profile_bloc.dart';
import 'package:commercepal/services/auth_service.dart';
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

  String _getCurrency(BuildContext context) {
    // Try to get from ProfileBloc if available
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        return profileState.profile.preferredCurrency ?? 'USD';
      }
    } catch (e) {
      // ProfileBloc not available
    }
    // Default currency
    return 'USD';
  }

  String _getCountry(BuildContext context) {
    // Try to get from ProfileBloc if available
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        return profileState.profile.country;
      }
    } catch (e) {
      // ProfileBloc not available
    }
    // Default country
    return 'US';
  }

  String _getConfigId() {
    // Use selected color index as configId (or generate from color)
    // For now, use a simple string representation
    return 'config_$_selectedColorIndex';
  }

  void _handleAddToCart(BuildContext context) {
    if (widget.productId == null || widget.productId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product ID is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get or create CartBloc
    CartBloc cartBloc;
    try {
      cartBloc = context.read<CartBloc>();
    } catch (e) {
      // CartBloc not in context, create new one
      cartBloc = CartBloc();
    }

    final String currency = _getCurrency(context);
    final String country = _getCountry(context);
    final String configId = _getConfigId();

    cartBloc.add(
      CartAddItemRequested(
        productId: widget.productId!,
        configId: configId,
        quantity: _quantity,
        currency: currency,
        country: country,
      ),
    );
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

    // Get or create CartBloc
    CartBloc cartBloc;
    try {
      cartBloc = context.read<CartBloc>();
    } catch (e) {
      cartBloc = CartBloc();
    }

    return BlocProvider.value(
      value: cartBloc,
      child: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartItemAdded) {
            setState(() {
              _isInCart = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item added to cart'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            int cartCount = 0;
            if (cartState is CartLoaded ||
                cartState is CartItemAdded ||
                cartState is CartItemUpdated ||
                cartState is CartItemDeleted) {
              final cart = cartState is CartLoaded
                  ? cartState.cart
                  : cartState is CartItemAdded
                      ? cartState.cart
                      : cartState is CartItemUpdated
                          ? cartState.cart
                          : (cartState as CartItemDeleted).cart;
              cartCount = cart.totalItems;
            }
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBarWidget(
                cartCount: cartCount,
                userInitials: AuthService().userInitials ?? 'U',
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
                  ProductDetailsButton(
                    productId: widget.productId,
                    productName: productName,
                  ),
                  const SizedBox(height: Spacing.xl),
                ],
              ),
            ),
          ),
          // Add to cart section (fixed at bottom)
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              // Check if item is in cart
              bool itemInCart = _isInCart;
              if (cartState is CartLoaded ||
                  cartState is CartItemAdded ||
                  cartState is CartItemUpdated ||
                  cartState is CartItemDeleted) {
                final cart = cartState is CartLoaded
                    ? cartState.cart
                    : cartState is CartItemAdded
                        ? cartState.cart
                        : cartState is CartItemUpdated
                            ? cartState.cart
                            : (cartState as CartItemDeleted).cart;
                itemInCart = cart.items.any(
                  (item) => item.productId == widget.productId,
                );
                if (itemInCart && !_isInCart) {
                  // Update local state if item was just added
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isInCart = true;
                      });
                    }
                  });
                }
              }

              return AddToCartSection(
                isInCart: itemInCart,
                quantity: _quantity,
                unitPrice: productPrice,
                onAddToCart: () {
                  _handleAddToCart(context);
                },
                onQuantityChanged: (int newQuantity) {
                  if (itemInCart && widget.productId != null) {
                    // Update quantity in cart
                    final cartState = context.read<CartBloc>().state;
                    if (cartState is CartLoaded ||
                        cartState is CartItemAdded ||
                        cartState is CartItemUpdated ||
                        cartState is CartItemDeleted) {
                      final cart = cartState is CartLoaded
                          ? cartState.cart
                          : cartState is CartItemAdded
                              ? cartState.cart
                              : cartState is CartItemUpdated
                                  ? cartState.cart
                                  : (cartState as CartItemDeleted).cart;
                      final cartItem = cart.items.firstWhere(
                        (item) => item.productId == widget.productId,
                        orElse: () => throw StateError('Item not found'),
                      );
                      context.read<CartBloc>().add(
                            CartUpdateItemRequested(
                              itemId: cartItem.id,
                              quantity: newQuantity,
                            ),
                          );
                    }
                  } else {
                    // Just update local quantity if not in cart yet
                    setState(() {
                      _quantity = newQuantity;
                    });
                  }
                },
                onToggleFavorite: () {
                  // TODO: Handle favorite toggle
                },
              );
            },
          ),
        ],
      ),
            );
          },
        ),
      ),
    );
  }
}

