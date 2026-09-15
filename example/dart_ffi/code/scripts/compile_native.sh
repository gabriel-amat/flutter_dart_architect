#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "🔨 Compiling native C crypto library..."

case "$(uname -s)" in
    Darwin*)
        clang -shared -fPIC -O3 src/native_crypto.c -o libnative_crypto.dylib
        echo "✅ Generated libnative_crypto.dylib for macOS"
        ;;
    Linux*)
        gcc -shared -fPIC -O3 src/native_crypto.c -o libnative_crypto.so
        echo "✅ Generated libnative_crypto.so for Linux"
        ;;
    *)
        echo "⚠️ Unsupported host OS for fast script. Use CMake or standard compiler."
        ;;
esac
