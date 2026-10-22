import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/otp_boxes_widget.dart';
import '../widgets/password_rules_widget.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordCubit>(
      create: (_) => sl<ForgotPasswordCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _enteredOtp = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSendPhone(BuildContext context) {
    if (_phoneFormKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<ForgotPasswordCubit>().sendOtp(
            overridePhone: _phoneController.text.trim(),
          );
    }
  }

  void _onVerifyOtp(BuildContext context) {
    if (_enteredOtp.length == 6) {
      FocusScope.of(context).unfocus();
      context.read<ForgotPasswordCubit>().verifyOtp(_enteredOtp);
    }
  }

  void _onResetPassword(BuildContext context) {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      final password = _passwordController.text;
      final confirm = _confirmPasswordController.text;

      final hasValidLength = password.length >= 8 && password.length <= 128;
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      final hasDigit = RegExp(r'\d').hasMatch(password);
      final hasMatch = password == confirm;

      if (!hasValidLength || !hasLetter || !hasDigit || !hasMatch) {
        return;
      }

      FocusScope.of(context).unfocus();
      context.read<ForgotPasswordCubit>().resetPassword(
            newPassword: password,
          );
    }
  }

  bool _canPopDirectly(ForgotPasswordStep step) {
    return step == ForgotPasswordStep.phone;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.step == ForgotPasswordStep.success) {
          // Success: Return to login screen with success snackbar
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF047857),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Password reset. Please log in with your new password.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ForgotPasswordCubit>();

        return PopScope(
          canPop: _canPopDirectly(state.step),
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              if (state.step == ForgotPasswordStep.otp) {
                cubit.changeNumber();
              } else if (state.step == ForgotPasswordStep.newPassword) {
                cubit.changeNumber();
              }
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Stack(
              children: [
                // Subtle decorative background elements
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryAccent.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF25D366).withValues(alpha: 0.06),
                    ),
                  ),
                ),

                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      // Top Navigation Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: AppColors.structuralNavy,
                              onPressed: () {
                                if (state.step == ForgotPasswordStep.otp ||
                                    state.step ==
                                        ForgotPasswordStep.newPassword) {
                                  cubit.changeNumber();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            const Spacer(),
                            // Step Progress Indicator
                            _buildStepBadge(state.step),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),

                      // Scrollable Form Card
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 16.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 24.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.94),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Error Banner
                                      if (state.errorMessage != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF1F2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFFFECDD3),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.error_outline_rounded,
                                                color: Color(0xFFBE123C),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  state.errorMessage!,
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFFBE123C),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () =>
                                                    cubit.clearError(),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Color(0xFFBE123C),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],

                                      // Active Step View
                                      if (state.step ==
                                          ForgotPasswordStep.phone)
                                        _buildPhoneStep(context, state)
                                      else if (state.step ==
                                          ForgotPasswordStep.otp)
                                        _buildOtpStep(context, state)
                                      else if (state.step ==
                                          ForgotPasswordStep.newPassword)
                                        _buildNewPasswordStep(context, state),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Step 1: Phone Input ---
  Widget _buildPhoneStep(BuildContext context, ForgotPasswordState state) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Icon(
            Icons.lock_reset_rounded,
            size: 46,
            color: AppColors.primaryAccent,
          ),
          const SizedBox(height: 14),
          const Text(
            'Forgot Password?',
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
            'Enter your registered mobile number to receive a 6-digit verification code on WhatsApp.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // WhatsApp Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF25D366).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: Color(0xFF128C7E),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Code will be delivered directly to your WhatsApp.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF128C7E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Phone Input
          AuthTextField(
            label: 'Phone Number',
            hintText: '+92 3XX XXXXXXX',
            controller: _phoneController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              final clean = val.replaceAll(' ', '');
              final phoneRegex =
                  RegExp(r'^((\+92)|(0092)|92|0)?3\d{9}$');
              if (!phoneRegex.hasMatch(clean)) {
                return 'Enter a valid Pakistani mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit Button
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: state.isLoading ? null : () => _onSendPhone(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send Code via WhatsApp',
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
        ],
      ),
    );
  }

  // --- Step 2: OTP Verification ---
  Widget _buildOtpStep(BuildContext context, ForgotPasswordState state) {
    final cubit = context.read<ForgotPasswordCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Icon(
          Icons.mark_chat_unread_outlined,
          size: 46,
          color: Color(0xFF128C7E),
        ),
        const SizedBox(height: 14),
        const Text(
          'Verify WhatsApp Code',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.structuralNavy,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the 6-digit code sent to WhatsApp at\n${state.phone}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),

        // Change Number Link
        Center(
          child: TextButton.icon(
            onPressed: () => cubit.changeNumber(),
            icon: const Icon(
              Icons.edit_outlined,
              size: 14,
              color: AppColors.primaryAccent,
            ),
            label: const Text(
              'Change number',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // OTP Boxes
        OtpBoxesWidget(
          shouldShake: state.shouldShakeOtp,
          onShakeCompleted: () => cubit.resetShake(),
          onChanged: (code) {
            setState(() {
              _enteredOtp = code;
            });
          },
          onCompleted: (code) {
            setState(() {
              _enteredOtp = code;
            });
            _onVerifyOtp(context);
          },
        ),
        const SizedBox(height: 20),

        // Resend Countdown / Button
        Center(
          child: state.cooldownSeconds > 0
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Resend code in 00:${state.cooldownSeconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                )
              : TextButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => cubit.sendOtp(overridePhone: state.phone),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: Color(0xFF128C7E),
                  ),
                  label: const Text(
                    'Resend code via WhatsApp',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF128C7E),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 22),

        // Verify Button
        Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: _enteredOtp.length == 6 && !state.isLoading
                ? AppColors.primaryGradient
                : null,
            color: _enteredOtp.length == 6 && !state.isLoading
                ? null
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _enteredOtp.length == 6 && !state.isLoading
                ? [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: (_enteredOtp.length == 6 && !state.isLoading)
                ? () => _onVerifyOtp(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Verify Code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // --- Step 3: New Password Input ---
  Widget _buildNewPasswordStep(
      BuildContext context, ForgotPasswordState state) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Icon(
            Icons.vpn_key_rounded,
            size: 46,
            color: AppColors.primaryAccent,
          ),
          const SizedBox(height: 14),
          const Text(
            'Create New Password',
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
            'Choose a strong password to secure your Karachi Pharmacy account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // New Password Field
          AuthTextField(
            label: 'New Password',
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
            onChanged: (_) => setState(() {}),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please enter new password';
              }
              if (val.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'[a-zA-Z]').hasMatch(val)) {
                return 'Must contain at least one letter';
              }
              if (!RegExp(r'\d').hasMatch(val)) {
                return 'Must contain at least one digit';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Confirm Password Field
          AuthTextField(
            label: 'Confirm New Password',
            hintText: '••••••••',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_outline_rounded,
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
            onChanged: (_) => setState(() {}),
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

          // Live Password Rules Checklist
          PasswordRulesWidget(
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          ),
          const SizedBox(height: 24),

          // Reset Password Button
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: _areRulesMet() && !state.isLoading
                  ? AppColors.primaryGradient
                  : null,
              color: _areRulesMet() && !state.isLoading
                  ? null
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _areRulesMet() && !state.isLoading
                  ? [
                      BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
          ),
          child: ElevatedButton(
            onPressed: (_areRulesMet() && !state.isLoading)
                ? () => _onResetPassword(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    ),
  );
}

  bool _areRulesMet() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    final hasValidLength = password.length >= 8 && password.length <= 128;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasMatch = password.isNotEmpty && password == confirm;

    return hasValidLength && hasLetter && hasDigit && hasMatch;
  }

  Widget _buildStepBadge(ForgotPasswordStep currentStep) {
    final int stepNumber = currentStep == ForgotPasswordStep.phone
        ? 1
        : (currentStep == ForgotPasswordStep.otp ? 2 : 3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Step $stepNumber of 3',
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryAccent,
        ),
      ),
    );
  }
}
