/**
 * fingerprint.h
 * Aura — Acoustic fingerprinting for duplicate detection.
 *
 * Produces a sequence of 32-bit sub-fingerprints, one per short window, so two
 * encodes of the same recording share most of their values even when the files
 * differ. Chromaprint-compatible output is a future upgrade; this keeps the
 * same shape (uint32 array) so the API does not change when it lands.
 */

#pragma once

#include <cstddef>
#include <cstdint>

namespace aura {

/// Sample rate used for fingerprinting (mono).
inline constexpr int kFingerprintSampleRate = 16000;

/// Seconds of audio fingerprinted.
inline constexpr int kFingerprintSeconds = 30;

/// Window length in ms for each sub-fingerprint.
inline constexpr int kFingerprintWindowMs = 500;

class Fingerprint {
public:
    /// MurmurHash3 x86 32-bit. Exposed for tests and reuse.
    static uint32_t murmur3_32(const uint8_t* data, std::size_t len, uint32_t seed);

    /// Computes windowed sub-fingerprints from mono 16-bit PCM.
    /// Writes at most [capacity] values into [out]; returns how many were written.
    static int compute(const int16_t* mono,
                       std::size_t frameCount,
                       int sampleRate,
                       uint32_t* out,
                       int capacity);

    /// Decodes [path] and fingerprints it.
    /// On entry *[inOutSize] is the capacity of [out]; on success it is set to
    /// the number of values written.
    /// Returns 0 on success, -1 on bad args, -2 when the file cannot be read.
    static int computeFromFile(const char* path, uint32_t* out, int* inOutSize);
};

}  // namespace aura
