import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/orders/bloc/orders_bloc.dart';
import 'package:commercepal/features/orders/data/models/order.dart';
import 'package:commercepal/features/orders/data/repository/orders_repository.dart';
import 'package:commercepal/features/orders/presentation/widgets/order_item_thumbnail.dart';
import 'package:commercepal/features/orders/presentation/widgets/order_status_badge.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedTabIndex = 0;

  static const List<String> _tabKeys = [
    'orderHistory.all',
    'orderHistory.delivered',
    'orderHistory.ongoing',
    'orderHistory.pendingPayment',
    'orderHistory.cancelled',
  ];

  /// Max thumbnails shown per order card before collapsing into "+N".
  static const int _maxThumbnails = 4;

  String? _getStageCategoryForTab(int index) {
    switch (index) {
      case 0:
        return null; // All
      case 1:
        return 'DELIVERED';
      case 2:
        return 'ONGOING';
      case 3:
        return 'PENDING_PAYMENT';
      case 4:
        return 'CANCELLED';
      default:
        return null;
    }
  }

  /// Returns true if [order] belongs to the given tab [stageCategory].
  /// [stageCategory] null means "All". Matches order.stageCategory and order.currentStage.
  bool _orderMatchesTab(Order order, String? stageCategory) {
    if (stageCategory == null || stageCategory.isEmpty) return true;
    final cat = stageCategory.toUpperCase();
    final orderCat = order.stageCategory.toUpperCase();
    final orderStage = order.currentStage.toUpperCase();

    if (orderCat == cat) return true;
    if (orderStage == cat) return true;

    // Aliases for common API variations
    switch (cat) {
      case 'DELIVERED':
        return orderCat.contains('DELIVERED') || orderStage.contains('DELIVERED');
      case 'ONGOING':
        return orderCat.contains('ONGOING') ||
            orderStage.contains('ONGOING') ||
            orderCat.contains('SHIPPED') ||
            orderStage.contains('SHIPPED') ||
            orderCat.contains('CONFIRMED') ||
            orderStage.contains('CONFIRMED') ||
            orderCat.contains('PROCESSING') ||
            orderStage.contains('PROCESSING');
      case 'PENDING_PAYMENT':
        return orderCat.contains('PENDING') && orderCat.contains('PAYMENT') ||
            orderStage.contains('PENDING') && orderStage.contains('PAYMENT') ||
            orderCat.contains('WAITING') ||
            orderStage.contains('WAITING') ||
            orderCat == 'PENDING_PAYMENT' ||
            orderStage == 'PENDING_PAYMENT';
      case 'CANCELLED':
        return orderCat.contains('CANCEL') || orderStage.contains('CANCEL');
      default:
        return orderCat == cat || orderStage == cat;
    }
  }

  final OrdersRepository _ordersRepository = OrdersRepository();

  @override
  void initState() {
    super.initState();
    // Load orders when screen initializes - use postFrameCallback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // print('🔵 OrderHistoryScreen: Dispatching OrdersLoadRequested event');
        try {
          final bloc = context.read<OrdersBloc>();
          // print('🔵 OrderHistoryScreen: BLoC found, adding event');
          bloc.add(OrdersLoadRequested());
        } catch (e) {
          // print('❌ OrderHistoryScreen: Error accessing BLoC: $e');
        }
      }
    });
  }

  /// Opens payment method selection to pay for an order (Waiting for Payment).
  Future<void> _openPayForOrder(BuildContext context, Order order) async {
    if (!context.mounted) return;
    context.push<void>(
      AppRoutes.retryPaymentMethod,
      extra: <String, dynamic>{
        'orderNumber': order.orderNumber,
        'currency': order.currency,
        'orderTotal': order.totalAmount,
        'paymentReference': order.paymentReference,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: context.tr('common.goBack'),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: Semantics(
          header: true,
          child: Text(context.tr('orderHistory.title')),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildFilterChips(context),
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return _buildLoading();
          }

          if (state is OrdersError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              isError: true,
              title: context.tr('common.somethingWentWrong'),
              subtitle: state.message,
              primaryLabel: context.tr('orderHistory.retry'),
              onPrimary: () {
                context.read<OrdersBloc>().add(OrdersLoadRequested());
              },
            );
          }

          if (state is OrdersLoaded) {
            final category = _getStageCategoryForTab(_selectedTabIndex);
            final filtered = state.response.content
                .where((Order o) => _orderMatchesTab(o, category))
                .toList();
            return _buildOrderList(filtered);
          }

          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: Spacing.gutter,
          vertical: Spacing.xs,
        ),
        itemCount: _tabKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = _selectedTabIndex == index;
          return ChoiceChip(
            label: Text(context.tr(_tabKeys[index])),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _selectedTabIndex = index;
              });
              // Filtering is done client-side from the already-loaded list; no need to reload.
            },
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Spacing.gutter),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
      itemBuilder: (_, __) => const Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.xs),
          child: ListTileShimmer(leadingSize: 64),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return AppEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: context.tr('orderHistory.noOrdersFound'),
        subtitle: context.tr('orders.history.emptySubtitle'),
        primaryLabel: context.tr('cart.startShopping'),
        onPrimary: () => context.go(AppRoutes.dashboard),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersBloc>().add(
          OrdersRefreshRequested(),
        );
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Spacing.gutter),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    // Get first item for display
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final productName = firstItem?.productName ?? context.tr('orderHistory.multipleItems');

    // Format date
    String formattedDate = '';
    try {
      final dateTime = DateTime.parse(order.orderDate);
      formattedDate = formatOrderDate(context, dateTime, 'dd MMM yyyy');
    } catch (e) {
      formattedDate = order.orderDate;
    }

    // Determine status from stageCategory or currentStage
    final status = order.stageCategory.isNotEmpty
        ? order.stageCategory.toLowerCase()
        : order.currentStage.toLowerCase();

    void goToOrderDetails() {
      // Delivered orders too: the tracking screen shows the full order.
      context.pushNamed(
        'orderTracking',
        queryParameters: {
          'id': order.orderNumber,
          'status': status,
        },
        extra: order,
      );
    }

    final String statusLabel = order.stageLabel.isNotEmpty
        ? order.stageLabel
        : _getStatusLabel(context, status);
    final String statusKey = OrderStatusBadge.pickStatus(
      <String>[order.currentStage, order.stageCategory],
    );
    final int itemCount = order.items.length;
    final int hiddenCount = itemCount > _maxThumbnails
        ? itemCount - (_maxThumbnails - 1)
        : 0;
    final int shownThumbs =
        hiddenCount > 0 ? _maxThumbnails - 1 : itemCount;

    return Card(
      child: InkWell(
        onTap: goToOrderDetails,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header: order number (copyable) + status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                '${context.tr('orderHistory.orderNumber')}${order.orderNumber}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: scheme.onSurface,
                                  fontFeatures: AppTypography.tabularFigures,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (order.orderNumber.isNotEmpty)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                iconSize: AppSizes.iconSm,
                                tooltip: context.tr('checkout.copyOrderNumber'),
                                icon: Icon(
                                  Icons.copy_rounded,
                                  color: scheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: order.orderNumber),
                                  );
                                  AppSnackbars.success(
                                    context,
                                    context.tr('checkout.orderNumberCopied'),
                                  );
                                },
                              ),
                          ],
                        ),
                        if (formattedDate.isNotEmpty)
                          Text(
                            context.tr('orders.history.placedOn', {
                              'date': formattedDate,
                            }),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: Spacing.xs),
                    child: OrderStatusBadge(
                      status: statusKey,
                      label: statusLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Divider(height: 1, color: context.commerce.border),
              const SizedBox(height: Spacing.sm),
              // Item thumbnails
              Row(
                children: <Widget>[
                  if (itemCount == 0)
                    const OrderItemThumbnail(url: '', size: 56)
                  else
                    for (int i = 0; i < shownThumbs; i++)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: Spacing.xs,
                        ),
                        child: OrderItemThumbnail(
                          url: order.items[i].productImageUrl,
                          size: 56,
                          semanticLabel: order.items[i].productName,
                        ),
                      ),
                  if (hiddenCount > 0)
                    Semantics(
                      label: context.tr('orders.history.moreItems', {
                        'count': hiddenCount,
                      }),
                      excludeSemantics: true,
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: AppRadius.smAll,
                          border: Border.all(color: context.commerce.border),
                        ),
                        child: Text(
                          '+$hiddenCount',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              // Product name
              Text(
                order.items.length > 1
                    ? context.tr('orders.history.itemsMore', {
                        'name': productName,
                        'count': order.items.length - 1,
                      })
                    : productName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.sm),
              // Total
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    context.tr('checkout.total'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: PriceTag(
                      amount: order.totalAmount,
                      currency: CountryCurrencyConstants.getCurrencySymbol(
                        order.currency,
                      ),
                      size: PriceTagSize.small,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              // Actions: Pay and Track (from API actions.canPay / actions.canTrack)
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (order.canPay)
                    AppButton.primary(
                      label: context.tr('orderHistory.pay'),
                      size: AppButtonSize.small,
                      fullWidth: false,
                      icon: Icons.payment_rounded,
                      onPressed: () => _openPayForOrder(context, order),
                    ),
                  if (order.canTrack)
                    AppButton.secondary(
                      label: context.tr('orderHistory.track'),
                      size: AppButtonSize.small,
                      fullWidth: false,
                      icon: Icons.local_shipping_outlined,
                      onPressed: () {
                        // Prevent card tap when pressing Track
                        context.pushNamed(
                          'orderTracking',
                          queryParameters: {
                            'id': order.orderNumber,
                            'status': status,
                          },
                          extra: order,
                        );
                      },
                    ),
                  AppButton.text(
                    label: context.tr('orders.history.viewDetails'),
                    size: AppButtonSize.small,
                    trailingIcon: Icons.chevron_right_rounded,
                    onPressed: goToOrderDetails,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return context.tr('orderHistory.delivered');
      case 'shipped':
      case 'ongoing':
        return context.tr('orderHistory.ongoing');
      case 'pending':
      case 'pending_confirmation':
      case 'pending_payment':
        return context.tr('orderHistory.pendingPayment');
      case 'cancelled':
      case 'canceled':
        return context.tr('orderHistory.cancelled');
      case 'confirmed':
      case 'waiting':
        return context.tr('orderHistory.waiting');
      default:
        return context.tr('orderHistory.pending');
    }
  }
}
