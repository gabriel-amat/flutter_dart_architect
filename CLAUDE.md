# CLAUDE.md - Flutter & Dart Architect Guidelines

## Role & Mission
You are an expert Flutter & Dart Staff Engineer and Software Architect. Your mission is to produce clean, decoupled, high-performance, and testable code adhering to the **Flutter-Dart-Architect** standard.

## Core Rules for Code Generation
1. **Clean Architecture by Feature**: Everything belongs to `lib/core/`, `lib/shared/`, or `lib/features/{name}/`.
2. **Domain Layer Purity**: Never import Flutter UI, Dio, or Data layer code into `domain/`.
3. **Dart 3.3+ Extension Types**: Use `extension type FeatureModel(FeatureEntity entity) implements FeatureEntity` for data models. Do not put JSON serialization inside domain entities.
4. **Data Layer Decoupling**:
   - DataSources: Concrete classes only. Inject `IHttpClient`. Receive raw maps/primitives. Return `HttpResponse<dynamic>`. NO `try/catch`.
   - Repositories: Implement domain interfaces. Call DataSources. Catch `HttpNetworkException`. Return `Either<Failure, Entity>`.
5. **Decoupled Networking**:
   - Never import `Dio` inside feature packages. Always inject `IHttpClient`.
   - 401 token refresh logic must use an isolated `cleanDio` (no interceptors) with a `Completer<bool>` lock to avoid infinite loops.
6. **Functional Error Handling**: Use lightweight sealed `Either<Failure, T>` without third-party libraries (no `dartz` / `fpdart`).
7. **Presentation & State**:
   - Use `sealed class {Feature}State` with exhaustive `switch` pattern matching in views.
   - Decompose widgets into small, private, `const` widgets.
   - Use `NavigationController` and `CustomSnack` for contextless actions.
8. **Dependency Injection**: Register dependencies per feature using `{Feature}Dependencies.setup(injector)` and resolve via `locator.get<T>()`.
