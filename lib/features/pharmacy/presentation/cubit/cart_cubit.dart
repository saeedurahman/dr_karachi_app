import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/data/models/branch_model.dart';
import '../../../home/data/models/product_model.dart';
import '../../data/models/branch_switch_warning_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/checkout_models.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final PharmacyRepository repository;

  CartCubit({required this.repository}) : super(CartInitial());

  List<BranchModel> _cachedBranches = [];
  BranchModel? _selectedBranch;

  String? lastErrorMessage;
  bool lastErrorWasAuth = false;

  @override
  void emit(CartState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  void updateBranches(List<BranchModel> branches, {BranchModel? selectedBranch}) {
    _cachedBranches = branches;
    if (selectedBranch != null) {
      _selectedBranch = selectedBranch;
    } else if (_selectedBranch == null && branches.isNotEmpty) {
      _selectedBranch = branches.first;
    }

    final current = state;
    if (current is CartLoaded) {
      emit(current.copyWith(
        branches: _cachedBranches,
        currentBranch: _selectedBranch,
      ));
    }
  }

  void selectBranch(BranchModel branch) {
    _selectedBranch = branch;
    final current = state;
    if (current is CartLoaded) {
      emit(current.copyWith(currentBranch: branch));
    }
  }

  Future<void> loadCart() async {
    if (isClosed) return;
    emit(CartLoading());
    try {
      if (_cachedBranches.isEmpty) {
        _cachedBranches = await repository.getBranches();
        if (_cachedBranches.isNotEmpty && _selectedBranch == null) {
          _selectedBranch = _cachedBranches.first;
        }
      }

      final cart = await repository.getCart();

      // If cart already has a branch, align selectedBranch with it
      if (cart.branchId != null && _cachedBranches.isNotEmpty) {
        final match = _cachedBranches.where((b) => b.id == cart.branchId);
        if (match.isNotEmpty) {
          _selectedBranch = match.first;
        }
      }

      emit(CartLoaded(
        cart: cart,
        branches: _cachedBranches,
        currentBranch: _selectedBranch,
      ));
    } catch (e) {
      // If error (e.g. 401 unauthenticated), provide empty cart with cached branches so UI works cleanly
      if (_cachedBranches.isNotEmpty) {
        emit(CartLoaded(
          cart: CartModel.empty(),
          branches: _cachedBranches,
          currentBranch: _selectedBranch,
        ));
      } else {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<bool> addToCart(
    ProductModel product,
    String branchId, {
    int quantity = 1,
  }) async {
    lastErrorMessage = null;
    lastErrorWasAuth = false;

    if (kDebugMode) {
      debugPrint('[CartCubit] addToCart called: product="${product.name}" (ID: ${product.id}), branchId="$branchId", quantity=$quantity');
    }
    final current = state;
    if (kDebugMode) {
      debugPrint('[CartCubit] Current CartState: ${current.runtimeType}');
    }
    CartModel existingCart = CartModel.empty();
    if (current is CartLoaded) {
      existingCart = current.cart;
      if (kDebugMode) {
        debugPrint('[CartCubit] Existing cart has ${existingCart.items.length} items');
      }
      emit(current.copyWith(addingProductId: product.id));
    }

    try {
      if (kDebugMode) {
        debugPrint('[CartCubit] Calling repository.addToCart(productId: ${product.id}, branchId: $branchId, qty: $quantity)...');
      }
      final updatedCart = await repository.addToCart(
        productId: product.id,
        branchId: branchId,
        quantity: quantity,
      );
      if (kDebugMode) {
        debugPrint('[CartCubit] repository.addToCart SUCCESS! Returned cart items: ${updatedCart.items.length}');
      }

      // Match branch
      if (_cachedBranches.isNotEmpty) {
        final match = _cachedBranches.where((b) => b.id == branchId);
        if (match.isNotEmpty) {
          _selectedBranch = match.first;
          if (kDebugMode) {
            debugPrint('[CartCubit] Matched branch: ${_selectedBranch?.name}');
          }
        }
      }

      emit(CartLoaded(
        cart: updatedCart,
        branches: _cachedBranches,
        currentBranch: _selectedBranch,
        addingProductId: null,
      ));
      if (kDebugMode) {
        debugPrint('[CartCubit] Emitted CartLoaded state successfully');
      }
      return true;
    } on BranchConflictException catch (e) {
      if (kDebugMode) {
        debugPrint('[CartCubit] Caught BranchConflictException: currentBranch=${e.warning.currentBranchId}, requestedBranch=${e.warning.requestedBranchId}');
      }
      String currName = 'another branch';
      String reqName = 'this branch';

      final currMatches = _cachedBranches.where((b) => b.id == e.warning.currentBranchId);
      if (currMatches.isNotEmpty) currName = currMatches.first.name;

      final reqMatches = _cachedBranches.where((b) => b.id == e.warning.requestedBranchId);
      if (reqMatches.isNotEmpty) reqName = reqMatches.first.name;

      emit(CartConflict(
        warning: e.warning,
        pendingProduct: product,
        pendingQuantity: quantity,
        currentBranchName: currName,
        requestedBranchName: reqName,
        currentCart: existingCart,
      ));
      if (kDebugMode) {
        debugPrint('[CartCubit] Emitted CartConflict state');
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        lastErrorWasAuth = true;
        lastErrorMessage = 'Please sign in to add medicines to cart.';
      } else {
        lastErrorWasAuth = false;
        final data = e.response?.data;
        if (data is Map && data['detail'] is String) {
          lastErrorMessage = data['detail'] as String;
        } else {
          lastErrorMessage = 'Could not add item to cart. Please try again.';
        }
      }
      if (kDebugMode) {
        debugPrint('[CartCubit] DioException in addToCart: $lastErrorMessage');
      }
      if (current is CartLoaded) {
        emit(current.copyWith(clearAddingProduct: true));
      }
      return false;
    } catch (e, stack) {
      lastErrorWasAuth = false;
      lastErrorMessage = 'An unexpected error occurred.';
      if (kDebugMode) {
        debugPrint('[CartCubit] ERROR in addToCart: $e\n$stack');
      }
      if (current is CartLoaded) {
        emit(current.copyWith(clearAddingProduct: true));
      }
      return false;
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    final current = state;
    if (current is! CartLoaded) return;

    if (newQuantity <= 0) {
      await removeItem(itemId);
      return;
    }

    emit(current.copyWith(updatingItemId: itemId));
    try {
      final updatedCart = await repository.updateCartItem(
        itemId: itemId,
        quantity: newQuantity,
      );
      emit(current.copyWith(
        cart: updatedCart,
        clearUpdatingItem: true,
      ));
    } catch (_) {
      emit(current.copyWith(clearUpdatingItem: true));
    }
  }

  Future<void> removeItem(String itemId) async {
    final current = state;
    if (current is! CartLoaded) return;

    emit(current.copyWith(updatingItemId: itemId));
    try {
      final updatedCart = await repository.removeCartItem(itemId);
      emit(current.copyWith(
        cart: updatedCart,
        clearUpdatingItem: true,
      ));
    } catch (_) {
      emit(current.copyWith(clearUpdatingItem: true));
    }
  }

  Future<void> clearCart() async {
    final current = state;
    if (current is! CartLoaded) return;

    emit(current.copyWith(isClearing: true));
    try {
      await repository.clearCart();
      emit(current.copyWith(
        cart: CartModel.empty(),
        isClearing: false,
      ));
    } catch (_) {
      emit(current.copyWith(isClearing: false));
    }
  }

  Future<void> resolveConflictAndAdd(
    ProductModel product,
    String newBranchId,
    int quantity,
  ) async {
    emit(CartLoading());
    try {
      // 1. Clear cart
      await repository.clearCart();

      // 2. Add pending item to new branch
      final updatedCart = await repository.addToCart(
        productId: product.id,
        branchId: newBranchId,
        quantity: quantity,
      );

      // 3. Switch selected branch
      final match = _cachedBranches.where((b) => b.id == newBranchId);
      if (match.isNotEmpty) {
        _selectedBranch = match.first;
      }

      emit(CartLoaded(
        cart: updatedCart,
        branches: _cachedBranches,
        currentBranch: _selectedBranch,
      ));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void dismissConflict() {
    final current = state;
    if (current is CartConflict) {
      emit(CartLoaded(
        cart: current.currentCart,
        branches: _cachedBranches,
        currentBranch: _selectedBranch,
      ));
    }
  }

  Future<OrderResponseModel?> checkout(CheckoutRequestModel request) async {
    final current = state;
    if (current is! CartLoaded) return null;

    emit(current.copyWith(isCheckingOut: true));
    try {
      final order = await repository.checkout(request);
      emit(current.copyWith(
        cart: CartModel.empty(),
        isCheckingOut: false,
        lastOrder: order,
      ));
      return order;
    } catch (_) {
      emit(current.copyWith(isCheckingOut: false));
      rethrow;
    }
  }
}
