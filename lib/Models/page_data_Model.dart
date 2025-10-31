// lib/Models/paged_data.dart
class SortInfo {
  final bool empty;
  final bool sorted;
  final bool unsorted;

  SortInfo({required this.empty, required this.sorted, required this.unsorted});

  factory SortInfo.fromJson(Map<String, dynamic> json) {
    return SortInfo(
      empty: json['empty'] == true,
      sorted: json['sorted'] == true,
      unsorted: json['unsorted'] == true,
    );
  }
}

class PageableInfo {
  final int pageNumber;
  final int pageSize;
  final SortInfo sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  PageableInfo({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory PageableInfo.fromJson(Map<String, dynamic> json) {
    return PageableInfo(
      pageNumber: (json['pageNumber'] is int) ? json['pageNumber'] as int : int.tryParse('${json['pageNumber']}') ?? 0,
      pageSize: (json['pageSize'] is int) ? json['pageSize'] as int : int.tryParse('${json['pageSize']}') ?? 0,
      sort: json['sort'] is Map<String, dynamic> ? SortInfo.fromJson(json['sort'] as Map<String, dynamic>) : SortInfo(empty: true, sorted: false, unsorted: true),
      offset: (json['offset'] is int) ? json['offset'] as int : int.tryParse('${json['offset']}') ?? 0,
      paged: json['paged'] == true,
      unpaged: json['unpaged'] == true,
    );
  }
}

class PagedData<T> {
  final List<T> content;
  final PageableInfo pageable;
  final bool last;
  final int totalPages;
  final int totalElements;
  final bool first;
  final int size;
  final int number;
  final int numberOfElements;
  final SortInfo sort;
  final bool empty;

  PagedData({
    required this.content,
    required this.pageable,
    required this.last,
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.size,
    required this.number,
    required this.numberOfElements,
    required this.sort,
    required this.empty,
  });

  factory PagedData.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) itemFromJson,
      ) {
    final rawContent = json['content'];
    final List<T> items = <T>[];
    if (rawContent is List) {
      for (final e in rawContent) {
        try {
          items.add(itemFromJson(e));
        } catch (e) {
          // skip malformed items but continue
          print('PagedData.fromJson: failed to parse item -> $e');
        }
      }
    }

    final pageable = json['pageable'] is Map<String, dynamic>
        ? PageableInfo.fromJson(json['pageable'] as Map<String, dynamic>)
        : PageableInfo(
        pageNumber: (json['number'] is int) ? json['number'] as int : int.tryParse('${json['number']}') ?? 0,
        pageSize: (json['size'] is int) ? json['size'] as int : int.tryParse('${json['size']}') ?? 0,
        sort: SortInfo(empty: true, sorted: false, unsorted: true),
        offset: 0,
        paged: true,
        unpaged: false);

    return PagedData<T>(
      content: items,
      pageable: pageable,
      last: json['last'] == true,
      totalPages: (json['totalPages'] is int) ? json['totalPages'] as int : int.tryParse('${json['totalPages']}') ?? 0,
      totalElements: (json['totalElements'] is int) ? json['totalElements'] as int : int.tryParse('${json['totalElements']}') ?? 0,
      first: json['first'] == true,
      size: (json['size'] is int) ? json['size'] as int : int.tryParse('${json['size']}') ?? 0,
      number: (json['number'] is int) ? json['number'] as int : int.tryParse('${json['number']}') ?? 0,
      numberOfElements: (json['numberOfElements'] is int) ? json['numberOfElements'] as int : int.tryParse('${json['numberOfElements']}') ?? 0,
      sort: json['sort'] is Map<String, dynamic> ? SortInfo.fromJson(json['sort'] as Map<String, dynamic>) : SortInfo(empty: true, sorted: false, unsorted: true),
      empty: json['empty'] == true,
    );
  }
}
