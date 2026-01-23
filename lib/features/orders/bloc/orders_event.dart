part of 'orders_bloc.dart';

@immutable
sealed class OrdersEvent {}

final class OrdersLoadRequested extends OrdersEvent {
  final int? customerId;
  final String? stageCategory;
  final String? searchQuery;
  final String? dateFrom;
  final String? dateTo;
  final int? page;
  final int? size;
  final String? sort;
  final String? direction;

  OrdersLoadRequested({
    this.customerId,
    this.stageCategory,
    this.searchQuery,
    this.dateFrom,
    this.dateTo,
    this.page,
    this.size,
    this.sort,
    this.direction,
  });
}

final class OrdersRefreshRequested extends OrdersEvent {
  final int? customerId;
  final String? stageCategory;
  final String? searchQuery;
  final String? dateFrom;
  final String? dateTo;
  final int? page;
  final int? size;
  final String? sort;
  final String? direction;

  OrdersRefreshRequested({
    this.customerId,
    this.stageCategory,
    this.searchQuery,
    this.dateFrom,
    this.dateTo,
    this.page,
    this.size,
    this.sort,
    this.direction,
  });
}
