# 📐 Flutter & Dart Architect Specification (SPEC)
### Standard Architectural Guidelines for Production-Ready Flutter Apps & AI Coding Assistants
*Version: 1.0.0 | Maintainer: Gabriel Amat | Target: Dart 3.3+ / Flutter 3.19+*

---

## 🎯 Purpose & Philosophy

Most AI coding assistants (ChatGPT, Claude, Copilot, Cursor, Antigravity) default to generating **anti-patterns** in Flutter:
- Deeply nested widgets with inline business logic.
- Mixing HTTP clients (e.g. raw `Dio`) directly in UI or Blocs.
- Catching generic exceptions and failing silently.
- Over-engineered state management or bloated model classes.
- Infinite recursion loops on 401 token refresh.
- Leaking infrastructure details into the domain layer.

This specification serves as the **ground-truth contract** for human developers and AI agents alike. Any code produced under the `flutter-dart-architect` standard must strictly follow these rules.

---

## 🏛️ 1. Project Directory Structure

Every application is organized by **Feature-Driven Clean Architecture**:

```
lib/
 ├─ core/                           # Cross-cutting foundational modules
 │   ├─ config/
 │   │   └─ environment_config.dart # Environment targets (local, hg, prod)
 │   ├─ di/
 │   │   ├─ app_injector.dart       # Abstraction for DI container
 │   │   ├─ injector_impl.dart      # Concrete DI implementation
 │   │   └─ service_locator.dart    # Global locator instance
 │   ├─ error/
 │   │   ├─ either.dart             # Lightweight zero-dependency Either/Left/Right
 │   │   ├─ exceptions.dart         # Core infrastructure exceptions
 │   │   └─ failure.dart            # Domain failure abstractions
 │   ├─ navigation/
 │   │   ├─ app_pages.dart          # Centralized route name constants
 │   │   ├─ custom_router.dart      # Router combining all modular routes
 │   │   └─ navigation_controller.dart # Contextless navigation helper
 │   ├─ network/
 │   │   ├─ http_client.dart        # Interface class IHttpClient
 │   │   ├─ http_response.dart      # Generic HttpResponse<T> wrapper
 │   │   ├─ http_network_exception.dart # Typed network exceptions & error enums
 │   │   ├─ dio_http_client.dart    # Concrete IHttpClient backed by Dio
 │   │   └─ interceptors/
 │   │       ├─ auth_interceptor.dart    # Anti-loop 401 refresh interceptor
 │   │       └─ logging_interceptor.dart # Sanitized structured request/response logger
 │   ├─ theme/
 │   │   ├─ app_colors.dart         # Centralized palette & ColorScheme
 │   │   ├─ app_text.dart           # Typography scale
 │   │   └─ app_theme.dart          # Centralized ThemeData (Light & Dark)
 │   └─ utils/
 │       ├─ app_logger.dart         # Lightweight logging wrapper
 │       └─ custom_snack.dart       # Contextless global snackbar notifications
 │
 ├─ shared/                         # Reusable widgets and UI components across features
 │    ├─ widgets/
 │    └─ helpers/
 │
 ├─ features/                       # Modular business domains
 │    └─ {feature_name}/
 │         ├─ data/
 │         │   ├─ datasources/      # Concrete data sources (pure HTTP / DB transport)
 │         │   ├─ models/           # Extension types wrapping Domain Entities
 │         │   └─ repositories/     # Concrete repository implementations
 │         ├─ domain/
 │         │   ├─ entities/         # Pure business models (no JSON logic)
 │         │   ├─ repositories/     # Abstract repository interfaces (IRepository)
 │         │   └─ usecases/         # Single-responsibility business use cases
 │         ├─ presentation/
 │         │   ├─ controllers/      # State management (Cubit / Bloc / Notifier)
 │         │   ├─ pages/            # Top-level screen widgets
 │         │   └─ widgets/          # Feature-specific private/reusable widgets
 │         ├─ {feature_name}_routes.dart       # Feature route map
 │         └─ {feature_name}_dependencies.dart # Feature DI registration
 │
 ├─ app.dart                        # MaterialApp root configuration
 └─ main.dart                       # Entry point & bootstrap
```

---

## 🧱 2. Layer Separation & Responsibilities Matrix

| Layer | Can Import | Must NEVER Import | Key Responsibilities |
| :--- | :--- | :--- | :--- |
| **Domain** | Pure Dart, Core Errors (`Either`, `Failure`) | Flutter UI, Core Network (`IHttpClient`, `Dio`), Data Layer | Pure business rules, Entities, Repository interfaces, UseCases. |
| **Data** | Domain, Core Network (`IHttpClient`, `HttpResponse`), Core Errors | Flutter UI (`package:flutter`) | DataSources (transport), Models (serialization), Repository implementations (translation, caching, mapping). |
| **Presentation** | Domain, Core UI/Theme/Navigation, State Management | Data Layer (`DataSources`, `Models`, concrete `Repositories`) | Flutter Widgets, reactive Controllers/Blocs/Cubits, user interaction. |
| **Core** | Pure Dart, Foundation packages | Feature layers (`features/*`) | Reusable infrastructure, utilities, base contracts. |

---

## 🚀 3. Core Architectural Pillars

### 3.1. Zero-Dependency Functional Error Handling (`Either<L, R>`)
Never allow unhandled exceptions or `throw` to crash the UI flow. All UseCases and Repositories return `Either<Failure, SuccessType>`.
- **Do not import third-party packages** like `dartz` or `fpdart` when simple sealed classes provide faster compile-time checks and clean pattern matching.
- **Contract:**
  ```dart
  sealed class Either<L, R> {
    const Either();
    bool get isLeft => this is Left<L, R>;
    bool get isRight => this is Right<L, R>;

    T fold<T>(T Function(L left) fnL, T Function(R right) fnR);
  }

  class Left<L, R> extends Either<L, R> {
    final L value;
    const Left(this.value);
    @override
    T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnL(value);
  }

  class Right<L, R> extends Either<L, R> {
    final R value;
    const Right(this.value);
    @override
    T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnR(value);
  }
  ```

---

### 3.2. Models as Dart 3.3+ Extension Types
Stop writing redundant duplicate classes or boilerplates for `Model` vs `Entity`.
- **Entity**: Resides in `domain/entities/`. Contains zero JSON logic. Pure immutable class.
- **Model**: Resides in `data/models/`. Defined as an **Extension Type** wrapping and implementing the Entity.
- **Benefits**: Zero memory overhead, zero runtime cost, compile-time polymorphism, keeps domain completely decoupled from serialization.

```dart
// domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String name;
  final String email;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
  });
}

// data/models/user_model.dart
import '../../domain/entities/user_entity.dart';

extension type UserModel(UserEntity entity) implements UserEntity {
  factory UserModel.fromEntity(UserEntity entity) => UserModel(entity);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      UserEntity(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

---

### 3.3. Strict Separation: DataSource vs RepositoryImpl

```
[ Presentation / Controller ]
             │
             ▼ calls UseCase
      [ Domain: UseCase ]
             │
             ▼ calls IRepository contract
   [ Data: RepositoryImpl ] ─── converts Entity <-> Model (Extension Type)
             │              ─── catches HttpNetworkException -> maps to Failure
             │              ─── manages caching / fallback / retry
             ▼ calls DataSource with raw Map/primitives
    [ Data: DataSource ]   ─── strictly concrete (no abstract interface needed)
             │              ─── NO try/catch (let exceptions bubble)
             │              ─── returns generic HttpResponse<dynamic>
             ▼
     [ Core: IHttpClient ]
```

#### 🛡️ DataSource Rules:
1. **Concrete class only**: No abstract interface required; decoupling is guaranteed by `IHttpClient`.
2. **Raw parameters**: Only receives primitive types (`String id`, `Map<String, dynamic> payload`, `Map<String, dynamic> queryParams`).
3. **Raw response**: Strictly returns `HttpResponse<dynamic>` from `IHttpClient`.
4. **No serialization**: Never instantiates Models or Entities.
5. **No `try/catch`**: Lets all network exceptions bubble up to the Repository.

```dart
class UserDatasource {
  final IHttpClient _client;
  UserDatasource(this._client);

  Future<HttpResponse<dynamic>> getProfile(String userId) {
    return _client.get('/users/$userId');
  }

  Future<HttpResponse<dynamic>> updateProfile(String userId, Map<String, dynamic> data) {
    return _client.put('/users/$userId', data: data);
  }
}
```

#### 🏛️ RepositoryImpl Rules:
1. Implements domain repository contract (`implements IUserRepository`).
2. Receives domain entities or value objects from UseCases.
3. Converts domain entities to payload maps via `Model.toJson()`.
4. Catches `HttpNetworkException` and maps them into domain-safe `Failure` subclasses (`UnauthorizedFailure`, `ServerFailure`, `ConnectionFailure`).
5. Deserializes `response.data` via `Model.fromJson(...)`.
6. Returns `Either<Failure, T>`.

```dart
class UserRepository implements IUserRepository {
  final UserDatasource _datasource;
  UserRepository(this._datasource);

  @override
  Future<Either<Failure, UserEntity>> getProfile(String id) async {
    try {
      final response = await _datasource.getProfile(id);
      final raw = response.data;
      if (raw is! Map) {
        return const Left(ServerFailure(message: 'Invalid server response structure'));
      }
      final model = UserModel.fromJson(Map<String, dynamic>.from(raw));
      return Right(model);
    } on HttpNetworkException catch (e) {
      if (e.isUnauthorized) return Left(UnauthorizedFailure(message: e.message));
      if (e.isConnectionError) return Left(ConnectionFailure(message: e.message));
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e, st) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: st));
    }
  }
}
```

---

### 3.4. Decoupled Network Layer & Resilient Auth Interceptor

#### Decoupled Contract (`IHttpClient`)
Never pass `Dio` directly to DataSources. All network operations must pass through `IHttpClient`.

#### Preventing Infinite 401 Refresh Loops (`AuthInterceptor`)
A critical bug in typical Flutter code: when a request fails with `401 Unauthorized`, the interceptor calls `/auth/refresh` on the same client, which fails with 401, triggering infinite recursion.

**The Solution:**
1. **Isolated `cleanDio`**: An independent Dio instance without interceptors used solely for calling the refresh endpoint and re-fetching the original request.
2. **Concurrency Lock (`Completer<bool>`)**: When multiple concurrent requests fail with 401 simultaneously, only the first request performs the token renewal. All subsequent requests await that single `Completer`.
3. **Bail-out condition**: If the failing request is already a retry or is an auth endpoint (`/login`, `/refresh`), abort immediately and forward the error.

---

### 3.5. Dependency Injection (DI) & Service Locator Pattern

- **Abstract Injector (`AppInjector`)**: Allows swapping underlying containers (e.g. `get_it`, `auto_injector`) without modifying feature modules.
- **Singleton Service Locator**: `locator.get<T>()` used throughout the app.
- **Feature Encapsulation**: Each feature has `{FeatureName}Dependencies.setup(injector)`.
- **Global Registration (`setDependencies`)**: Called in `main.dart` before `runApp`.

```dart
void setDependencies() {
  final injector = AutoInjectorImpl();

  // Core singletons
  injector.registerSingleton<NavigationController>(() => NavigationController());
  injector.registerSingleton<CustomSnack>(() => CustomSnack());

  // Feature dependencies
  AuthDependencies.setup(injector);
  ProfileDependencies.setup(injector);

  locator.setup(injector);
  injector.commit();
}
```

---

### 3.6. Modular Named Routes & Contextless Navigation

- Routes are organized per feature (`lib/features/{feature}/{feature}_routes.dart`).
- Route names defined in `AppPages` constants (`lib/core/navigation/app_pages.dart`).
- Centralized `CustomRouter.generateRoute` combines all feature route maps and provides a fallback `NotFoundPage`.
- **Contextless Navigation**: `NavigationController` encapsulates `GlobalKey<NavigatorState>` so navigation can occur safely without passing `BuildContext` into background services or controllers.
- **Contextless Feedback**: `CustomSnack` encapsulates `GlobalKey<ScaffoldMessengerState>`.

```dart
MaterialApp(
  navigatorKey: locator.get<NavigationController>().navigatorKey,
  scaffoldMessengerKey: locator.get<CustomSnack>().snackbarKey,
  onGenerateRoute: CustomRouter.generateRoute,
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
)
```

---

### 3.7. Presentation & State Management Guidelines

1. **Sealed State Representation**:
   Always model state hierarchies with `sealed class`:
   ```dart
   sealed class ProfileState {
     const ProfileState();
   }
   class ProfileInitial extends ProfileState { const ProfileInitial(); }
   class ProfileLoading extends ProfileState { const ProfileLoading(); }
   class ProfileSuccess extends ProfileState {
     final UserEntity user;
     const ProfileSuccess(this.user);
   }
   class ProfileError extends ProfileState {
     final String message;
     const ProfileError(this.message);
   }
   ```
2. **Compile-Time Exhaustiveness**: UI builds use `switch (state)` with no wildcard `default:` branch to guarantee all states are handled.
3. **Widget Composition**: Maximize private widgets (`class _ProfileHeader extends StatelessWidget`) instead of monster build methods or widget-returning functions (`Widget _buildHeader()`).
4. **Immutability & `const`**: Ensure every widget without mutable state uses `const` constructors to eliminate superfluous element rebuilds.
5. **Responsive & Mobile-First**:
   - Baseline: Mobile portrait layout.
   - Web/Desktop: Center content with `ConstrainedBox(constraints: BoxConstraints(maxWidth: 480))` on form and auth screens.
   - Overflow safety: Every form/page wrapped in `SingleChildScrollView` or `ListView` with touch targets $\ge 48\times48\,\text{dp}$.

---

## 🤖 4. AI Coding Agent Guardrails (Rules of Engagement)

When prompted to generate or refactor Flutter code, an AI agent complying with this specification **MUST NOT**:
1. ❌ Never put network calls or Dio code directly inside widgets or controllers.
2. ❌ Never import `package:dio` inside `features/` (only inside `lib/core/network/`).
3. ❌ Never create abstract interfaces for DataSources (only for Repositories).
4. ❌ Never do `try/catch` inside DataSources.
5. ❌ Never return `dynamic` or `Response` from Repositories; always return `Either<Failure, T>`.
6. ❌ Never instantiate Repositories directly in UI widgets; use `locator.get<T>()`.
7. ❌ Never hardcode API URLs inside classes; use `EnvironmentConfig`.
8. ❌ Never leave trailing commas unformatted or ignore line limits (80 chars target).
9. ❌ Never create infinite loops during token refreshes.
10. ❌ Never let UI catch unhandled exceptions; handle failures functionally.
