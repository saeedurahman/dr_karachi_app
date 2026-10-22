import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../home/data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;
  final bool isAdding;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onTap,
    this.isAdding = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPercent > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image + Badges Header
                Expanded(
                  child: Stack(
                    children: [
                      // Product Image Container
                      Center(
                        child: product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.primaryAccent,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),

                      // Rx Required Badge
                      if (product.requiresPrescription)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Rx',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Discount Badge
                      if (hasDiscount)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${product.discountPercent.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Product Title
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.structuralNavy,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 4),

                // SKU or Subtitle
                if (product.sku.isNotEmpty)
                  Text(
                    product.sku,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: AppColors.secondary.withValues(alpha: 0.8),
                    ),
                  ),

                const SizedBox(height: 8),

                // Price and Add Button Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Text(
                              'Rs. ${product.originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.secondary,
                              ),
                            ),
                          Text(
                            'Rs. ${product.discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildAddButton(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.canvasBase,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          Icons.medication_liquid_rounded,
          size: 44,
          color: AppColors.primaryAccent.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final isOutOfStock =
        product.stockAtBranch != null && product.stockAtBranch! <= 0;

    if (isOutOfStock) {
      if (kDebugMode) {
        debugPrint('[ProductCard] "${product.name}" is marked Unavailable/OutOfStock (stock: ${product.stockAtBranch})');
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Unavailable',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isAdding
          ? () {
              if (kDebugMode) {
                debugPrint('[ProductCard] Add tapped while isAdding is true for "${product.name}" (ignored)');
              }
            }
          : () {
              if (kDebugMode) {
                debugPrint('[ProductCard] Add button tapped for: "${product.name}" (ID: ${product.id})');
              }
              if (onAddToCart != null) {
                onAddToCart!();
              } else {
                if (kDebugMode) {
                  debugPrint('[ProductCard] ERROR: onAddToCart callback is null for "${product.name}"');
                }
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isAdding
              ? AppColors.primaryAccent.withValues(alpha: 0.7)
              : AppColors.primaryAccent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isAdding
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_shopping_cart_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
