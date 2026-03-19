import 'package:get_it/get_it.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/usecases/auth_usecases.dart';
import 'domain/usecases/chat_usecases.dart';

final sl = GetIt.instance; // Service Locator

void init() {
  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl());

  // UseCases
  sl.registerLazySingleton(() => AuthUseCases(sl()));
  sl.registerLazySingleton(() => ChatUseCases(sl()));
}
