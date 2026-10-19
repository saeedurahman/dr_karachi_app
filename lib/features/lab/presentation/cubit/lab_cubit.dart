import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/data/models/lab_test_model.dart';
import '../../domain/repositories/lab_repository.dart';
import 'lab_state.dart';

class LabCubit extends Cubit<LabState> {
  final LabRepository repository;

  LabCubit({required this.repository}) : super(LabInitial());

  String? _currentBranchId;

  Future<void> loadLabTests({String? branchId}) async {
    if (branchId != null) _currentBranchId = branchId;
    emit(LabLoading());

    try {
      final tests = await repository.getLabTests(branchId: _currentBranchId);
      if (isClosed) return;
      emit(LabLoaded(
        allTests: tests,
        filteredTests: tests,
        selectedCategory: 'All',
        searchQuery: '',
      ));
    } catch (_) {
      if (isClosed) return;
      emit(LabError('Failed to load diagnostic lab tests. Please try again.'));
    }
  }

  void selectCategory(String category) {
    final currentState = state;
    if (currentState is! LabLoaded) return;

    final filtered = _applyFilters(
      currentState.allTests,
      category,
      currentState.searchQuery,
    );

    emit(currentState.copyWith(
      selectedCategory: category,
      filteredTests: filtered,
    ));
  }

  void search(String query) {
    final currentState = state;
    if (currentState is! LabLoaded) return;

    final filtered = _applyFilters(
      currentState.allTests,
      currentState.selectedCategory ?? 'All',
      query,
    );

    emit(currentState.copyWith(
      searchQuery: query,
      filteredTests: filtered,
    ));
  }

  List<LabTestModel> _applyFilters(
    List<LabTestModel> tests,
    String category,
    String query,
  ) {
    return tests.where((test) {
      final matchesSearch = query.trim().isEmpty ||
          test.name.toLowerCase().contains(query.trim().toLowerCase()) ||
          test.code.toLowerCase().contains(query.trim().toLowerCase()) ||
          (test.description?.toLowerCase().contains(query.trim().toLowerCase()) ?? false);

      if (!matchesSearch) return false;

      if (category == 'Home Sampling') {
        return test.homeSamplingAvailable;
      } else if (category == 'Packages') {
        return test.code.toLowerCase().contains('pkg') ||
            test.name.toLowerCase().contains('package') ||
            test.name.toLowerCase().contains('profile');
      } else if (category == 'Fast Reports') {
        return (test.turnaroundHours ?? 24) <= 12;
      }

      return true; // 'All'
    }).toList();
  }

  Future<void> refresh() async {
    await loadLabTests(branchId: _currentBranchId);
  }
}
