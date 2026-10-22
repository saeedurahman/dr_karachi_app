import 'package:flutter/material.dart';

class PasswordRulesWidget extends StatelessWidget {
  final String password;
  final String confirmPassword;

  const PasswordRulesWidget({
    super.key,
    required this.password,
    required this.confirmPassword,
  });

  bool get hasValidLength => password.length >= 8 && password.length <= 128;
  bool get hasLetter => RegExp(r'[a-zA-Z]').hasMatch(password);
  bool get hasDigit => RegExp(r'\d').hasMatch(password);
  bool get hasMatch =>
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      password == confirmPassword;

  bool get isAllSatisfied =>
      hasValidLength && hasLetter && hasDigit && hasMatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PASSWORD REQUIREMENTS',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          _buildRuleItem('8 – 128 characters', hasValidLength),
          const SizedBox(height: 6),
          _buildRuleItem('At least one letter (a-z, A-Z)', hasLetter),
          const SizedBox(height: 6),
          _buildRuleItem('At least one digit (0-9)', hasDigit),
          const SizedBox(height: 6),
          _buildRuleItem('Passwords match', hasMatch),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text, bool isMet) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isMet ? const Color(0xFF10B981) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isMet ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              width: 1.5,
            ),
          ),
          child: isMet
              ? const Icon(
                  Icons.check,
                  size: 11,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
              color: isMet ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}
