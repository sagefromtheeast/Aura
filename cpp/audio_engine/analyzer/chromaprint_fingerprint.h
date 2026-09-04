/**
 * chromaprint_fingerprint.h
 * Aura — Chromaprint acoustic fingerprinting for duplicate detection.
 *
 * Wraps the vendored Chromaprint core (third_party/chromaprint, MIT + KissFFT
 * BSD-3) behind a small, allocation-free-at-the-boundary C++ surface.
 *
 * Aura vendors Chromaprint WITHOUT its internal avresample copy, because that
 * file is LGPL FFmpeg code. AudioProcessor therefore cannot resample, so every
 * entry point here decodes to exactly [kChromaprintSampleRate] mono up front
 * and feeds chromaprint at its native rate.
 *
 * Output is a raw sub-fingerprint array (one uint32 per ~0.124 s frame) — the
 * same shape the old MurmurHash fingerprint produced, so the FFI signature and
 * the Dart bindings are unchanged. Unlike that hash, two encodes of the same
 * recording now produce *similar* values, which is what makes bit-error-rate
 * comparison meaningful.
 */

#pragma once

#include <cstddef>
#include <cstdint>

namespace aura {

/// Chromaprint's fixed internal rate. Audio must be resampled to this before
/// being fed in (see the note above about avresample).
inline constexpr int kChromaprintSampleRate = 11025;

/// Seconds of audio fingerprinted. Chromaprint's own default is 120; 30 is
/// plenty to identify a duplicate and keeps a full-library scan affordable.
inline constexpr int kChromaprintSeconds = 30;

class ChromaprintFingerprint {
public:
    /// Fingerprints mono 16-bit PCM sampled at [kChromaprintSampleRate].
    /// Writes at most [capacity] sub-fingerprints into [out]; returns how many
    /// were written, or 0 on failure (too little audio, allocation failure).
    static int compute(const int16_t* mono,
                       std::size_t frameCount,
                       int sampleRate,
                       uint32_t* out,
                       int capacity);

    /// Decodes [path] and fingerprints it.
    /// On entry *[inOutSize] is the capacity of [out]; on success it is set to
    /// the number of values written.
    /// Returns 0 on success, -1 on bad args, -2 when the file cannot be read
    /// or is too short to fingerprint.
    static int computeFromFile(const char* path, uint32_t* out, int* inOutSize);

    /// Bit error rate between two raw fingerprints: the fraction of differing
    /// bits over the overlapping prefix, in [0, 1]. Returns 1.0 (maximally
    /// different) when either side is empty.
    ///
    /// Identical encodes score ~0.0; unrelated tracks hover near 0.5, since
    /// independent bits disagree half the time. Aura treats < 0.35 as a match.
    static double bitErrorRate(const uint32_t* a, std::size_t aLen,
                               const uint32_t* b, std::size_t bLen);
};

}  // namespace aura
