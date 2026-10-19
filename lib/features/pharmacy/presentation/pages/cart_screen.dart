import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/checkout_bottom_sheet.dart';
import '../widgets/quantity_selector.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.structuralNavy,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final count = state is CartLoaded ? state.cart.itemCount : 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shopping Cart',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.structuralNavy,
                  ),
                ),
                Text(
                  count == 0 ? '0 items' : '$count item${count == 1 ? '' : 's'} selected',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.isNotEmpty) {
                return TextButton.icon(
                  onPressed: () => _confirmClearCart(context),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Clear',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAccent),
            );
          }

          if (state is CartLoaded) {
            final cart = state.cart;
            if (cart.isEmpty) {
              return _buildEmptyCart(context);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Fulfilling Dispensary Card
                  _buildBranchBanner(context, state),
                  const SizedBox(height: 14),

                  // 2. Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItemCard(context, item, state);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Quality Assurance Seal
                  _buildQualitySeal(),
                  const SizedBox(height: 20),

                  // 4. Order Summary Card
                  _buildOrderSummary(context, cart, state),
                ],
              ),
            );
          }

          if (state is CartError) {
            return Center(
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
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<CartCubit>().loadCart(),
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
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 40,
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.structuralNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore our licensed pharmacy catalog to add genuine prescription medicines, OTC remedies, and health essentials.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.secondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Browse Pharmacy Catalog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchBanner(BuildContext context, CartLoaded state) {
    final branchName = state.currentBranch?.name ?? 'Quetta Flagship Dispensary';
    final city = state.currentBranch?.city ?? 'Quetta';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FULFILLING DISPENSARY',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7F1D1D),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$branchName ($city)',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.structuralNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    dynamic item,
    CartLoaded state,
  ) {
    final hasDiscount = item.discountPercent > 0;
    final isOutOfStock = item.stockAtBranch <= 0;
    final isLowStock = item.stockAtBranch > 0 && item.stockAtBranch <= 5;
    final isUpdating = state.updatingItemId == item.id;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pill Icon / Image
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.medication_liquid_rounded,
                  size: 24,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Rs. ${item.discountedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.structuralNavy,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${item.discountPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Trash delete button
              IconButton(
                onPressed: isUpdating
                    ? null
                    : () => context.read<CartCubit>().removeItem(item.id),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Stock Status Indicator
          if (isOutOfStock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Text(
                'Out of stock at this branch',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDC2626),
                ),
              ),
            )
          else if (isLowStock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                'Only ${item.stockAtBranch} available',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD97706),
                ),
              ),
            )
          else
            const Text(
              '✓ In Stock',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF16A34A),
              ),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Quantity Selector & Line Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuantitySelector(
                value: item.quantity,
                min: 1,
                max: item.stockAtBranch > 0 ? item.stockAtBranch : 20,
                disabled: isUpdating || isOutOfStock,
                onChange: (newQty) {
                  context.read<CartCubit>().updateQuantity(item.id, newQty);
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Rs. ${item.lineTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.structuralNavy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySeal() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: AppColors.primaryAccent,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'All prescription medicines will be reviewed by a licensed pharmacist before dispatch.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                color: AppColors.secondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, dynamic cart, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.structuralNavy,
            ),
          ),
          const SizedBox(height: 14),

          // Subtotal
          _buildSummaryRow('Subtotal', 'Rs. ${cart.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),

          // Savings
          if (cart.discountAmount > 0) ...[
            _buildSummaryRow(
              'Total Savings',
              '-Rs. ${cart.discountAmount.toStringAsFixed(0)}',
              valueColor: const Color(0xFF16A34A),
            ),
            const SizedBox(height: 8),
          ],

          // Delivery Charges
          _buildSummaryRow('Estimated Delivery', 'Rs. ${cart.deliveryCharges.toStringAsFixed(0)}'),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Grand Total (Subtotal + Delivery Charges)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grand Total',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.structuralNavy,
                    ),
                  ),
                  Text(
                    'Tax inclusive',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              Text(
                'Rs. ${(cart.subtotal + cart.deliveryCharges).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openCheckout(context),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Proceed to Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shadowColor: AppColors.primaryAccent.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Cash on Delivery (COD) supported upon delivery.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: AppColors.secondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.structuralNavy,
          ),
        ),
      ],
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Clear Cart?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your shopping cart?',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<CartCubit>().clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );
  }

  void _openCheckout(BuildContext context) {
    CheckoutBottomSheet.show(context);
  }
}
