import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../cubit/cart_conflict_info.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/pharmacy_cubit.dart';
import '../cubit/pharmacy_state.dart';
import '../widgets/branch_conflict_dialog.dart';
import '../widgets/category_chips.dart';
import '../widgets/pharmacy_search_bar.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class PharmacyScreen extends StatelessWidget {
  final String? initialBranchId;

  const PharmacyScreen({super.key, this.initialBranchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cartState = ctx.read<CartCubit>().state;
        String? defaultBranch = initialBranchId;
        if (defaultBranch == null && cartState is CartLoaded) {
          defaultBranch = cartState.currentBranch?.id ??
              (cartState.branches.isNotEmpty ? cartState.branches.first.id : null);
        }
        defaultBranch ??= '44444444-4444-4444-4444-444444444444';
        return sl<PharmacyCubit>()..loadInitialData(branchId: defaultBranch);
      },
      child: const _PharmacyScreenContent(),
    );
  }
}

class _PharmacyScreenContent extends StatelessWidget {
  const _PharmacyScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (kDebugMode) {
          debugPrint('[PharmacyScreen] BlocListener received CartState: ${state.runtimeType}');
        }
        if (state is CartConflict) {
          BranchConflictDialog.show(
            context,
            conflict: CartConflictInfo(
              warning: state.warning,
              pendingProduct: state.pendingProduct,
              pendingQuantity: state.pendingQuantity,
              currentBranchName: state.currentBranchName,
              requestedBranchName: state.requestedBranchName,
            ),
            onKeepCurrentCart: () {
              Navigator.of(context).pop();
              context.read<CartCubit>().dismissConflict();
            },
            onClearAndSwitch: () {
              Navigator.of(context).pop();
              context.read<CartCubit>().resolveConflictAndAdd(
                    state.pendingProduct,
                    state.warning.requestedBranchId,
                    state.pendingQuantity,
                  );
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvasBase,
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                color: AppColors.primaryAccent,
                onRefresh: () async {
                  await Future.wait([
                    context.read<PharmacyCubit>().refresh(),
                    context.read<CartCubit>().loadCart(),
                  ]);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Top Clinical Header + Cart Icon
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.medication_rounded,
                                    color: AppColors.primaryAccent,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Karachi Lab Pharmacy',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.structuralNavy,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '100% Genuine Medicines • Fast Delivery',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 12,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Shopping Cart Icon Button with Live Counter Badge
                                _buildCartIconButton(context),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Dispensary Branch Selector Chip (Quetta single-branch model)
                            _buildBranchSelectorStrip(context),
                            const SizedBox(height: 12),


                            // Search Bar
                            PharmacySearchBar(
                              onSearchChanged: (query) {
                                context.read<PharmacyCubit>().search(query);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Category Chips Bar
                    SliverToBoxAdapter(
                      child: BlocBuilder<PharmacyCubit, PharmacyState>(
                        builder: (context, state) {
                          if (state is PharmacyLoaded && state.categories.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CategoryChips(
                                categories: state.categories,
                                selectedCategoryId: state.selectedCategoryId,
                                onCategorySelected: (catId) {
                                  context.read<PharmacyCubit>().selectCategory(catId);
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    // 3. Products Grid or State View
                    BlocBuilder<PharmacyCubit, PharmacyState>(
                      builder: (context, pharmacyState) {
                        if (pharmacyState is PharmacyLoading) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          );
                        }

                        if (pharmacyState is PharmacyError) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 48,
                                      color: AppColors.primaryAccent,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      pharmacyState.message,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 14,
                                        color: AppColors.structuralNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () =>
                                          context.read<PharmacyCubit>().refresh(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Try Again'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (pharmacyState is PharmacyLoaded) {
                          if (pharmacyState.products.isEmpty) {
                            return SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 56,
                                        color: AppColors.secondary.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No medicines found',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.structuralNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Try searching with a generic name, brand or clearing selected category filter.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 13,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return BlocBuilder<CartCubit, CartState>(
                            builder: (context, cartState) {
                              final hasItemsInCart =
                                  cartState is CartLoaded && cartState.cart.isNotEmpty;

                              return SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  hasItemsInCart ? 170 : 120,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.68,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final product = pharmacyState.products[index];
                                      final isAdding = cartState is CartLoaded &&
                                          cartState.addingProductId == product.id;

                                      return ProductCard(
                                        product: product,
                                        isAdding: isAdding,
                                        onAddToCart: () {
                                          if (kDebugMode) {
                                            debugPrint('[PharmacyScreen] ProductCard.onAddToCart triggered for: "${product.name}" (ID: ${product.id})');
                                          }
                                          _handleAddToCart(
                                            context,
                                            product,
                                            cartState,
                                          );
                                        },
                                      );
                                    },
                                    childCount: pharmacyState.products.length,
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      },
                    ),
                  ],
                ),
              ),

              // 4. Floating Sticky Cart Summary Bar (Above Glass Bottom Nav)
              BlocBuilder<CartCubit, CartState>(
                builder: (context, cartState) {
                  if (cartState is CartLoaded && cartState.cart.isNotEmpty) {
                    return Positioned(
                      left: 16,
                      right: 16,
                      bottom: 94,
                      child: _buildFloatingCartBar(context, cartState.cart),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartIconButton(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final count = cartState is CartLoaded ? cartState.cart.itemCount : 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<CartCubit>(),
                  child: const CartScreen(),
                ),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.structuralNavy.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.structuralNavy.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.structuralNavy,
                  size: 20,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchSelectorStrip(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final currentBranch = cartState is CartLoaded ? cartState.currentBranch : null;
        final branchName = currentBranch?.name ?? 'Quetta - Zain Plaza';
        final city = currentBranch?.city ?? 'Balochistan';

        return GestureDetector(
          onTap: () => _openBranchSelectionSheet(context, cartState),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 16,
                  color: AppColors.primaryAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Dispensary: ',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '$branchName ($city)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.structuralNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openBranchSelectionSheet(BuildContext context, CartState state) {
    if (state is! CartLoaded || state.branches.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Select Fulfilling Dispensary',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.structuralNavy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Medicines will be dispatched with verified inventory from the selected branch.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.branches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final b = state.branches[i];
                      final isSelected = state.currentBranch?.id == b.id;

                      return ListTile(
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          context.read<CartCubit>().selectBranch(b);
                          context.read<PharmacyCubit>().changeBranch(b.id);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryAccent
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        tileColor: isSelected
                            ? const Color(0xFFFFF1F2)
                            : const Color(0xFFF8FAFC),
                        leading: Icon(
                          Icons.location_on_rounded,
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.secondary,
                        ),
                        title: Text(
                          b.name,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.primaryAccent
                                : AppColors.structuralNavy,
                          ),
                        ),
                        subtitle: Text(
                          b.address.isNotEmpty ? b.address : '${b.city}, Pakistan',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.secondary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryAccent,
                                size: 20,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAddToCart(
    BuildContext context,
    dynamic product,
    CartState cartState,
  ) async {
    if (kDebugMode) {
      debugPrint('-------------------- [ADD TO CART FLOW] --------------------');
      debugPrint('[PharmacyScreen] _handleAddToCart START for: "${product.name}" (ID: ${product.id})');
      debugPrint('[PharmacyScreen] Current cartState runtimeType: ${cartState.runtimeType}');
    }

    String? branchId;
    if (cartState is CartLoaded && cartState.currentBranch != null) {
      branchId = cartState.currentBranch!.id;
      if (kDebugMode) {
        debugPrint('[PharmacyScreen] Branch from CartLoaded.currentBranch: $branchId (${cartState.currentBranch!.name})');
      }
    } else if (cartState is CartLoaded && cartState.branches.isNotEmpty) {
      branchId = cartState.branches.first.id;
      if (kDebugMode) {
        debugPrint('[PharmacyScreen] Branch from CartLoaded.branches.first: $branchId');
      }
    } else {
      branchId = context.read<PharmacyCubit>().currentBranchId;
      if (kDebugMode) {
        debugPrint('[PharmacyScreen] Branch from PharmacyCubit: $branchId');
      }
    }

    // Default to real Quetta Cantt Branch ID from database
    if (branchId == null) {
      branchId = '44444444-4444-4444-4444-444444444444';
      if (kDebugMode) {
        debugPrint('[PharmacyScreen] branchId was null, using default: $branchId');
      }
    }

    if (kDebugMode) {
      debugPrint('[PharmacyScreen] Calling CartCubit.addToCart(productId: ${product.id}, branchId: $branchId, qty: 1)...');
    }
    final success = await context.read<CartCubit>().addToCart(
          product,
          branchId,
          quantity: 1,
        );

    if (kDebugMode) {
      debugPrint('[PharmacyScreen] CartCubit.addToCart finished -> success: $success, mounted: ${context.mounted}');
      debugPrint('------------------------------------------------------------');
    }

    if (!context.mounted) return;

    if (success) {
      // User requested to remove the "Added <item> to cart" SnackBar banner.
      // The bottom sticky cart bar updates automatically with items & total.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } else {
      final cartCubit = context.read<CartCubit>();
      if (cartCubit.lastErrorWasAuth) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.structuralNavy,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please sign in to add medicines to your cart.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'SIGN IN',
              textColor: const Color(0xFFFDE047),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        );
      } else if (cartCubit.lastErrorMessage != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cartCubit.lastErrorMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Widget _buildFloatingCartBar(BuildContext context, dynamic cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.structuralNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${cart.itemCount} Item${cart.itemCount == 1 ? '' : 's'} Selected',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                Text(
                  'Rs. ${cart.grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CartCubit>(),
                    child: const CartScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
            label: const Text('View Cart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
