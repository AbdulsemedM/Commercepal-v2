import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
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
import '../widgets/in_app_product_video.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_specifications.dart';
import '../widgets/add_to_cart_section.dart';
import '../widgets/multi_variant_selector_widget.dart';
import '../../data/models/product_details.dart';
import '../../data/models/product_image.dart';
import '../widgets/reviews_section_widget.dart';
import '../widgets/recommended_products_section.dart';
import '../widgets/product_detail_shimmer.dart';
import '../widgets/product_detail_action_pills.dart';
import '../widgets/product_details_error_view.dart';
import 'package:commercepal/features/wishlist/data/wishlist_item.dart';
import 'package:commercepal/features/wishlist/data/repository/wishlist_repository.dart';
import 'package:commercepal/features/products/presentation/widgets/product_actions_sheet.dart';
import 'package:commercepal/services/app_analytics.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    this.productId,
    this.productName,
    this.productPrice,
    this.productImage,
    this.productRating,
    this.productReviewCount,
  });

  final String? productId;

  /// Fallback data carried over from the card that opened this screen, used
  /// when the API returns an empty product record.
  final String? productName;
  final String? productPrice;
  final String? productImage;
  final double? productRating;
  final int? productReviewCount;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isInCart = false;
  bool _isInWishlist = false;
  bool _isAddingToCart = false;
  String? _wishlistStateLoadedForProductId;
  String _cachedCountry = 'ET'; // Default Ethiopia, will be loaded in initState
  // Map to track multiple variants with their quantities
  // Key: variant index, Value: quantity
  final Map<int, int> _selectedVariants = <int, int>{};
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reviewsKey = GlobalKey();

  String? _lastRecordedViewProductId;
  String? _lastAnalyticsProductId;

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleWishlist(ProductDetails product) async {
    HapticFeedback.selectionClick();
    final WishlistRepository repository = WishlistRepository();
    if (_isInWishlist) {
      await repository.removeItem(product.id);
    } else {
      final String imageUrl = product.mainImage.main.isNotEmpty
          ? product.mainImage.main
          : product.mainImage.thumbnail;
      await repository.addItem(
        WishlistItem(
          productId: product.id,
          productName: product.title,
          imageUrl: imageUrl,
        ),
      );
    }
    if (mounted) {
      setState(() => _isInWishlist = !_isInWishlist);
    }
  }

  void _scrollToReviews() {
    final BuildContext? target = _reviewsKey.currentContext;
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No customer feedback yet')),
      );
      return;
    }
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  Map<String, String> _buildSpecifications(ProductDetails product) {
    final Map<String, String> specs = <String, String>{
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
      if (product.hasHierarchicalConfigurators) 'Configurable options': 'Yes',
    };

    for (final String line in product.description) {
      final int colon = line.indexOf(':');
      if (colon <= 0 || colon >= line.length - 1) continue;
      final String key = line.substring(0, colon).trim();
      final String value = line.substring(colon + 1).trim();
      if (key.isEmpty || value.isEmpty || key.length > 40) continue;
      if (value.length > 120) continue;
      specs.putIfAbsent(key, () => value);
    }
    return specs;
  }

  List<String> _descriptionParagraphs(ProductDetails product) {
    return product.description.where((String line) {
      final int colon = line.indexOf(':');
      if (colon <= 0 || colon >= line.length - 1) return true;
      final String key = line.substring(0, colon).trim();
      final String value = line.substring(colon + 1).trim();
      if (key.isEmpty || value.isEmpty || key.length > 40) return true;
      if (value.length > 120) return true;
      return false;
    }).toList();
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    NavigationService.instance.navigateToDashboardTab(context, tabIndex);
  }

  String _getCurrency(BuildContext context) {
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        return profileState.profile.preferredCurrency ?? 'ETB';
      }
    } catch (e) {
      // ProfileBloc not available
    }
    return 'ETB';
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

  Future<void> _recordLocalViewAndLogAnalytics(ProductDetails product) async {
    // Skip empty records (dead catalog entries) so recently-viewed doesn't
    // fill up with blank tiles.
    if (product.title.isEmpty) return;
    if (_lastRecordedViewProductId == product.id) return;
    _lastRecordedViewProductId = product.id;
    final String imageUrl = product.mainImage.main.isNotEmpty
        ? product.mainImage.main
        : product.mainImage.thumbnail;
    final String currency = product.pricing.currency.isNotEmpty
        ? product.pricing.currency
        : _getCurrency(context);
    await Storage().recordLocalProductView(<String, dynamic>{
      'productId': product.id,
      'title': product.title,
      'imageUrl': imageUrl,
      'price': product.pricing.currentPrice,
      'currency': currency,
      'rating': product.meta.rating,
      'reviewCount': product.meta.reviewCount,
    });
    if (_lastAnalyticsProductId != product.id) {
      _lastAnalyticsProductId = product.id;
      await AppAnalytics.logViewItem(
        itemId: product.id,
        itemName: product.title,
        currency: currency,
        value: product.pricing.currentPrice,
      );
    }
  }

  void _onProductOverflowMenu(BuildContext context, ProductDetails product) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.compare_arrows),
                title: const Text('Compare'),
                subtitle: const Text('Add to compare (up to 4)'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Storage().addProductCompareId(product.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to compare. Opening compare screen…'),
                    ),
                  );
                  context.push(AppRoutes.productCompare);
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share_outlined),
                title: const Text('Share & link'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await showProductActionsSheet(
                    context,
                    productId: product.id,
                    title: product.title,
                    shareUrl: product.externalUrl.isNotEmpty
                        ? product.externalUrl
                        : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// A degraded catalog record (null pricing) or an explicitly unsellable item
  /// cannot be checked out, so it must never reach the cart.
  static bool _canPurchase(ProductDetails productDetails) {
    if (!productDetails.isSellAllowed) return false;
    return productDetails.pricing.currentPrice > 0 ||
        productDetails.variants
            .any((variant) => (variant.pricing?.currentPrice ?? 0) > 0);
  }

  void _handleAddToCart(
    BuildContext context,
    ProductDetails productDetails, {
    required String fallbackName,
    required String fallbackImageUrl,
  }) {
    if (_isAddingToCart) return;

    if (widget.productId == null || widget.productId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product ID is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_canPurchase(productDetails)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This item is currently unavailable and cannot be added to your cart.',
          ),
          backgroundColor: Colors.orange,
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
    HapticFeedback.lightImpact();
    setState(() {
      _isAddingToCart = true;
    });

    if (!hasVariants) {
      // No variants: add product with default config (no variant selection needed)
      final cartProduct = Product.fromProductDetails(
        productDetails,
        fallbackId: widget.productId,
        fallbackName: fallbackName,
        fallbackImageUrl: fallbackImageUrl,
      );
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
    bool addedAnyVariant = false;
    for (final entry in _selectedVariants.entries) {
      final variantIndex = entry.key;
      final quantity = entry.value;

      if (quantity > 0 && variantIndex < productDetails.variants.length) {
        final variant = productDetails.variants[variantIndex];
        final cartProduct = Product.fromProductDetails(
          productDetails,
          variantIndex: variantIndex,
          fallbackId: widget.productId,
          fallbackName: fallbackName,
          fallbackImageUrl: fallbackImageUrl,
        );

        // A zero-price variant would be dropped again on the next cart read.
        if (cartProduct.price <= 0) continue;

        addedAnyVariant = true;
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

    if (!addedAnyVariant) {
      // Nothing was dispatched, so no CartItemAdded will clear the spinner.
      setState(() {
        _isAddingToCart = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The selected options are currently unavailable. Please choose another option.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
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
            HapticFeedback.mediumImpact();
            final String? pid = widget.productId;
            if (pid != null && pid.isNotEmpty) {
              AppAnalytics.logAddToCart(
                itemId: pid,
                currency: _getCurrency(context),
              );
            }
            setState(() {
              _isInCart = true;
              _isAddingToCart = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item added to cart'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CartError) {
            setState(() {
              _isAddingToCart = false;
            });
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight + 20),
                child: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
                  builder: (BuildContext context, ProductDetailsState pdState) {
                    return AppBarWidget(
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
                    hasNotification: false,
                    additionalActions: pdState is ProductDetailsLoaded
                        ? <Widget>[
                            Semantics(
                              label: 'Product actions',
                              button: true,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                                onPressed: () => _onProductOverflowMenu(
                                  context,
                                  pdState.productDetails,
                                ),
                              ),
                            ),
                          ]
                        : null,
                    );
                  },
                ),
              ),
              body: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
                builder: (context, state) {
                  if (state is ProductDetailsLoading) {
                    return const ProductDetailShimmer();
                  }

                  if (state is ProductDetailsError) {
                    return ProductDetailsErrorView(
                      message: state.message,
                      errorCode: state.errorCode,
                      onRetry: () {
                        context.read<ProductDetailsBloc>().add(
                          ProductDetailsFetchRequested(
                            productId: widget.productId ?? '',
                            country: _getCountry(context),
                            currency: _getCurrency(context),
                          ),
                        );
                      },
                      onGoBack: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _recordLocalViewAndLogAnalytics(product);
                      }
                    });
                    final selectedVariant = product.variants.isNotEmpty
                        ? product.variants[state.selectedVariantIndex]
                        : null;
                    final apiPrice =
                        selectedVariant?.pricing?.formattedCurrentPrice ??
                        product.pricing.formattedCurrentPrice;

                    // The API sometimes returns an almost empty record (null
                    // title/pricing/images). Fall back to the data the card
                    // that opened this screen already displayed.
                    final String displayTitle = product.title.isNotEmpty
                        ? product.title
                        : (widget.productName ?? '');
                    final String currentPrice = apiPrice.isNotEmpty
                        ? apiPrice
                        : (widget.productPrice ?? '');
                    final double displayRating = product.meta.rating > 0
                        ? product.meta.rating
                        : (widget.productRating ?? 0);
                    final int displayReviewCount = product.meta.reviewCount > 0
                        ? product.meta.reviewCount
                        : (widget.productReviewCount ?? 0);
                    final List<ProductImage> galleryImages =
                        product.images.isNotEmpty
                            ? product.images
                            : (product.mainImage.main.isNotEmpty
                                ? [product.mainImage]
                                : (widget.productImage != null &&
                                        widget.productImage!.isNotEmpty
                                    ? [
                                        ProductImage(
                                          thumbnail: widget.productImage!,
                                          main: widget.productImage!,
                                        ),
                                      ]
                                    : []));
                    final String fallbackImageUrl = galleryImages.isEmpty
                        ? ''
                        : (galleryImages.first.main.isNotEmpty
                            ? galleryImages.first.main
                            : galleryImages.first.thumbnail);

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
                              controller: _scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: Spacing.sm),
                                  ProductImageGallery(
                                    images: galleryImages,
                                    isInWishlist: _isInWishlist,
                                    onToggleWishlist: () =>
                                        _toggleWishlist(product),
                                  ),
                                  const SizedBox(height: Spacing.md),
                                  ProductInfoSection(
                                    title: displayTitle,
                                    price: currentPrice,
                                    originalPrice: product
                                            .pricing
                                            .formattedOriginalPrice
                                            .isNotEmpty
                                        ? product.pricing.formattedOriginalPrice
                                        : null,
                                    isOnDiscount: product.pricing.isOnDiscount,
                                    rating: displayRating,
                                    reviewCount: displayReviewCount,
                                    code: product.id,
                                    category: product.categoryId,
                                    keywords: product.brandName,
                                    vendorName: product.vendorName.isNotEmpty
                                        ? product.vendorName
                                        : null,
                                    stockLevel: product.stockLevel,
                                    status: product.status.isNotEmpty
                                        ? product.status
                                        : null,
                                    stuffStatus:
                                        product.stuffStatus.isNotEmpty
                                            ? product.stuffStatus
                                            : null,
                                    createdTime:
                                        product.createdTime.isNotEmpty
                                            ? product.createdTime
                                            : null,
                                    updatedTime:
                                        product.updatedTime.isNotEmpty
                                            ? product.updatedTime
                                            : null,
                                    isSellAllowed: product.isSellAllowed,
                                    variantSelector:
                                        product.variants.isNotEmpty
                                            ? MultiVariantSelectorWidget(
                                                variants: product.variants,
                                                selectedVariants:
                                                    _selectedVariants,
                                                onVariantToggled:
                                                    _handleVariantToggled,
                                                onQuantityChanged:
                                                    _handleQuantityChanged,
                                              )
                                            : null,
                                  ),
                                  Builder(
                                    builder: (BuildContext context) {
                                      final Map<String, String> specs =
                                          _buildSpecifications(product);
                                      if (specs.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Column(
                                        children: <Widget>[
                                          const SizedBox(height: Spacing.md),
                                          ProductSpecifications(
                                            specifications: specs,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: Spacing.md),
                                  ProductDetailActionPills(
                                    onCompanyProfile: () {
                                      showCompanyProfileSheet(
                                        context,
                                        vendorName: product.vendorName,
                                        brandName: product.brandName,
                                        provider: product.provider,
                                      );
                                    },
                                    onCustomerFeedback: () {
                                      if (product.customerReviews.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No customer feedback yet',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      _scrollToReviews();
                                    },
                                  ),
                                  Builder(
                                    builder: (BuildContext context) {
                                      final List<String> paragraphs =
                                          _descriptionParagraphs(product);
                                      if (paragraphs.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          Spacing.md,
                                          Spacing.lg,
                                          Spacing.md,
                                          0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Description',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: Spacing.sm),
                                            ...paragraphs.map(
                                              (String paragraph) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: Spacing.xs,
                                                ),
                                                child: Text(
                                                  paragraph,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color:
                                                            Colors.grey[800],
                                                        height: 1.4,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (product.videos.isNotEmpty) ...[
                                    const SizedBox(height: Spacing.lg),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Spacing.md,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          for (var i = 0;
                                              i < product.videos.length;
                                              i++)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom: i <
                                                        product.videos.length -
                                                            1
                                                    ? Spacing.md
                                                    : 0,
                                              ),
                                              child: SoftFailProductVideo(
                                                url: product.videos[i].url,
                                                autoPlay: i == 0,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: Spacing.lg),
                                  KeyedSubtree(
                                    key: _reviewsKey,
                                    child: product.customerReviews.isNotEmpty
                                        ? ReviewsSectionWidget(
                                            reviews: product.customerReviews,
                                            averageRating: product.meta.rating,
                                            totalReviews:
                                                product.meta.reviewCount,
                                            onViewAllTap: () {
                                              context.push(
                                                '${AppRoutes.productDetailsReviews}?productId=${widget.productId}',
                                              );
                                            },
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(height: Spacing.lg),
                                  YouMayAlsoLikeSection(
                                    productId: product.id.isNotEmpty
                                        ? product.id
                                        : (widget.productId ?? ''),
                                    productTitle: displayTitle,
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
                            final int displayQuantity =
                                totalQuantity > 0 ? totalQuantity : _quantity;
                            final String resolvedCurrency =
                                selectedVariant?.pricing?.currency.isNotEmpty ==
                                        true
                                    ? selectedVariant!.pricing!.currency
                                    : (product.pricing.currency.isNotEmpty
                                        ? product.pricing.currency
                                        : _getCurrency(context));
                            final double resolvedUnitPrice =
                                selectedVariant?.pricing?.currentPrice ??
                                    product.pricing.currentPrice;

                            return AddToCartSection(
                              isInCart: itemInCart && !hasSelectedVariants,
                              isInWishlist: _isInWishlist,
                              isAddingToCart: _isAddingToCart,
                              canAddToCart: _canPurchase(product),
                              quantity: displayQuantity,
                              unitPrice: hasSelectedVariants
                                  ? MoneyFormatter.format(
                                      totalPrice,
                                      resolvedCurrency,
                                    )
                                  : currentPrice,
                              total: hasSelectedVariants
                                  ? MoneyFormatter.format(
                                      totalPrice,
                                      resolvedCurrency,
                                    )
                                  : (resolvedUnitPrice > 0
                                      ? MoneyFormatter.format(
                                          resolvedUnitPrice * displayQuantity,
                                          resolvedCurrency,
                                        )
                                      : null),
                              onAddToCart: () {
                                _handleAddToCart(
                                  context,
                                  product,
                                  fallbackName: displayTitle,
                                  fallbackImageUrl: fallbackImageUrl,
                                );
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
                              onToggleFavorite: () => _toggleWishlist(product),
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
