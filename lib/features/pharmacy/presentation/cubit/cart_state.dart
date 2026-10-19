import '../../../home/data/models/branch_model.dart';
import '../../../home/data/models/product_model.dart';
import '../../data/models/branch_switch_warning_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/checkout_models.dart';

abstract class CartState {
  const CartState();
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartModel cart;
  final List<BranchModel> branches;
  final BranchModel? currentBranch;
  final String? addingProductId;
  final String? updatingItemId;
  final bool isClearing;
  final bool isCheckingOut;
  final OrderResponseModel? lastOrder;

  const CartLoaded({
    required this.cart,
    this.branches = const [],
    this.currentBranch,
    this.addingProductId,
    this.updatingItemId,
    this.isClearing = false,
    this.isCheckingOut = false,
    this.lastOrder,
  });

  CartLoaded copyWith({
    CartModel? cart,
    List<BranchModel>? branches,
    BranchModel? currentBranch,
    String? addingProductId,
    bool clearAddingProduct = false,
    String? updatingItemId,
    bool clearUpdatingItem = false,
    bool? isClearing,
    bool? isCheckingOut,
    OrderResponseModel? lastOrder,
  }) {
    return CartLoaded(
      cart: cart ?? this.cart,
      branches: branches ?? this.branches,
      currentBranch: currentBranch ?? this.currentBranch,
      addingProductId: clearAddingProduct ? null : (addingProductId ?? this.addingProductId),
      updatingItemId: clearUpdatingItem ? null : (updatingItemId ?? this.updatingItemId),
      isClearing: isClearing ?? this.isClearing,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      lastOrder: lastOrder ?? this.lastOrder,
    );
  }
}

class CartConflict extends CartState {
  final BranchSwitchWarningModel warning;
  final ProductModel pendingProduct;
  final int pendingQuantity;
  final String currentBranchName;
  final String requestedBranchName;
  final CartModel currentCart;

  const CartConflict({
    required this.warning,
    required this.pendingProduct,
    required this.pendingQuantity,
    required this.currentBranchName,
    required this.requestedBranchName,
    required this.currentCart,
  });
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);
}
