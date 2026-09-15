# 📦 Package-Oriented Architecture Specification (`package_oriented`)

### Multi-Package Monorepo Architecture with Melos for Scaled Engineering Teams
*Maintainer: Gabriel Amat | Target: Dart 3.3+ / Flutter 3.19+*

---

## 🎯 Purpose & Scope

When multiple engineering squads (e.g., 20+ developers) work in the same mobile repository:
- A single Flutter package suffers from merge conflicts and accidental tight coupling.
- Developers accidentally import private data from other features.
- CI/CD build times explode because the entire app is retested on every commit.

The **Package-Oriented** architecture solves this by slicing the codebase into **autonomous, compile-independent Dart & Flutter packages** orchestrated by **Melos**.

---

## 🏛️ Monorepo Directory Structure

```
my_organization_repo/
 ├─ melos.yaml                      # Melos monorepo configuration
 ├─ pubspec.yaml                    # Root workspace declaration
 ├─ apps/
 │   ├─ customer_app/               # Main client application shell (assembles packages)
 │   └─ partner_app/                # Secondary app sharing core & design system
 └─ packages/
     ├─ core/
     │   ├─ core_network/           # IHttpClient, Dio implementation, AuthInterceptor
     │   ├─ core_error/             # Either, Failure, Exceptions
     │   └─ core_storage/           # Encrypted storage & session manager
     ├─ design_system/              # Design tokens, color palette, atomic UI components
     └─ features/
         ├─ feature_auth/           # Autonomous authentication package
         ├─ feature_transfers/      # Autonomous transfers & payments package
         └─ feature_cards/          # Autonomous cards & limits package
```

---

## 🛡️ The Golden Boundary Rules

1. **Features NEVER import sibling Features**:
   - `feature_transfers` CANNOT declare a dependency on `feature_cards`.
   - If a transfer requires card data, communication happens via abstract domain contracts or deep link routing provided by `apps/customer_app`.
2. **Design System is Pure Presentation**:
   - The `design_system` package contains zero business logic or network calls.
3. **Core is Zero-UI**:
   - `core_network` and `core_storage` do not depend on `package:flutter/material.dart`.
4. **Independent CI/CD Caching**:
   - Using Melos filters (`melos exec --diff=origin/main`), CI only tests and analyzes packages that have actual Git diffs.

---

## ⚡ Melos Configuration (`melos.yaml`)

```yaml
name: enterprise_flutter_monorepo
packages:
  - "apps/*"
  - "packages/**"

scripts:
  bootstrap:
    run: melos bootstrap
    description: Link all internal packages together.

  analyze:
    run: melos exec -- flutter analyze .
    description: Run static analysis on all packages.

  test:changed:
    run: melos exec --diff=origin/main -- "flutter test"
    description: Run tests only on packages modified in the current branch.
```
