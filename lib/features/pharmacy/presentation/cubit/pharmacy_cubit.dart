import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import 'pharmacy_state.dart';

class PharmacyCubit extends Cubit<PharmacyState> {
  final PharmacyRepository repository;

  PharmacyCubit({required this.repository}) : super(PharmacyInitial());

  String? _currentBranchId;
  String? get currentBranchId => _currentBranchId;

  void setBranchId(String? branchId) {
    _currentBranchId = branchId;
  }

  Future<void> changeBranch(String branchId) async {
    _currentBranchId = branchId;
    await refresh();
  }

  Future<void> loadInitialData({String? branchId}) async {
    if (branchId != null) _currentBranchId = branchId;
    emit(PharmacyLoading());

    try {
      final results = await Future.wait([
        repository.getCategories(),
        repository.getProducts(
          page: 1,
          pageSize: 20,
          branchId: _currentBranchId,
        ),
      ]);

      if (isClosed) return;
      final categories = results[0] as List<CategoryModel>;
      final productsData = results[1] as Map<String, dynamic>;

      final products = productsData['products'] as List<ProductModel>;
      final totalCount = productsData['total'] as int;
      final totalPages = productsData['pages'] as int;

      emit(PharmacyLoaded(
        categories: categories,
        products: products,
        totalCount: totalCount,
        totalPages: totalPages,
        currentPage: 1,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(PharmacyError('Failed to load pharmacy catalog. Please try again.'));
    }
  }

  Future<void> selectCategory(String? categoryId) async {
    final currentState = state;
    if (currentState is! PharmacyLoaded) return;

    final targetCategoryId =
        currentState.selectedCategoryId == categoryId ? null : categoryId;

    emit(currentState.copyWith(
      selectedCategoryId: targetCategoryId,
      clearCategory: targetCategoryId == null,
      isFiltering: true,
      currentPage: 1,
    ));

    try {
      final result = await repository.getProducts(
        page: 1,
        pageSize: 20,
        categoryId: targetCategoryId,
        search: currentState.searchQuery.isEmpty ? null : currentState.searchQuery,
        branchId: _currentBranchId,
      );

      final products = result['products'] as List<ProductModel>;
      final totalCount = result['total'] as int;
      final totalPages = result['pages'] as int;

      emit(currentState.copyWith(
        products: products,
        selectedCategoryId: targetCategoryId,
        clearCategory: targetCategoryId == null,
        totalCount: totalCount,
        totalPages: totalPages,
        currentPage: 1,
        isFiltering: false,
      ));
    } catch (_) {
      emit(currentState.copyWith(isFiltering: false));
    }
  }

  Future<void> search(String query) async {
    final currentState = state;
    if (currentState is! PharmacyLoaded) return;

    emit(currentState.copyWith(
      searchQuery: query,
      isFiltering: true,
      currentPage: 1,
    ));

    try {
      final result = await repository.getProducts(
        page: 1,
        pageSize: 20,
        categoryId: currentState.selectedCategoryId,
        search: query.trim().isEmpty ? null : query.trim(),
        branchId: _currentBranchId,
      );

      final products = result['products'] as List<ProductModel>;
      final totalCount = result['total'] as int;
      final totalPages = result['pages'] as int;

      emit(currentState.copyWith(
        products: products,
        searchQuery: query,
        totalCount: totalCount,
        totalPages: totalPages,
        currentPage: 1,
        isFiltering: false,
      ));
    } catch (_) {
      emit(currentState.copyWith(isFiltering: false));
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is PharmacyLoaded) {
      await loadInitialData(branchId: _currentBranchId);
    } else {
      await loadInitialData(branchId: _currentBranchId);
    }
  }
}
