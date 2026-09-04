/**
 * chromaprint_fingerprint.cpp
 * Aura — Chromaprint acoustic fingerprinting.
 */

#include "chromaprint_fingerprint.h"

#include <algorithm>
#include <vector>

#include "../decoder/decoder.h"
#include "chromaprint.h"

namespace aura {
namespace {

/// Frees a ChromaprintContext even if we return early.
struct ContextGuard {
    explicit ContextGuard(ChromaprintContext* c) : ctx(c) {}
    ~ContextGuard() {
        if (ctx != nullptr) chromaprint_free(ctx);
    }
    ContextGuard(const ContextGuard&) = delete;
    ContextGuard& operator=(const ContextGuard&) = delete;
    ChromaprintContext* ctx;
};

/// Same for the fingerprint buffer chromaprint allocates for us.
struct RawGuard {
    ~RawGuard() {
        if (data != nullptr) chromaprint_dealloc(data);
    }
    uint32_t* data = nullptr;
};

inline int popcount32(uint32_t v) {
    // Portable SWAR popcount — __builtin_popcount is not available on MSVC and
    // std::popcount needs C++20, while the engine targets C++17.
    v = v - ((v >> 1) & 0x55555555u);
    v = (v & 0x33333333u) + ((v >> 2) & 0x33333333u);
    v = (v + (v >> 4)) & 0x0F0F0F0Fu;
    return static_cast<int>((v * 0x01010101u) >> 24);
}

}  // namespace

int ChromaprintFingerprint::compute(const int16_t* mono,
                                    std::size_t frameCount,
                                    int sampleRate,
                                    uint32_t* out,
                                    int capacity) {
    if (mono == nullptr || out == nullptr || capacity <= 0) return 0;
    if (frameCount == 0) return 0;

    // Without the LGPL avresample copy, chromaprint cannot resample; callers
    // must hand us audio already at the native rate.
    if (sampleRate != kChromaprintSampleRate) return 0;

    ContextGuard guard(chromaprint_new(CHROMAPRINT_ALGORITHM_DEFAULT));
    if (guard.ctx == nullptr) return 0;

    if (chromaprint_start(guard.ctx, kChromaprintSampleRate, 1) != 1) return 0;

    // chromaprint_feed takes an int sample count, so feed in bounded chunks
    // rather than casting a size_t that could overflow it.
    constexpr std::size_t kChunk = 8192;
    for (std::size_t offset = 0; offset < frameCount; offset += kChunk) {
        const std::size_t n = std::min(kChunk, frameCount - offset);
        if (chromaprint_feed(guard.ctx, mono + offset, static_cast<int>(n)) != 1) {
            return 0;
        }
    }

    if (chromaprint_finish(guard.ctx) != 1) return 0;

    RawGuard raw;
    int size = 0;
    if (chromaprint_get_raw_fingerprint(guard.ctx, &raw.data, &size) != 1) return 0;
    if (raw.data == nullptr || size <= 0) return 0;

    const int written = std::min(size, capacity);
    std::copy(raw.data, raw.data + written, out);
    return written;
}

int ChromaprintFingerprint::computeFromFile(const char* path,
                                            uint32_t* out,
                                            int* inOutSize) {
    if (path == nullptr || out == nullptr || inOutSize == nullptr) return -1;
    const int capacity = *inOutSize;
    if (capacity <= 0) return -1;

    // Decode straight to chromaprint's native rate — see the header note.
    auto decoder = Decoder::open(path, kChromaprintSampleRate, /*channels=*/1);
    if (!decoder) return -2;

    const std::size_t maxFrames =
        static_cast<std::size_t>(kChromaprintSampleRate) * kChromaprintSeconds;
    std::vector<float> pcm(maxFrames, 0.0f);
    const std::size_t read = decoder->read(pcm.data(), maxFrames);
    if (read == 0) return -2;

    std::vector<int16_t> mono(read);
    for (std::size_t i = 0; i < read; ++i) {
        const float clamped = std::max(-1.0f, std::min(1.0f, pcm[i]));
        mono[i] = static_cast<int16_t>(clamped * 32767.0f);
    }

    const int written =
        compute(mono.data(), read, kChromaprintSampleRate, out, capacity);
    *inOutSize = written;
    return (written > 0) ? 0 : -2;
}

double ChromaprintFingerprint::bitErrorRate(const uint32_t* a, std::size_t aLen,
                                            const uint32_t* b, std::size_t bLen) {
    if (a == nullptr || b == nullptr || aLen == 0 || bLen == 0) return 1.0;

    // Compare the overlapping prefix. Aura fingerprints a fixed 30s window from
    // the start of each file, so aligned prefixes are the right comparison; a
    // length mismatch only means one file was shorter.
    const std::size_t n = std::min(aLen, bLen);
    int differing = 0;
    for (std::size_t i = 0; i < n; ++i) {
        differing += popcount32(a[i] ^ b[i]);
    }
    return static_cast<double>(differing) / static_cast<double>(n * 32);
}

}  // namespace aura
