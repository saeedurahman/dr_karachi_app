import '../../../home/data/models/lab_test_model.dart';

abstract class LabState {}

class LabInitial extends LabState {}

class LabLoading extends LabState {}

class LabLoaded extends LabState {
  final List<LabTestModel> tests;
  final List<String> categories;
  final String selectedCategory; // 'All' or a specific category
  final String searchQuery;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isFiltering;
  final String? error;

  LabLoaded({
    required this.tests,
    this.categories = const ['All'],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.page = 1,
    this.limit = 20,
    required this.total,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isFiltering = false,
    this.error,
  });

  // Backward compatibility getters
  List<LabTestModel> get allTests => tests;
  List<LabTestModel> get filteredTests => tests;

  LabLoaded copyWith({
    List<LabTestModel>? tests,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    int? page,
    int? limit,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFiltering,
    String? error,
  }) {
    return LabLoaded(
      tests: tests ?? this.tests,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFiltering: isFiltering ?? this.isFiltering,
      error: error,
    );
  }
}

class LabError extends LabState {
  final String message;
  LabError(this.message);
}
