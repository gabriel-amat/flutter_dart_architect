cmake_minimum_required(VERSION 3.10)
project(native_crypto LANGUAGES C)

add_library(native_crypto SHARED
  native_crypto.c
)

set_target_properties(native_crypto PROPERTIES
  PUBLIC_HEADER native_crypto.h
  OUTPUT_NAME "native_crypto"
)

target_include_directories(native_crypto PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)
