import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/profile/bloc/profile_bloc.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/navigation_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import '../../bloc/product_details_bloc.dart';
import '../../bloc/product_details_event.dart';
import '../../bloc/product_details_state.dart';
import '../../data/repository/product_details_repository.dart';
import '../../data/models/product.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_specifications.dart';
import '../widgets/add_to_cart_section.dart';
import '../widgets/multi_variant_selector_widget.dart';
import '../../data/models/product_details.dart';
import '../widgets/reviews_section_widget.dart';
import '../widgets/recommended_products_section.dart';
import '../widgets/product_detail_shimmer.dart';
import 'package:commercepal/features/wishlist/data/wishlist_item.dart';
import 'package:commercepal/features/wishlist/data/repository/wishlist_repository.dart';

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
  int _quantity = 1;
  bool _isInCart = false;
  bool _isInWishlist = false;
  String? _wishlistStateLoadedForProductId;
  String _cachedCountry = 'US'; // Default, will be loaded in initState
  // Map to track multiple variants with their quantities
  // Key: variant index, Value: quantity
  final Map<int, int> _selectedVariants = <int, int>{};

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    NavigationService.instance.navigateToDashboardTab(context, tabIndex);
  }

  String _getCurrency(BuildContext context) {
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        return profileState.profile.preferredCurrency ?? 'USD';
      }
    } catch (e) {
      // ProfileBloc not available
    }
    return 'USD';
  }

  Future<void> _loadCountry() async {
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        setState(() {
          _cachedCountry = profileState.profile.country;
        });
        return;
      }
    } catch (e) {
      // ProfileBloc not available
    }
    // Fallback to saved country from settings
    final storage = Storage();
    final country = await storage.getSelectedCountry();
    if (mounted) {
      setState(() {
        _cachedCountry = country;
      });
    }
  }

  String _getCountry(BuildContext context) {
    return _cachedCountry;
  }

  Future<void> _launchUrlString(String url) async {
    if (url.trim().isEmpty) return;
    String normalized = url.trim();
    if (!normalized.toLowerCase().startsWith('http://') &&
        !normalized.toLowerCase().startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    try {
      final uri = Uri.parse(normalized);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleAddToCart(
    BuildContext context,
    ProductDetails productDetails,
  ) {
    if (widget.productId == null || widget.productId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product ID is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool hasVariants = productDetails.variants.isNotEmpty;

    // If product has variants, user must select at least one
    if (hasVariants && _selectedVariants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one variant'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final String currency = _getCurrency(context);
    final String country = _getCountry(context);

    if (!hasVariants) {
      // No variants: add product with default config (no variant selection needed)
      final cartProduct = Product.fromProductDetails(productDetails);
      context.read<CartBloc>().add(
        CartAddItemRequested(
          productId: widget.productId!,
          configId: '',
          quantity: _quantity,
          currency: currency,
          country: country,
          product: cartProduct,
        ),
      );
      return;
    }

    // Has variants: add all selected variants to cart
    for (final entry in _selectedVariants.entries) {
      final variantIndex = entry.key;
      final quantity = entry.value;

      if (quantity > 0 && variantIndex < productDetails.variants.length) {
        final variant = productDetails.variants[variantIndex];
        final cartProduct = Product.fromProductDetails(
          productDetails,
          variantIndex: variantIndex,
        );

        context.read<CartBloc>().add(
          CartAddItemRequested(
            productId: widget.productId!,
            configId: variant.configId,
            quantity: quantity,
            currency: currency,
            country: country,
            product: cartProduct,
          ),
        );
      }
    }

    setState(() {
      _selectedVariants.clear();
    });
  }
  
  void _handleVariantToggled(int variantIndex) {
    setState(() {
      if (_selectedVariants.containsKey(variantIndex)) {
        // Remove variant if already selected
        _selectedVariants.remove(variantIndex);
      } else {
        // Add variant with quantity 1
        _selectedVariants[variantIndex] = 1;
      }
    });
  }
  
  void _handleQuantityChanged((int, int) data) {
    final (variantIndex, newQuantity) = data;
    setState(() {
      if (newQuantity <= 0) {
        _selectedVariants.remove(variantIndex);
      } else {
        _selectedVariants[variantIndex] = newQuantity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the CartBloc provided at the app level
    return BlocProvider(
      create: (context) =>
          ProductDetailsBloc(repository: ProductDetailsRepository())..add(
            ProductDetailsFetchRequested(
              productId: widget.productId ?? '',
              country: _getCountry(context),
              currency: _getCurrency(context),
            ),
          ),
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
                onSearchTap: () {
                  context.push(AppRoutes.productSearch);
                },
                onSearchSubmitted: (String query) {
                  context.push(
                    '${AppRoutes.productSearch}?query=${Uri.encodeComponent(query)}',
                  );
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
              body: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
                builder: (context, state) {
                  if (state is ProductDetailsLoading) {
                    return const ProductDetailShimmer();
                  }

                  if (state is ProductDetailsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: Spacing.md),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: Spacing.lg),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<ProductDetailsBloc>().add(
                                  ProductDetailsFetchRequested(
                                    productId: widget.productId ?? '',
                                    country: _getCountry(context),
                                    currency: _getCurrency(context),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ProductDetailsLoaded) {
                    final product = state.productDetails;
                    if (product.id != _wishlistStateLoadedForProductId) {
                      _wishlistStateLoadedForProductId = product.id;
                      Storage().isInWishlist(product.id).then((bool inList) {
                        if (mounted) {
                          setState(() => _isInWishlist = inList);
                        }
                      });
                    }
                    final selectedVariant = product.variants.isNotEmpty
                        ? product.variants[state.selectedVariantIndex]
                        : null;
                    final currentPrice =
                        selectedVariant?.pricing?.formattedCurrentPrice ??
                        product.pricing.formattedCurrentPrice;

                    return Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              context.read<ProductDetailsBloc>().add(
                                ProductDetailsRefreshRequested(
                                  productId: widget.productId ?? '',
                                  country: _getCountry(context),
                                  currency: _getCurrency(context),
                                ),
                              );
                            },
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: Spacing.sm),
                                  // Product images (use mainImage when images list is empty)
                                  ProductImageGallery(
                                    images: product.images.isNotEmpty
                                        ? product.images
                                        : (product.mainImage.main.isNotEmpty
                                            ? [product.mainImage]
                                            : []),
                                  ),
                                  const SizedBox(height: Spacing.md),
                                  // Product info
                                  ProductInfoSection(
                                    title: product.title,
                                    price: currentPrice,
                                    rating: product.meta.rating,
                                    reviewCount: product.meta.reviewCount,
                                    code: product.id,
                                    category: product.categoryId,
                                    keywords: product.brandName,
                                    vendorName: product.vendorName.isNotEmpty ? product.vendorName : null,
                                    provider: product.provider.isNotEmpty ? product.provider : null,
                                    stockLevel: product.stockLevel,
                                    status: product.status.isNotEmpty ? product.status : null,
                                    stuffStatus: product.stuffStatus.isNotEmpty ? product.stuffStatus : null,
                                    createdTime: product.createdTime.isNotEmpty ? product.createdTime : null,
                                    updatedTime: product.updatedTime.isNotEmpty ? product.updatedTime : null,
                                    isSellAllowed: product.isSellAllowed,
                                  ),
                                  const SizedBox(height: Spacing.lg),
                                  // Description
                                  if (product.description.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Description',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: Spacing.sm),
                                          ...product.description.map(
                                            (paragraph) => Padding(
                                              padding: const EdgeInsets.only(bottom: Spacing.xs),
                                              child: Text(
                                                paragraph,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.grey[800],
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: Spacing.lg),
                                  ],
                                  // Multi-variant selector
                                  if (product.variants.isNotEmpty)
                                    MultiVariantSelectorWidget(
                                      variants: product.variants,
                                      selectedVariants: _selectedVariants,
                                      onVariantToggled: _handleVariantToggled,
                                      onQuantityChanged: _handleQuantityChanged,
                                    ),
                                  const SizedBox(height: Spacing.lg),
                                  // Specifications (if available)
                                  if (product.physicalParameters.weight > 0 ||
                                      product.physicalParameters.length > 0 ||
                                      product.physicalParameters.width > 0 ||
                                      product.physicalParameters.height > 0 ||
                                      product.minOrderQuantity > 1 ||
                                      product.quantityStep > 1 ||
                                      product.hasHierarchicalConfigurators)
                                    ProductSpecifications(
                                      specifications: {
                                        if (product.physicalParameters.length > 0)
                                          'Length': '${product.physicalParameters.length}cm',
                                        if (product.physicalParameters.width > 0)
                                          'Width': '${product.physicalParameters.width}cm',
                                        if (product.physicalParameters.height > 0)
                                          'Height': '${product.physicalParameters.height}cm',
                                        if (product.physicalParameters.weight > 0)
                                          'Weight': '${product.physicalParameters.weight}g',
                                        if (product.minOrderQuantity > 1)
                                          'Min. order quantity': '${product.minOrderQuantity}',
                                        if (product.quantityStep > 1)
                                          'Quantity step': '${product.quantityStep}',
                                        if (product.hasHierarchicalConfigurators)
                                          'Configurable options': 'Yes',
                                      },
                                    ),
                                  const SizedBox(height: Spacing.lg),
                                  // Videos
                                  if (product.videos.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Videos',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: Spacing.sm),
                                          ...product.videos.asMap().entries.map((entry) {
                                            final i = entry.key + 1;
                                            final video = entry.value;
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: Spacing.sm),
                                              child: InkWell(
                                                onTap: () => _launchUrlString(video.url),
                                                borderRadius: BorderRadius.circular(8),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.play_circle_outline, size: 32, color: Theme.of(context).colorScheme.primary),
                                                    const SizedBox(width: Spacing.sm),
                                                    Expanded(
                                                      child: Text(
                                                        'Video $i',
                                                        style: Theme.of(context).textTheme.bodyMedium,
                                                      ),
                                                    ),
                                                    const Icon(Icons.open_in_new, size: 18),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: Spacing.lg),
                                  ],
                                  // External link
                                  if (product.externalUrl.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                                      child: OutlinedButton.icon(
                                        onPressed: () => _launchUrlString(product.externalUrl),
                                        icon: const Icon(Icons.open_in_new, size: 18),
                                        label: const Text('View on seller site'),
                                      ),
                                    ),
                                    const SizedBox(height: Spacing.lg),
                                  ],
                                  // Reviews section
                                  if (product.customerReviews.isNotEmpty)
                                    ReviewsSectionWidget(
                                      reviews: product.customerReviews,
                                      averageRating: product.meta.rating,
                                      totalReviews: product.meta.reviewCount,
                                      onViewAllTap: () {
                                        context.push(
                                          '${AppRoutes.productDetailsReviews}?productId=${widget.productId}',
                                        );
                                      },
                                    ),
                                  const SizedBox(height: Spacing.lg),
                                  // Recommended products
                                  if (product.recommendedProducts.isNotEmpty)
                                    RecommendedProductsSection(
                                      products: product.recommendedProducts,
                                    ),
                                  const SizedBox(height: Spacing.xl),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Add to cart section (fixed at bottom)
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, cartState) {
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
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(() {
                                      _isInCart = true;
                                    });
                                  }
                                });
                              }
                            }

                            // Calculate total quantity and price for selected variants
                            int totalQuantity = _selectedVariants.values.fold(0, (sum, qty) => sum + qty);
                            double totalPrice = 0.0;
                            for (final entry in _selectedVariants.entries) {
                              final variantIndex = entry.key;
                              final quantity = entry.value;
                              if (variantIndex < product.variants.length) {
                                final variant = product.variants[variantIndex];
                                final price = variant.pricing?.currentPrice ?? product.pricing.currentPrice;
                                totalPrice += price * quantity;
                              }
                            }
                            
                            final hasSelectedVariants = _selectedVariants.isNotEmpty;

                            return AddToCartSection(
                              isInCart: itemInCart && !hasSelectedVariants,
                              isInWishlist: _isInWishlist,
                              quantity: totalQuantity > 0 ? totalQuantity : _quantity,
                              unitPrice: hasSelectedVariants
                                  ? '${product.pricing.currency} ${MoneyFormatter.formatAmount(totalPrice)}'
                                  : currentPrice,
                              onAddToCart: () {
                                _handleAddToCart(context, product);
                              },
                              onQuantityChanged: (int newQuantity) {
                                // This is handled by the multi-variant selector
                                // Keep for backward compatibility
                                if (!hasSelectedVariants) {
                                  setState(() {
                                    _quantity = newQuantity;
                                  });
                                }
                              },
                              onToggleFavorite: () async {
                                final repository = WishlistRepository();
                                if (_isInWishlist) {
                                  await repository.removeItem(product.id);
                                } else {
                                  final imageUrl = product.mainImage.main.isNotEmpty
                                      ? product.mainImage.main
                                      : product.mainImage.thumbnail;
                                  await repository.addItem(WishlistItem(
                                    productId: product.id,
                                    productName: product.title,
                                    imageUrl: imageUrl,
                                  ));
                                }
                                if (mounted) {
                                  setState(() => _isInWishlist = !_isInWishlist);
                                }
                              },
                            );
                          },
                        ),
                      ],
                    );
                  }

                  // Initial state
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
