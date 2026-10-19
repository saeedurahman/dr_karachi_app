import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/marketing_opt_in_checkbox.dart';
import '../../../main/presentation/pages/main_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _marketingOptIn = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Password strength evaluation (score 0 to 4)
  int _evaluatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[a-zA-Z]').hasMatch(password)) score++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) score++;
    return score;
  }

  String _getStrengthLabel(int score) {
    switch (score) {
      case 1:
        return 'Too Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  Color _getStrengthColor(int score) {
    switch (score) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF3B82F6);
      case 4:
        return const Color(0xFF10B981);
      default:
        return Colors.grey.shade300;
    }
  }

  void _onRegisterPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim().replaceAll(' ', '');
      context.read<AuthCubit>().register(
            fullName: _nameController.text.trim(),
            phone: phone,
            password: _passwordController.text,
            marketingOptIn: _marketingOptIn,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF047857),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  content: Text(
                    'Account created! Welcome, ${state.user.fullName}!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorMessage = state is AuthError ? state.message : null;
            final strength = _evaluatePasswordStrength(_passwordController.text);

            return Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/auth/auth-hero.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Soft light clinical overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.88),
                          const Color(0xFFF8FAFC).withValues(alpha: 0.94),
                          Colors.white.withValues(alpha: 0.96),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form Content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Brand Logo
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/images/logo/logo.png',
                              height: 52,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.local_hospital_rounded,
                                size: 45,
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Glass Card Form Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22.0,
                                  vertical: 24.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Create Account',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          color: AppColors.structuralNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Join Karachi Pharmacy for seamless pharmacy and lab services',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 18),

                                      // Error Banner
                                      if (errorMessage != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF1F2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFFFECDD3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.error_outline_rounded,
                                                color: Color(0xFFBE123C),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  errorMessage,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFFBE123C),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],

                                      // Full Name Input
                                      AuthTextField(
                                        label: 'Full Name',
                                        hintText: 'e.g. Ali Ahmed',
                                        controller: _nameController,
                                        prefixIcon: Icons.person_outline_rounded,
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Please enter your full name';
                                          }
                                          if (val.trim().length < 2) {
                                            return 'Name must be at least 2 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Phone Input
                                      AuthTextField(
                                        label: 'Phone Number',
                                        hintText: '+923001234567',
                                        controller: _phoneController,
                                        prefixIcon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Please enter your phone number';
                                          }
                                          final clean = val.replaceAll(' ', '');
                                          final phoneRegex = RegExp(r'^((\+92)|(0092)|92|0)?3\d{9}$');
                                          if (!phoneRegex.hasMatch(clean)) {
                                            return 'Enter a valid Pakistani mobile number';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Password Input
                                      AuthTextField(
                                        label: 'Password',
                                        hintText: '••••••••',
                                        controller: _passwordController,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
                                        onChanged: (_) => setState(() {}),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: const Color(0xFF64748B),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Please enter password';
                                          }
                                          if (val.length < 8) {
                                            return 'Password must be at least 8 characters';
                                          }
                                          return null;
                                        },
                                      ),

                                      // Password Strength Bar
                                      if (_passwordController.text.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: List.generate(4, (index) {
                                            final isActive = index < strength;
                                            return Expanded(
                                              child: Container(
                                                height: 4,
                                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(2),
                                                  color: isActive
                                                      ? _getStrengthColor(strength)
                                                      : Colors.grey.shade200,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Password strength:',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            Text(
                                              _getStrengthLabel(strength),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: _getStrengthColor(strength),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 14),

                                      // Confirm Password Input
                                      AuthTextField(
                                        label: 'Confirm Password',
                                        hintText: '••••••••',
                                        controller: _confirmPasswordController,
                                        prefixIcon: Icons.verified_user_outlined,
                                        obscureText: _obscureConfirmPassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: const Color(0xFF64748B),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword = !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (val != _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
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
                                      const SizedBox(height: 22),

                                      // Register Button
                                      Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryAccent
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () => _onRegisterPressed(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Create Account',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons.arrow_forward_rounded,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),

                                      // Login Link
                                      const SizedBox(height: 18),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Already have an account? ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
  }
}
