import '../../../home/data/models/lab_test_model.dart';

abstract class LabState {}

class LabInitial extends LabState {}

class LabLoading extends LabState {}

class LabLoaded extends LabState {
  final List<LabTestModel> allTests;
  final List<LabTestModel> filteredTests;
  final String? selectedCategory; // 'All', 'Popular', 'Home Sampling', 'Routine'
  final String searchQuery;

  LabLoaded({
    required this.allTests,
    required this.filteredTests,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  LabLoaded copyWith({
    List<LabTestModel>? allTests,
    List<LabTestModel>? filteredTests,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return LabLoaded(
      allTests: allTests ?? this.allTests,
      filteredTests: filteredTests ?? this.filteredTests,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LabError extends LabState {
  final String message;
  LabError(this.message);
}
