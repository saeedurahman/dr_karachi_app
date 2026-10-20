import '../../../home/data/models/lab_test_model.dart';

class LabTestsPageResponse {
  final List<LabTestModel> items;
  final int total;
  final int page;
  final int limit;
  final int pages;
  final List<String> categories;

  LabTestsPageResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.categories,
  });

  factory LabTestsPageResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => LabTestModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawCats = json['categories'] as List<dynamic>? ?? [];
    final categories = rawCats.map((e) => e.toString()).toList();

    return LabTestsPageResponse(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? items.length,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
      categories: categories,
    );
  }
}
