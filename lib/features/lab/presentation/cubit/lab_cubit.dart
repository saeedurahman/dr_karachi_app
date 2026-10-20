import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/lab_repository.dart';
import 'lab_state.dart';

class LabCubit extends Cubit<LabState> {
  final LabRepository repository;

  LabCubit({required this.repository}) : super(LabInitial());

  String? _currentBranchId;
  static const int _pageSize = 20;

  Future<void> loadLabTests({String? branchId}) async {
    if (branchId != null) _currentBranchId = branchId;
    emit(LabLoading());

    try {
      // Fetch initial page 1
      final res = await repository.getLabTests(
        page: 1,
        limit: _pageSize,
        branchId: _currentBranchId,
      );

      // Merge categories from response and categories endpoint if needed
      List<String> categories = ['All'];
      if (res.categories.isNotEmpty) {
        for (final c in res.categories) {
          if (!categories.contains(c)) categories.add(c);
        }
      } else {
        try {
          final fetchedCats = await repository.getCategories();
          for (final c in fetchedCats) {
            if (!categories.contains(c)) categories.add(c);
          }
        } catch (_) {}
      }

      if (isClosed) return;

      emit(LabLoaded(
        tests: res.items,
        categories: categories,
        selectedCategory: 'All',
        searchQuery: '',
        page: res.page,
        limit: _pageSize,
        total: res.total,
        hasMore: res.page < res.pages,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(LabError('Failed to load diagnostic lab tests. Please check connection and try again.'));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! LabLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore || currentState.isFiltering) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;
      final res = await repository.getLabTests(
        page: nextPage,
        limit: currentState.limit,
        search: currentState.searchQuery,
        category: currentState.selectedCategory == 'All' ? null : currentState.selectedCategory,
        branchId: _currentBranchId,
      );

      if (isClosed) return;

      // Deduplicate items by ID
      final existingIds = currentState.tests.map((t) => t.id).toSet();
      final newItems = res.items.where((t) => !existingIds.contains(t.id)).toList();

      emit(currentState.copyWith(
        tests: [...currentState.tests, ...newItems],
        page: nextPage,
        total: res.total,
        hasMore: nextPage < res.pages,
        isLoadingMore: false,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> selectCategory(String category) async {
    final currentState = state;
    if (currentState is! LabLoaded) return;
    if (currentState.selectedCategory == category && !currentState.isFiltering) return;

    emit(currentState.copyWith(selectedCategory: category, isFiltering: true));

    try {
      final res = await repository.getLabTests(
        page: 1,
        limit: _pageSize,
        search: currentState.searchQuery,
        category: category == 'All' ? null : category,
        branchId: _currentBranchId,
      );

      if (isClosed) return;

      emit(currentState.copyWith(
        tests: res.items,
        selectedCategory: category,
        page: 1,
        total: res.total,
        hasMore: 1 < res.pages,
        isFiltering: false,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(currentState.copyWith(isFiltering: false));
    }
  }

  Future<void> search(String query) async {
    final currentState = state;
    if (currentState is! LabLoaded) return;

    emit(currentState.copyWith(searchQuery: query, isFiltering: true));

    try {
      final res = await repository.getLabTests(
        page: 1,
        limit: _pageSize,
        search: query.trim().isEmpty ? null : query.trim(),
        category: currentState.selectedCategory == 'All' ? null : currentState.selectedCategory,
        branchId: _currentBranchId,
      );

      if (isClosed) return;

      emit(currentState.copyWith(
        tests: res.items,
        searchQuery: query,
        page: 1,
        total: res.total,
        hasMore: 1 < res.pages,
        isFiltering: false,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(currentState.copyWith(isFiltering: false));
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is LabLoaded) {
      try {
        final res = await repository.getLabTests(
          page: 1,
          limit: _pageSize,
          search: currentState.searchQuery,
          category: currentState.selectedCategory == 'All' ? null : currentState.selectedCategory,
          branchId: _currentBranchId,
        );

        if (isClosed) return;

        emit(currentState.copyWith(
          tests: res.items,
          page: 1,
          total: res.total,
          hasMore: 1 < res.pages,
        ));
      } catch (_) {
        await loadLabTests(branchId: _currentBranchId);
      }
    } else {
      await loadLabTests(branchId: _currentBranchId);
    }
  }
}
