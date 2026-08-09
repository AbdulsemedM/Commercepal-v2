import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/widgets/app_empty_state.dart';
import 'package:commercepal/core/widgets/shimmer_loading.dart';
import 'package:commercepal/features/home/presentation/widgets/home_product_rows.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/bloc/visual_search_bloc.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/services/camera_service.dart';
import 'package:commercepal/services/localization_service.dart';

class VisualSearchScreen extends StatefulWidget {
  const VisualSearchScreen({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  State<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends State<VisualSearchScreen> {
  static const double _loadMoreScrollThreshold = 200;

  final CameraService _cameraService = CameraService();
  final TextEditingController _urlController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final String? initialUrl = widget.initialUrl?.trim();
    if (initialUrl != null && initialUrl.isNotEmpty) {
      _urlController.text = initialUrl;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VisualSearchBloc>().add(
              VisualSearchByUrlRequested(initialUrl),
            );
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double current = _scrollController.position.pixels;
    if (maxScroll - current <= _loadMoreScrollThreshold) {
      context.read<VisualSearchBloc>().add(VisualSearchLoadMoreRequested());
    }
  }

  Future<void> _pickImage(ImageSourceAction source) async {
    final String? base64 = source == ImageSourceAction.camera
        ? await _cameraService.pickFromCameraBase64()
        : await _cameraService.pickFromGalleryBase64();
    if (!mounted || base64 == null) return;
    context.read<VisualSearchBloc>().add(VisualSearchByImageRequested(base64));
  }

  void _searchByUrl() {
    final String url = _urlController.text.trim();
    if (url.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<VisualSearchBloc>().add(VisualSearchByUrlRequested(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(LocalizationService.t(context, 'visualSearch.title')),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          _buildUploadSection(context),
          Expanded(
            child: BlocBuilder<VisualSearchBloc, VisualSearchState>(
              builder: (BuildContext context, VisualSearchState state) {
                if (state is VisualSearchInitial) {
                  return _buildIdleState(context);
                }
                if (state is VisualSearchLoading) {
                  return _buildLoadingGrid();
                }
                if (state is VisualSearchError) {
                  final String message = state.localizationKey != null
                      ? LocalizationService.t(context, state.localizationKey!)
                      : state.message;
                  return AppEmptyState(
                    icon: Icons.search_off_outlined,
                    title: message,
                    primaryLabel: LocalizationService.t(
                      context,
                      'visualSearch.retry',
                    ),
                    onPrimary: () {
                      context.read<VisualSearchBloc>().add(VisualSearchReset());
                    },
                  );
                }
                if (state is VisualSearchLoaded) {
                  return _buildResults(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSourceAction.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    LocalizationService.t(context, 'visualSearch.takePhoto'),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSourceAction.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    LocalizationService.t(context, 'visualSearch.fromGallery'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            LocalizationService.t(context, 'visualSearch.or'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: LocalizationService.t(
                      context,
                      'visualSearch.urlHint',
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchByUrl(),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              IconButton.filled(
                onPressed: _searchByUrl,
                icon: const Icon(Icons.link),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.navy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Text(
          LocalizationService.t(context, 'visualSearch.idleHint'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: Spacing.sm),
              Text(LocalizationService.t(context, 'visualSearch.analyzing')),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(Spacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Spacing.md,
              mainAxisSpacing: Spacing.md,
              childAspectRatio: 0.52,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => const ProductCardShimmer(),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, VisualSearchLoaded state) {
    if (state.products.isEmpty) {
      return AppEmptyState(
        icon: Icons.image_search_outlined,
        title: LocalizationService.t(context, 'visualSearch.noResults'),
        subtitle: LocalizationService.t(context, 'visualSearch.noResultsHint'),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              0,
              Spacing.md,
              Spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (state.previewImageBase64 != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(state.previewImageBase64!),
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (state.message != null && state.message!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.sm),
                  Text(
                    state.message!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(Spacing.md),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Spacing.md,
              mainAxisSpacing: Spacing.md,
              childAspectRatio: 0.52,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final Product product = state.products[index];
                return ProductCard(
                  productId: product.id,
                  imageUrl: product.imageUrl ?? '',
                  description: product.name,
                  price: formatHomeProductPrice(product),
                  product: product,
                  currency: product.currency,
                  fillCell: true,
                );
              },
              childCount: state.products.length,
            ),
          ),
        ),
        if (state.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
      ],
    );
  }
}

enum ImageSourceAction { camera, gallery }
