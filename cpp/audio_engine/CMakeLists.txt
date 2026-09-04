# cpp/audio_engine/CMakeLists.txt
# Aura — C++ audio engine shared library.
#
# Consumed by android/app/CMakeLists.txt (NDK) and buildable standalone on a
# host machine for the DSP test suite:
#
#   cmake -S cpp/audio_engine -B build -DAURA_BUILD_TESTS=ON -G Ninja
#   ninja -C build && ./build/aura_engine_tests

cmake_minimum_required(VERSION 3.16)
project(aura_engine VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(AURA_WITH_FFMPEG "Build the FFmpeg decoder backend" OFF)
option(AURA_BUILD_TESTS "Build the host test runner" OFF)

# Release builds get -O3 per the spec; debug keeps symbols.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
endif()
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

set(AURA_SOURCES
    audio_engine.cpp
    dsp/equalizer.cpp
    dsp/replay_gain.cpp
    dsp/crossfade.cpp
    decoder/decoder.cpp
    decoder/ffmpeg_decoder.cpp
    analyzer/feature_extractor.cpp
    analyzer/fingerprint.cpp
)

add_library(aura_engine SHARED ${AURA_SOURCES})

target_include_directories(aura_engine PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# ── Optional FFmpeg backend ───────────────────────────────────────────────────
if(AURA_WITH_FFMPEG)
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
        pkg_check_modules(FFMPEG IMPORTED_TARGET
            libavcodec libavformat libavutil libswresample)
    endif()

    if(FFMPEG_FOUND)
        target_compile_definitions(aura_engine PRIVATE AURA_WITH_FFMPEG)
        target_link_libraries(aura_engine PRIVATE PkgConfig::FFMPEG)
        message(STATUS "Aura: FFmpeg decoder ENABLED")
    else()
        message(WARNING
            "Aura: AURA_WITH_FFMPEG=ON but FFmpeg was not found; "
            "falling back to the miniaudio decoder only.")
    endif()
else()
    message(STATUS "Aura: FFmpeg decoder disabled (miniaudio only)")
endif()

# ── Platform libraries ────────────────────────────────────────────────────────
if(ANDROID)
    # miniaudio uses AAudio/OpenSL ES on Android.
    target_link_libraries(aura_engine PRIVATE log OpenSLES android)
elseif(APPLE)
    find_library(COREAUDIO CoreAudio)
    find_library(COREFOUNDATION CoreFoundation)
    find_library(AUDIOTOOLBOX AudioToolbox)
    target_link_libraries(aura_engine PRIVATE
        ${COREAUDIO} ${COREFOUNDATION} ${AUDIOTOOLBOX})
elseif(UNIX)
    find_package(Threads REQUIRED)
    target_link_libraries(aura_engine PRIVATE Threads::Threads ${CMAKE_DL_LIBS} m)
endif()

# ── Tests (host only) ─────────────────────────────────────────────────────────
if(AURA_BUILD_TESTS)
    add_executable(aura_engine_tests tests/test_main.cpp)
    target_link_libraries(aura_engine_tests PRIVATE aura_engine)
    target_include_directories(aura_engine_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
    enable_testing()
    add_test(NAME aura_engine_tests COMMAND aura_engine_tests)
endif()
