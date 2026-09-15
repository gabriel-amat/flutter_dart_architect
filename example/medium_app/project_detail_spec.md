# 🟡 Medium App Tier Specification (`medium_app`)

### Full Feature-Driven Clean Architecture for Production SaaS & Mobile Apps
*Maintainer: Gabriel Amat | Target: Dart 3.3+ / Flutter 3.19+*

---

## 🎯 Purpose & Scope

The **Medium App** tier is the baseline for production Flutter applications developed by small-to-medium teams (3 to 15 developers):
- Scalable from 5 to 50+ screens.
- Strong boundaries between layers (`Domain`, `Data`, `Presentation`).
- 100% decoupled from third-party network and functional libraries.
- Ready for test automation (Unit, Widget, and Integration tests).

---

## 🏛️ Directory Structure

```
lib/
 ├─ core/                           # Cross-cutting foundational modules
 │   ├─ di/                         # AppInjector & ServiceLocator
 │   ├─ error/                      # Native Either<L, R>, Failure, Exceptions
 │   ├─ navigation/                 # AppPages, CustomRouter, NavigationController
 │   ├─ network/                    # IHttpClient, HttpResponse, DioHttpClient, AuthInterceptor
 │   ├─ theme/                      # Centralized AppTheme (Light & Dark)
 │   └─ utils/                      # CustomSnack, AppLogger
 ├─ shared/                         # Reusable widgets and design helpers
 ├─ features/                       # Modular business domains
 │    └─ {feature_name}/
 │         ├─ data/
 │         │   ├─ datasources/      # Concrete HTTP/DB transport (returns HttpResponse)
 │         │   ├─ models/           # Dart 3.3+ Extension Types wrapping Entities
 │         │   └─ repositories/     # Implements IRepository, catches HttpNetworkException
 │         ├─ domain/
 │         │   ├─ entities/         # Pure Dart immutable models (no JSON logic)
 │         │   ├─ repositories/     # Abstract interface (IRepository)
 │         │   └─ usecases/         # Single-responsibility business actions
 │         ├─ presentation/
 │         │   ├─ controllers/      # Sealed state + ValueNotifier/Cubit (split via part/part of)
 │         │   ├─ pages/            # Screen widgets with responsive constraints
 │         │   └─ widgets/          # Private focused widgets
 │         ├─ {feature}_routes.dart       # Modular route definitions
 │         └─ {feature}_dependencies.dart # Feature DI registration function
 ├─ app.dart                        # MaterialApp configuration
 └─ main.dart                       # App initialization & entry point
```

---

## ⚡ The Key Architectural Pillars

1. **Models as Dart 3.3+ Extension Types**:
   - `extension type UserModel(UserEntity entity) implements UserEntity`.
   - Keeps Domain Entities completely pure while encapsulating `fromJson` and `toJson` in the Data layer with zero runtime overhead.
2. **Decoupled Network & Anti-Loop 401**:
   - DataSources depend exclusively on `IHttpClient`.
   - Token renewal on 401 uses an isolated `cleanDio` (without interceptors) and a `Completer<bool>` concurrency lock to prevent recursive refresh loops.
3. **Zero-Dependency Functional Error Handling**:
   - Native sealed `Either<Failure, T>` with `.fold(left, right)`. No need for `dartz` or `fpdart`.
4. **Contextless Navigation & Feedback**:
   - `NavigationController` and `CustomSnack` allow navigating and showing feedback without passing `BuildContext` into background services or controllers.
5. **Sealed States with `part` / `part of`**:
   - Controllers and States are split into `{feature}_controller.dart` and `{feature}_state.dart` using Dart's `part` directive.

---

## 🤖 AI Coding Assistant Guidelines (Medium Tier)

When generating features for this tier, the AI must:
- Create separate folders: `domain/`, `data/`, and `presentation/`.
- Never import `Dio` inside `features/`.
- Never put `try/catch` inside DataSources (let exceptions bubble to Repositories).
- Always return `Either<Failure, Entity>` from UseCases and Repositories.
- Separate controllers and states using `part` / `part of`.
