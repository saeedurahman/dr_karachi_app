import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/marketing_opt_in_checkbox.dart';
import '../../data/models/checkout_models.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: const CheckoutBottomSheet(),
      ),
    );
  }

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  String _deliveryMethod = 'delivery'; // 'delivery' or 'pickup'
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _marketingOptIn = false;
  OrderResponseModel? _placedOrder;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_deliveryMethod == 'delivery' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _errorMessage = null);

    final req = CheckoutRequestModel(
      deliveryMethod: _deliveryMethod,
      deliveryAddress: _deliveryMethod == 'delivery' ? _addressController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      paymentMethod: 'cod',
      marketingOptIn: _marketingOptIn,
    );

    try {
      final order = await context.read<CartCubit>().checkout(req);
      if (order != null && mounted) {
        setState(() {
          _placedOrder = order;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: _placedOrder != null ? _buildOrderSuccess() : _buildCheckoutForm(),
      ),
    );
  }

  Widget _buildCheckoutForm() {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final isCheckingOut = state is CartLoaded && state.isCheckingOut;
        final cart = state is CartLoaded ? state.cart : null;
        final grandTotal = cart != null ? (cart.subtotal + cart.deliveryCharges) : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Complete Order',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Delivery Method Switcher
                const Text(
                  'Fulfillment Method',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.structuralNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMethodOption(
                        title: 'Doorstep Delivery',
                        subtitle: 'Direct to your home',
                        icon: Icons.delivery_dining_rounded,
                        value: 'delivery',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMethodOption(
                        title: 'Branch Pickup',
                        subtitle: 'Collect at dispensary',
                        icon: Icons.storefront_rounded,
                        value: 'pickup',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Delivery Address Field (if delivery)
                if (_deliveryMethod == 'delivery') ...[
                  const Text(
                    'Delivery Address (Quetta)',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.structuralNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    validator: (v) {
                      if (_deliveryMethod == 'delivery' && (v == null || v.trim().isEmpty)) {
                        return 'Please provide complete delivery address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g. House #12, Street 3, Cantt, Quetta',
                      hintStyle: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryAccent,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.structuralNavy.withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.structuralNavy.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primaryAccent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Order Notes (Optional)
                const Text(
                  'Special Instructions (Optional)',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.structuralNavy,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Call before arrival, leave with security',
                    hintStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.secondary,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.structuralNavy.withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.structuralNavy.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primaryAccent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Method Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.structuralNavy.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method: Cash on Delivery (COD)',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.structuralNavy,
                              ),
                            ),
                            Text(
                              'Pay when your verified medicine parcel is handed over.',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // WhatsApp Marketing Opt-In Checkbox
                MarketingOptInCheckbox(
                  value: _marketingOptIn,
                  onChanged: (val) {
                    setState(() {
                      _marketingOptIn = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCheckingOut ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: isCheckingOut
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Confirm Order • Rs. ${grandTotal.toStringAsFixed(0)}'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMethodOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _deliveryMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _deliveryMethod = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.structuralNavy.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primaryAccent : AppColors.secondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.structuralNavy : AppColors.secondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSuccess() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Order Placed Successfully!',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.structuralNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Order Reference: #${_placedOrder!.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryAccent,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Our licensed pharmacist at Karachi Lab Pharmacy will verify your medicines and dispatch them directly to your destination.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close sheet
                Navigator.of(context).pop(); // close cart screen back to pharmacy
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Back to Pharmacy'),
            ),
          ),
        ],
      ),
    );
  }
}
