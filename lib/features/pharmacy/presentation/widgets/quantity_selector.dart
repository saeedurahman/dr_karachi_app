import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final bool disabled;
  final ValueChanged<int> onChange;

  const QuantitySelector({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 99,
    this.disabled = false,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement / Delete
          _buildButton(
            icon: value <= min ? Icons.delete_outline_rounded : Icons.remove_rounded,
            color: value <= min ? const Color(0xFFDC2626) : AppColors.structuralNavy,
            enabled: !disabled,
            onTap: () {
              if (value <= min) {
                onChange(0); // indicates removal
              } else {
                onChange(value - 1);
              }
            },
          ),

          // Value Display
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
          ),

          // Increment
          _buildButton(
            icon: Icons.add_rounded,
            color: AppColors.primaryAccent,
            enabled: !disabled && value < max,
            onTap: () {
              if (value < max) {
                onChange(value + 1);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: enabled ? color : color.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
