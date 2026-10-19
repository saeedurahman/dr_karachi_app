import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class PharmacySearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final String initialValue;

  const PharmacySearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialValue = '',
  });

  @override
  State<PharmacySearchBar> createState() => _PharmacySearchBarState();
}

class _PharmacySearchBarState extends State<PharmacySearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearchChanged(value);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          color: AppColors.structuralNavy,
        ),
        decoration: InputDecoration(
          hintText: 'Search medicines, multivitamins, tests...',
          hintStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: AppColors.secondary.withValues(alpha: 0.7),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.secondary,
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }
}
