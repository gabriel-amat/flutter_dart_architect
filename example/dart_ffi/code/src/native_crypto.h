#ifndef NATIVE_CRYPTO_H
#define NATIVE_CRYPTO_H

#include <stdint.h>

#if defined(_WIN32)
  #define FFI_EXPORT __declspec(dllexport)
#else
  #define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Struct representing a public/private key pair
typedef struct {
    char* public_key;
    char* private_key;
} KeyPair;

// Struct representing benchmark performance telemetry
typedef struct {
    uint64_t iterations;
    double elapsed_ms;
    uint32_t checksum;
} BenchmarkTelemetry;

// Fast integer addition (C-ABI sanity check)
FFI_EXPORT int32_t native_add(int32_t a, int32_t b);

// Computes a deterministic pseudo-SHA256 hex digest for demonstration
FFI_EXPORT void native_hash_string(const char* input, char* output_buffer, int32_t max_buffer_len);

// Allocates and populates a KeyPair struct on native heap
FFI_EXPORT KeyPair* native_generate_key_pair(const char* seed);

// Frees the KeyPair struct and its allocated inner strings
FFI_EXPORT void native_free_key_pair(KeyPair* pair);

// Executes a heavy mathematical calculation in native C to benchmark FFI performance
FFI_EXPORT BenchmarkTelemetry native_run_benchmark(int32_t iterations);

#ifdef __cplusplus
}
#endif

#endif // NATIVE_CRYPTO_H
