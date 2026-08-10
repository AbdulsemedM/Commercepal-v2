import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/widgets/app_empty_state.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
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
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CheckoutScreenHeader(
              title: LocalizationService.t(context, 'visualSearch.title'),
            ),
            Expanded(
              child: BlocBuilder<VisualSearchBloc, VisualSearchState>(
                builder: (BuildContext context, VisualSearchState state) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: _buildSearchPanel(context, scheme),
                      ),
                      ..._buildStateSlivers(context, state, scheme),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: Spacing.xxl),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStateSlivers(
    BuildContext context,
    VisualSearchState state,
    ColorScheme scheme,
  ) {
    if (state is VisualSearchInitial) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildIdleState(context, scheme),
        ),
      ];
    }

    if (state is VisualSearchLoading) {
      return <Widget>[
        SliverToBoxAdapter(child: _buildAnalyzingBanner(context, scheme)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            0,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Spacing.md,
              mainAxisSpacing: Spacing.md,
              childAspectRatio: 0.52,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, __) => const ProductCardShimmer(),
              childCount: 6,
            ),
          ),
        ),
      ];
    }

    if (state is VisualSearchError) {
      final String message = state.localizationKey != null
          ? LocalizationService.t(context, state.localizationKey!)
          : state.message;
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: Icons.search_off_outlined,
            title: message,
            primaryLabel: LocalizationService.t(context, 'visualSearch.retry'),
            onPrimary: () {
              context.read<VisualSearchBloc>().add(VisualSearchReset());
            },
          ),
        ),
      ];
    }

    if (state is VisualSearchLoaded) {
      return _buildResultsSlivers(context, state, scheme);
    }

    return const <Widget>[];
  }

  Widget _buildSearchPanel(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.md,
      ),
      child: Container(
        decoration: AppDecorations.elevatedCard(
          background: scheme.surface,
        ),
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              LocalizationService.t(context, 'visualSearch.subtitle'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SourceActionCard(
                    icon: Icons.camera_alt_rounded,
                    label: LocalizationService.t(
                      context,
                      'visualSearch.takePhoto',
                    ),
                    onTap: () => _pickImage(ImageSourceAction.camera),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _SourceActionCard(
                    icon: Icons.photo_library_rounded,
                    label: LocalizationService.t(
                      context,
                      'visualSearch.fromGallery',
                    ),
                    onTap: () => _pickImage(ImageSourceAction.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: <Widget>[
                Expanded(child: Divider(color: scheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                  child: Text(
                    LocalizationService.t(context, 'visualSearch.or'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                  ),
                ),
                Expanded(child: Divider(color: scheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: LocalizationService.t(
                  context,
                  'visualSearch.urlHint',
                ),
                prefixIcon: Icon(
                  Icons.link_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: AppColors.cream.withValues(alpha: 0.65),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: Spacing.xs),
                  child: IconButton(
                    onPressed: _searchByUrl,
                    tooltip: LocalizationService.t(
                      context,
                      'visualSearch.searchLink',
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  ),
                ),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchByUrl(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF0E6D8)),
            ),
            child: const Icon(
              Icons.image_search_rounded,
              size: 40,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            LocalizationService.t(context, 'visualSearch.idleTitle'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            LocalizationService.t(context, 'visualSearch.idleHint'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingBanner(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                LocalizationService.t(context, 'visualSearch.analyzing'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultsSlivers(
    BuildContext context,
    VisualSearchLoaded state,
    ColorScheme scheme,
  ) {
    if (state.products.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: Icons.image_search_outlined,
            title: LocalizationService.t(context, 'visualSearch.noResults'),
            subtitle: LocalizationService.t(
              context,
              'visualSearch.noResultsHint',
            ),
          ),
        ),
      ];
    }

    return <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            0,
            Spacing.md,
            Spacing.sm,
          ),
          child: Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: AppDecorations.elevatedCard(
              background: scheme.surface,
            ),
            child: Row(
              children: <Widget>[
                if (state.previewImageBase64 != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(state.previewImageBase64!),
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        state.message != null && state.message!.isNotEmpty
                            ? state.message!
                            : LocalizationService.t(
                                context,
                                'visualSearch.resultsTitle',
                              ),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        LocalizationService.t(context, 'visualSearch.resultsCount')
                            .replaceAll('{count}', '${state.products.length}'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    ];
  }
}

class _SourceActionCard extends StatelessWidget {
  const _SourceActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.md + 2,
            horizontal: Spacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
            border: Border.all(color: const Color(0xFFF0E6D8)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ImageSourceAction { camera, gallery }
