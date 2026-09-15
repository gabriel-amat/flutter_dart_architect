import '../../../core/di/app_injector.dart';
import '../../../core/network/http_client.dart';
import 'data/datasources/auth_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'presentation/controllers/login_controller.dart';

abstract final class AuthDependencies {
  static void setup(AppInjector injector) {
    // DataSource
    injector.registerLazySingleton<AuthDatasource>(
      () => AuthDatasource(injector.get<IHttpClient>()),
    );

    // Repository
    injector.registerLazySingleton<IAuthRepository>(
      () => AuthRepository(
        injector.get<AuthDatasource>(),
        injector.get<IHttpClient>(),
      ),
    );

    // UseCases
    injector.registerFactory<LoginUseCase>(
      () => LoginUseCase(injector.get<IAuthRepository>()),
    );

    // Controller
    injector.registerFactory<LoginController>(
      () => LoginController(injector.get<LoginUseCase>()),
    );
  }
}
