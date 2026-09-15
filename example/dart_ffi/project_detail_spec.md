# ⚡ Dart FFI (Foreign Function Interface) Specification (`dart_ffi`)

### Ultra Low-Latency In-Process C-ABI Interoperability for High-Performance Computing
*Maintainer: Gabriel Amat | Target: Dart 3.3+ / Flutter 3.19+*

---

## 🎯 Purpose & Scope

While Flutter's `MethodChannel` is the standard solution for interacting with host OS APIs (such as iOS UIKit and Android SDK), it introduces asynchronous message-passing overhead:
- Binary serialization / deserialization via `StandardMessageCodec`.
- Thread hops across the Flutter UI thread and platform background threads.
- Inability to share contiguous blocks of memory without copying buffers.

**Dart FFI (`dart:ffi`)** bypasses this entire pipeline by allowing Dart code to directly invoke compiled C-ABI functions in C, C++, Rust, Zig, or Go within the same process.

### Primary Use Cases
1. **Cryptography & Security**: In-process hashing, HMAC, elliptic curve cryptography (ECC / secp256k1), and encrypted SQLite databases (SQLCipher).
2. **Audio, Signal & Video Processing**: Real-time DSP filters, FFT transforms, and video decoding.
3. **Machine Learning & Computer Vision**: Running ONNX or custom C++ inference engines with direct pixel buffer pointers.
4. **Game Engines & Heavy Simulation**: Physics engines, collision detection, and mathematical calculations requiring maximum CPU throughput.

---

## 📁 Architecture & Directory Structure

```
example/dart_ffi/
 ├─ project_detail_spec.md             # This specification
 └─ code/
     ├─ src/                           # Native C99 source code & build configurations
     │   ├─ native_crypto.h            # C exported function prototypes & struct definitions
     │   ├─ native_crypto.c            # C implementation of hashing, heap structs & benchmarks
     │   └─ CMakeLists.txt             # Cross-platform CMake build configuration
     ├─ scripts/
     │   └─ compile_native.sh          # Quick local compilation script for macOS/Linux
     ├─ lib/
     │   ├─ ffi/
     │   │   ├─ native_types.dart      # Dart `Struct` definitions (KeyPairStruct, BenchmarkTelemetryStruct)
     │   │   └─ native_bindings.dart   # DynamicLibrary loader and lookupFunction mappings
     │   ├─ models/
     │   │   └─ crypto_models.dart     # Pure Dart immutable domain entities
     │   ├─ services/
     │   │   ├─ i_native_crypto_service.dart   # Abstract domain interface (pure Dart)
     │   │   └─ native_crypto_service_impl.dart# Concrete FFI implementation with Arenas
     │   └─ main.dart                  # Interactive Flutter UI benchmark & key generator
     └─ test/
         ├─ ffi_service_test.dart      # In-process unit tests invoking native C dylib
         └─ widget_test.dart           # UI widget test with mocked service
```

---

## ⚡ Core Rules & Best Practices

### 1. Abstract Domain Interface First (`INativeCryptoService`)
Never expose raw pointers (`Pointer<T>`) or FFI structs (`Struct`) directly to widgets, BLoCs, or Cubits.
Always wrap low-level bindings behind a pure Dart interface:

```dart
abstract interface class INativeCryptoService {
  int add(int a, int b);
  String hashString(String input);
  CryptoKeyPair generateKeyPair(String seed);
  BenchmarkResult runBenchmark({int iterations = 1000000});
}
```

This guarantees:
- **Separation of Concerns**: Presentation and business layers do not depend on `dart:ffi`.
- **Testability**: Fast unit/widget tests can inject a `MockNativeCryptoService` without compiling or linking native binaries.

---

### 2. Automatic Memory Management with Arenas (`using`)
Manual `malloc()` and `free()` easily cause memory leaks or catastrophic segmentation faults (`SIGSEGV`).
Always use the RAII pattern via `package:ffi`'s `Arena` and `using()` block:

```dart
@override
String hashString(String input) {
  // Arena automatically frees all allocated native memory upon scope exit!
  return using((Arena arena) {
    final Pointer<Utf8> inputPtr = input.toNativeUtf8(allocator: arena);
    const int bufferLen = 128;
    final Pointer<Utf8> outputPtr = arena<Uint8>(bufferLen).cast<Utf8>();

    _bindings.nativeHashString(inputPtr, outputPtr, bufferLen);

    return outputPtr.toDartString();
  });
}
```

---

### 3. Handling Native Heap Allocations (Free in `finally`)
When a C function allocates dynamic memory on the system heap using `malloc()` and returns a pointer to Dart:
- Dart garbage collection **does NOT track or free native heap memory**.
- You **MUST** provide a matching native cleanup function (`native_free_key_pair`) and call it inside a `try ... finally` block:

```dart
@override
CryptoKeyPair generateKeyPair(String seed) {
  return using((Arena arena) {
    final Pointer<Utf8> seedPtr = seed.toNativeUtf8(allocator: arena);
    final Pointer<KeyPairStruct> pairPtr = _bindings.nativeGenerateKeyPair(seedPtr);

    if (pairPtr == nullptr) {
      throw StateError('Native memory allocation failed.');
    }

    try {
      // Safely read native fields
      return CryptoKeyPair(
        publicKey: pairPtr.ref.publicKey.toDartString(),
        privateKey: pairPtr.ref.privateKey.toDartString(),
      );
    } finally {
      // Crucial: release native memory allocated by C
      _bindings.nativeFreeKeyPair(pairPtr);
    }
  });
}
```

---

### 4. Struct Mapping & Passing by Value
For small telemetry structs or mathematical coordinates, C functions can return structs **by value** directly on the stack:

#### Native C
```c
typedef struct {
    uint64_t iterations;
    double elapsed_ms;
    uint32_t checksum;
} BenchmarkTelemetry;

BenchmarkTelemetry native_run_benchmark(int32_t iterations);
```

#### Dart FFI
```dart
final class BenchmarkTelemetryStruct extends Struct {
  @Uint64()
  external int iterations;

  @Double()
  external double elapsedMs;

  @Uint32()
  external int checksum;
}

// Lookup signature
typedef _NativeBenchmarkC = BenchmarkTelemetryStruct Function(Int32 iterations);
typedef _NativeBenchmarkDart = BenchmarkTelemetryStruct Function(int iterations);
```

---

### 5. Multi-Platform DynamicLibrary Resolution
Dynamic libraries are packaged and resolved differently depending on the operating system:

```dart
static DynamicLibrary _loadLibrary() {
  if (Platform.isMacOS) {
    final localFile = File('libnative_crypto.dylib');
    if (localFile.existsSync()) return DynamicLibrary.open(localFile.absolute.path);
    try {
      return DynamicLibrary.open('libnative_crypto.dylib');
    } catch (_) {
      return DynamicLibrary.process();
    }
  } else if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libnative_crypto.so');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('native_crypto.dll');
  } else if (Platform.isIOS) {
    // Statically linked into runner executable on iOS
    return DynamicLibrary.process();
  }
  throw UnsupportedError('Unsupported OS: ${Platform.operatingSystem}');
}
```

---

## 🍏 iOS & Xcode Setup: What You Must Configure

Because iOS enforces strict sandboxing, code-signing, and forbids loading arbitrary unsigned `.dylib` binaries from custom filesystem paths at runtime, integrating native C/C++ via Dart FFI requires specific Xcode configurations.

### 1. Linking Strategies on iOS: Static vs Dynamic

| Strategy | When to Use | How Dart Loads It |
| :--- | :--- | :--- |
| **Static Linking (Recommended)** | Custom C/C++ files or Flutter FFI plugins | `DynamicLibrary.process()` |
| **Dynamic Framework (`.xcframework`)** | Precompiled third-party vendor SDKs | `DynamicLibrary.open('FrameworkName.framework/FrameworkName')` |

---

### 2. Method A: Adding C/C++ Directly to the Xcode Project

If you are developing custom C code inside your Flutter application:
1. Open `ios/Runner.xcworkspace` in **Xcode**.
2. In the Project Navigator, right-click `Runner` and select **Add Files to "Runner"...**.
3. Select your C source files (`native_crypto.c` and `native_crypto.h`).
4. **Crucial Settings in the Dialog**:
   * ✅ **Destination**: Check *"Copy items if needed"*.
   * ✅ **Added folders**: Select *"Create groups"*.
   * ✅ **Add to targets**: Check **`Runner`**.
5. Verify in **Xcode -> Target "Runner" -> Build Phases -> Compile Sources** that `native_crypto.c` is listed.

---

### 3. Method B: Integrating via CocoaPods (`.podspec`) in Plugins (Legacy / Dual Mode)

If creating a reusable Flutter plugin / FFI package supporting CocoaPods:
1. Add the C source files inside the plugin's `ios/Classes/` or `src/` directory.
2. In your plugin's `ios/<plugin_name>.podspec`, specify the source files:
   ```ruby
   Pod::Spec.new do |s|
     s.name             = 'native_crypto'
     s.version          = '1.0.0'
     s.summary          = 'Native C Crypto Engine for Flutter'
     s.source_files     = 'Classes/**/*', 'src/**/*.{c,h}'
     s.public_header_files = 'Classes/**/*.h', 'src/**/*.h'
     s.dependency 'Flutter'
     s.platform = :ios, '12.0'
     s.pod_target_xcconfig = {
       'DEFINES_MODULE' => 'YES',
       'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
     }
   end
   ```
3. Run `pod install` in your `example/ios` directory. CocoaPods automatically configures the Xcode compile targets.

---

### 4. Method C: Modern Swift Package Manager (SPM - Pure Xcode, Zero CocoaPods)

Modern Flutter applications (Flutter 3.24+ / Xcode 16+) and enterprise iOS teams are rapidly deprecating CocoaPods in favor of Apple's native **Swift Package Manager (SPM)** (`flutter config --enable-swift-package-manager`). In this setup, there is **no `Podfile`**, **no `Podfile.lock`**, and **no `Pods/` directory**.

#### Step 1: Define `Package.swift` for the Native C/C++ Engine
At the root of your native C module (or Flutter plugin `ios/`), create a `Package.swift` declaring a C target:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "native_crypto",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "native_crypto",
            targets: ["native_crypto"]
        ),
    ],
    targets: [
        .target(
            name: "native_crypto",
            path: "src",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        ),
    ]
)
```

> [!NOTE]
> For SPM C targets, `publicHeadersPath` specifies where the exposed `.h` headers reside (e.g. `.` or `include/`). SPM compiles every `.c` file found under `path` into a static library product without needing Ruby or CocoaPods.

#### Step 2: Add the Package Dependency in Xcode
There are two ways to connect your SPM package to your Flutter Runner:

**Option 1: Add as Local Package Dependency (Direct App)**
1. Open `ios/Runner.xcodeproj` in **Xcode** (no `.xcworkspace` required when CocoaPods is removed).
2. Go to **File -> Add Package Dependencies...**.
3. Click **Add Local...** in the bottom-left corner and select your native package directory containing `Package.swift`.
4. In the target dialog, select **Add to Target: Runner**.
5. Verify in **Target "Runner" -> General -> Frameworks, Libraries, and Embedded Content** that `native_crypto` is present.

**Option 2: Flutter SPM Plugin Auto-Discovery (Flutter 3.24+)**
* When developing an FFI plugin, Flutter’s tooling automatically generates `FlutterGeneratedPluginSwiftPackage` during `flutter build ios` or `flutter run`.
* If your plugin contains a valid `Package.swift`, Flutter registers it directly into Xcode's SPM dependency tree without touching CocoaPods.

#### Step 3: Loading in Dart
Because SPM compiles the target as part of the app link phase:
```dart
// SPM static libraries are linked directly into the host process
final DynamicLibrary dylib = DynamicLibrary.process();
```

---

### 5. ⚠️ The Critical iOS Gotcha: Dead Code Stripping

In **Release builds**, Xcode's Clang optimizer performs aggressive **Dead Code Stripping** (`DEAD_CODE_STRIPPING = YES`).

Because Dart calls native C functions at runtime via `DynamicLibrary.process().lookup('native_add')`, the Xcode linker sees **no references to `native_add` from Swift or Objective-C**. As a result, the linker strips the function from the release binary, resulting in:
```
ArgumentError: Failed to lookup symbol (dlsym(RTLD_DEFAULT, native_add): symbol not found)
```

#### How to Prevent Dead Code Stripping (Choose one):

* **Approach 1: Compiler Attributes (Best Practice)**:
  Annotate every exported C function in your `.h` header with `__attribute__((used))` in addition to visibility default:
  ```c
  #if defined(_WIN32)
    #define FFI_EXPORT __declspec(dllexport)
  #else
    #define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
  #endif

  FFI_EXPORT int32_t native_add(int32_t a, int32_t b);
  ```
  The `__attribute__((used))` instructs Clang to never discard this symbol, even if it appears uncalled at compile time.

* **Approach 2: Xcode Build Settings (Exported Symbols List)**:
  * In Xcode, select **Target "Runner" -> Build Settings -> Other Linker Flags**.
  * Add the flag: `-Wl,-exported_symbol,_native_add` (Note the leading underscore for C symbols on Darwin).

* **Approach 3: Dummy Native Reference in `AppDelegate.swift`**:
  Add an explicit call in `AppDelegate.swift` to force the linker to preserve the symbol table:
  ```swift
  import Flutter
  import UIKit

  @main
  @objc class AppDelegate: FlutterAppDelegate {
    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      // Dummy call forcing Xcode linker to retain native C symbols in release builds
      _ = native_add(0, 0)

      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
  }
  ```

---

### 6. Using Precompiled `.xcframework` (Dynamic Linking)

If consuming a vendor precompiled binary:
1. Drag the `.xcframework` into **Xcode -> Target "Runner" -> General -> Frameworks, Libraries, and Embedded Content**.
2. Set the embed option to **Embed & Sign**.
3. In Dart, load the framework using:
   ```dart
   final dylib = DynamicLibrary.open('NativeCrypto.framework/NativeCrypto');
   ```

---

## ⚖️ Architectural Decision Matrix: FFI vs MethodChannel

| Dimension | `MethodChannel` | `Dart FFI` |
| :--- | :--- | :--- |
| **Language Target** | Kotlin, Java, Swift, Objective-C | C, C++, Rust, Zig, Go |
| **Execution Model** | Asynchronous (Message passing) | Synchronous / In-Process Call |
| **Data Marshalling** | Binary serialized (`StandardMessageCodec`) | Zero-copy direct memory pointers |
| **Latency** | Medium (~0.1ms to 2ms per call) | Nanoseconds (~15ns per call) |
| **Threading** | Runs on Platform UI/Background threads | Runs directly on Dart isolate |
| **Memory Risk** | Memory managed by Dart & JVM/ARC | **High** (Segfault if pointers misused) |
| **Best Used For** | OS APIs: Biometrics, GPS, Apple Pay, Bluetooth | High-throughput math, crypto, audio, 3D graphics |
