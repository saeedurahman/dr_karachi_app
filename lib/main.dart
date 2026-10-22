import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/main/presentation/pages/main_screen.dart';
import 'features/pharmacy/presentation/cubit/cart_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Uncaught platform error: $error');
    }
    return true;
  };

  // Friendly release ErrorWidget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    return const Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.structuralNavy,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'An unexpected error occurred. Please restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => di.sl<CartCubit>()..loadCart(),
        ),
      ],
      child: MaterialApp(
        title: 'Karachi Pharmacy',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.20,
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || (state is AuthLoading && context.read<AuthCubit>().state is AuthInitial)) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo/logo.png',
                    height: 60,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_hospital_rounded,
                      size: 60,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is Authenticated) {
          return const MainScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
