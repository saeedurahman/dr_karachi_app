import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/branch_model.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;

  HomeCubit({required this.homeRepository}) : super(HomeInitial());

  @override
  void emit(HomeState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadHomeData({String? branchId}) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        homeRepository.getBranches(),
        homeRepository.getDoctors(branchId: branchId),
        homeRepository.getFeaturedProducts(branchId: branchId),
        homeRepository.getLabTests(branchId: branchId),
        homeRepository.getActiveAppointment(),
      ]);

      final branches = (results[0] as List).cast<BranchModel>();
      final doctors = results[1] as List<dynamic>;
      final products = results[2] as List<dynamic>;
      final labTests = results[3] as List<dynamic>;
      final activeAppointment = results[4];

      BranchModel? selectedBranch;
      if (branches.isNotEmpty) {
        if (branchId != null) {
          selectedBranch = branches.firstWhere(
            (b) => b.id == branchId,
            orElse: () => branches.first,
          );
        } else {
          selectedBranch = branches.first;
        }
      }

      emit(
        HomeLoaded(
          branches: branches,
          selectedBranch: selectedBranch,
          doctors: doctors.cast(),
          products: products.cast(),
          labTests: labTests.cast(),
          activeAppointment: activeAppointment as dynamic,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> selectBranch(BranchModel branch) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(selectedBranch: branch));
      try {
        final results = await Future.wait([
          homeRepository.getDoctors(branchId: branch.id),
          homeRepository.getFeaturedProducts(branchId: branch.id),
          homeRepository.getLabTests(branchId: branch.id),
        ]);

        emit(
          current.copyWith(
            selectedBranch: branch,
            doctors: (results[0] as List).cast(),
            products: (results[1] as List).cast(),
            labTests: (results[2] as List).cast(),
          ),
        );
      } catch (_) {
        // Keep current data if refetch fails
      }
    }
  }
}
