import '../../../home/data/models/product_model.dart';
import '../../data/models/category_model.dart';

abstract class PharmacyState {}

class PharmacyInitial extends PharmacyState {}

class PharmacyLoading extends PharmacyState {}

class PharmacyLoaded extends PharmacyState {
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final String? selectedCategoryId;
  final String searchQuery;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool isFiltering;

  PharmacyLoaded({
    required this.categories,
    required this.products,
    this.selectedCategoryId,
    this.searchQuery = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.isFiltering = false,
  });

  PharmacyLoaded copyWith({
    List<CategoryModel>? categories,
    List<ProductModel>? products,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? isFiltering,
  }) {
    return PharmacyLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      isFiltering: isFiltering ?? this.isFiltering,
    );
  }
}

class PharmacyError extends PharmacyState {
  final String message;
  PharmacyError(this.message);
}
