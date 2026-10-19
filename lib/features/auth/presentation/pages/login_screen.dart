import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignInPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _onQuickTestLogin(BuildContext context) {
    const testPhone = '+923001234567';
    const testPass = 'Password123!';
    _phoneController.text = testPhone;
    _passwordController.text = testPass;
    context.read<AuthCubit>().login(
          phone: testPhone,
          password: testPass,
        );
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
                    'Welcome back, ${state.user.fullName}!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              );
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorMessage = state is AuthError ? state.message : null;

            return Stack(
              children: [
                // Fullscreen background hero with frosted glass effect
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
                        vertical: 24.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Brand Logo
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/images/logo/logo.png',
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.local_hospital_rounded,
                                size: 50,
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Glass Card Form Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22.0,
                                  vertical: 26.0,
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
                                        'Sign In to Karachi Pharmacy',
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
                                        'Access your pharmacy cart, active prescriptions, and lab bookings',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

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

                                      // Phone Input
                                      AuthTextField(
                                        label: 'Phone Number',
                                        hintText: '+923001234567',
                                        controller: _phoneController,
                                        prefixIcon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Please enter phone number';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Password Input
                                      AuthTextField(
                                        label: 'Password',
                                        hintText: '••••••••',
                                        controller: _passwordController,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
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
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 22),

                                      // Sign In Button
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
                                              : () => _onSignInPressed(context),
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
                                                      'Sign In',
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

                                      // Developer Quick Test Login (Matching Frontend dev card)
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF1F2).withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: AppColors.primaryAccent.withValues(alpha: 0.25),
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.auto_awesome,
                                                  size: 14,
                                                  color: AppColors.primaryAccent,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Quick Test Account',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF991B1B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Patient account (+923001234567 / Password123!) for rapid testing.',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                color: Color(0xFF7F1D1D),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 32,
                                              width: double.infinity,
                                              child: OutlinedButton(
                                                onPressed: isLoading
                                                    ? null
                                                    : () => _onQuickTestLogin(context),
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  side: BorderSide(
                                                    color: AppColors.primaryAccent
                                                        .withValues(alpha: 0.4),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                                child: const Text(
                                                  'Auto-fill & Sign In as Test Patient',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF991B1B),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Register Link
                                      const SizedBox(height: 18),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Don't have an account yet? ",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const RegisterScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Create Account',
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
