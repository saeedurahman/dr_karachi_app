import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/pharmacy/data/datasources/pharmacy_remote_data_source.dart';
import '../../features/pharmacy/data/repositories/pharmacy_repository_impl.dart';
import '../../features/pharmacy/domain/repositories/pharmacy_repository.dart';
import '../../features/pharmacy/presentation/cubit/cart_cubit.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_cubit.dart';
import '../../features/lab/data/datasources/lab_remote_data_source.dart';
import '../../features/lab/data/repositories/lab_repository_impl.dart';
import '../../features/lab/domain/repositories/lab_repository.dart';
import '../../features/lab/presentation/cubit/lab_cubit.dart';
import '../../features/doctors/data/datasources/doctors_remote_data_source.dart';
import '../../features/doctors/data/repositories/doctors_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctors_repository.dart';
import '../../features/doctors/presentation/cubit/doctors_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/forgot_password/data/datasources/forgot_password_remote_data_source.dart';
import '../../features/forgot_password/data/repositories/forgot_password_repository_impl.dart';
import '../../features/forgot_password/domain/repositories/forgot_password_repository.dart';
import '../../features/forgot_password/presentation/cubit/forgot_password_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Home
  sl.registerFactory<HomeCubit>(() => HomeCubit(homeRepository: sl()));
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Pharmacy
  sl.registerFactory<PharmacyCubit>(() => PharmacyCubit(repository: sl()));
  sl.registerLazySingleton<CartCubit>(() => CartCubit(repository: sl()));
  sl.registerLazySingleton<PharmacyRepository>(
    () => PharmacyRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PharmacyRemoteDataSource>(
    () => PharmacyRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Lab
  sl.registerFactory<LabCubit>(() => LabCubit(repository: sl()));
  sl.registerLazySingleton<LabRepository>(
    () => LabRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LabRemoteDataSource>(
    () => LabRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Doctors
  sl.registerFactory<DoctorsCubit>(() => DoctorsCubit(repository: sl()));
  sl.registerLazySingleton<DoctorsRepository>(
    () => DoctorsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DoctorsRemoteDataSource>(
    () => DoctorsRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Auth
  // Cubits
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(authRepository: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      storageService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Forgot Password
  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(repository: sl()),
  );
  sl.registerLazySingleton<ForgotPasswordRepository>(
    () => ForgotPasswordRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ForgotPasswordRemoteDataSource>(
    () => ForgotPasswordRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Core
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: sl(),
      storageService: sl(),
      onAuthExpired: () {
        if (sl.isRegistered<AuthCubit>()) {
          sl<AuthCubit>().forceUnauthenticated();
        }
      },
    ),
  );

  //! External
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(resetOnError: true),
    ),
  );
  sl.registerLazySingleton<Dio>(() => Dio());
}
