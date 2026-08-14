cmake_minimum_required(VERSION 3.10.2)

project(aura_engine)

# Add miniaudio include directory
include_directories(../../native/include)

# Build the shared library
add_library(aura_engine SHARED
    ../../native/src/audio_engine.cpp
)

# Link against Android NDK libraries
target_link_libraries(aura_engine
    log
)
