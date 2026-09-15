#include "native_crypto.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

FFI_EXPORT int32_t native_add(int32_t a, int32_t b) {
    return a + b;
}

FFI_EXPORT void native_hash_string(const char* input, char* output_buffer, int32_t max_buffer_len) {
    if (input == NULL || output_buffer == NULL || max_buffer_len < 65) {
        return;
    }

    // FNV-1a 64-bit hash algorithm duplicated to produce a 64-character mock SHA-256 hex string
    uint64_t hash1 = 14695981039346656037ULL;
    uint64_t hash2 = 1099511628211ULL;

    const unsigned char* p = (const unsigned char*)input;
    while (*p) {
        hash1 ^= (uint64_t)(*p);
        hash1 *= 1099511628211ULL;

        hash2 ^= (uint64_t)(*p);
        hash2 *= 14695981039346656037ULL;
        p++;
    }

    snprintf(output_buffer, max_buffer_len, "%016llx%016llx%016llx%016llx", 
             (unsigned long long)hash1, 
             (unsigned long long)hash2, 
             (unsigned long long)(hash1 ^ hash2), 
             (unsigned long long)(hash1 + hash2));
}

FFI_EXPORT KeyPair* native_generate_key_pair(const char* seed) {
    KeyPair* pair = (KeyPair*)malloc(sizeof(KeyPair));
    if (pair == NULL) {
        return NULL;
    }

    size_t key_len = 128;
    pair->public_key = (char*)malloc(key_len);
    pair->private_key = (char*)malloc(key_len);

    if (pair->public_key == NULL || pair->private_key == NULL) {
        if (pair->public_key) free(pair->public_key);
        if (pair->private_key) free(pair->private_key);
        free(pair);
        return NULL;
    }

    const char* safe_seed = (seed != NULL) ? seed : "default_seed";
    snprintf(pair->public_key, key_len, "pub_secp256k1_%s_f7a8b9c0", safe_seed);
    snprintf(pair->private_key, key_len, "priv_secp256k1_%s_1a2b3c4d_secret", safe_seed);

    return pair;
}

FFI_EXPORT void native_free_key_pair(KeyPair* pair) {
    if (pair != NULL) {
        if (pair->public_key != NULL) {
            free(pair->public_key);
            pair->public_key = NULL;
        }
        if (pair->private_key != NULL) {
            free(pair->private_key);
            pair->private_key = NULL;
        }
        free(pair);
    }
}

FFI_EXPORT BenchmarkTelemetry native_run_benchmark(int32_t iterations) {
    clock_t start = clock();

    uint32_t checksum = 0;
    for (int32_t i = 0; i < iterations; i++) {
        // High-density bit manipulation loop
        checksum = (checksum ^ (uint32_t)i) * 1664525u + 1013904223u;
        checksum ^= (checksum >> 16);
    }

    clock_t end = clock();
    double elapsed_ms = ((double)(end - start) / CLOCKS_PER_SEC) * 1000.0;

    BenchmarkTelemetry telemetry;
    telemetry.iterations = (uint64_t)iterations;
    telemetry.elapsed_ms = elapsed_ms;
    telemetry.checksum = checksum;

    return telemetry;
}
