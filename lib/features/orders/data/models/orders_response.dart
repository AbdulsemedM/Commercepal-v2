import 'order.dart';

class SortInfo {
  final bool empty;
  final bool unsorted;
  final bool sorted;

  SortInfo({
    required this.empty,
    required this.unsorted,
    required this.sorted,
  });

  factory SortInfo.fromJson(Map<String, dynamic> json) => SortInfo(
        empty: json['empty'] as bool? ?? true,
        unsorted: json['unsorted'] as bool? ?? true,
        sorted: json['sorted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'empty': empty,
        'unsorted': unsorted,
        'sorted': sorted,
      };
}

class Pageable {
  final int offset;
  final SortInfo sort;
  final bool unpaged;
  final int pageSize;
  final bool paged;
  final int pageNumber;

  Pageable({
    required this.offset,
    required this.sort,
    required this.unpaged,
    required this.pageSize,
    required this.paged,
    required this.pageNumber,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) => Pageable(
        offset: json['offset'] as int? ?? 0,
        sort: SortInfo.fromJson(
          json['sort'] as Map<String, dynamic>? ?? {},
        ),
        unpaged: json['unpaged'] as bool? ?? false,
        pageSize: json['pageSize'] as int? ?? 0,
        paged: json['paged'] as bool? ?? true,
        pageNumber: json['pageNumber'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'offset': offset,
        'sort': sort.toJson(),
        'unpaged': unpaged,
        'pageSize': pageSize,
        'paged': paged,
        'pageNumber': pageNumber,
      };
}

class OrdersResponse {
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
  final int size;
  final List<Order> content;
  final int number;
  final SortInfo sort;
  final int numberOfElements;
  final Pageable pageable;
  final bool empty;

  OrdersResponse({
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.last,
    required this.size,
    required this.content,
    required this.number,
    required this.sort,
    required this.numberOfElements,
    required this.pageable,
    required this.empty,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final contentJson = json['content'] as List<dynamic>? ?? [];
    final content = contentJson
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrdersResponse(
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      size: json['size'] as int? ?? 0,
      content: content,
      number: json['number'] as int? ?? 0,
      sort: SortInfo.fromJson(
        json['sort'] as Map<String, dynamic>? ?? {},
      ),
      numberOfElements: json['numberOfElements'] as int? ?? 0,
      pageable: Pageable.fromJson(
        json['pageable'] as Map<String, dynamic>? ?? {},
      ),
      empty: json['empty'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalPages': totalPages,
        'totalElements': totalElements,
        'first': first,
        'last': last,
        'size': size,
        'content': content.map((order) => order.toJson()).toList(),
        'number': number,
        'sort': sort.toJson(),
        'numberOfElements': numberOfElements,
        'pageable': pageable.toJson(),
        'empty': empty,
      };
}
