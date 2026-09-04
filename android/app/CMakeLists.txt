# android/app/CMakeLists.txt
# Aura — Android NDK entry point.
#
# The engine itself lives in cpp/audio_engine/ and is shared with iOS and the
# host test build; this file just pulls it into the Gradle NDK build.

cmake_minimum_required(VERSION 3.16)

project(aura_android)

# Builds the `aura_engine` shared library target.
add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../cpp/audio_engine
    ${CMAKE_CURRENT_BINARY_DIR}/aura_engine
)
