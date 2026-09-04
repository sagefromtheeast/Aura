/**
 * fingerprint.cpp
 * Aura — Windowed MurmurHash3 acoustic fingerprint.
 */

#include "fingerprint.h"

#include <algorithm>
#include <cmath>
#include <vector>

#include "../decoder/decoder.h"

namespace aura {
namespace {

inline uint32_t rotl32(uint32_t x, int8_t r) {
    return (x << r) | (x >> (32 - r));
}

}  // namespace

uint32_t Fingerprint::murmur3_32(const uint8_t* data, std::size_t len, uint32_t seed) {
    if (data == nullptr) return seed;

    uint32_t h1 = seed;
    const uint32_t c1 = 0xcc9e2d51;
    const uint32_t c2 = 0x1b873593;

    const std::size_t nblocks = len / 4;
    for (std::size_t i = 0; i < nblocks; ++i) {
        uint32_t k1;
        // memcpy-style load keeps this alignment- and alias-safe.
        k1 = static_cast<uint32_t>(data[i * 4 + 0]) |
             (static_cast<uint32_t>(data[i * 4 + 1]) << 8) |
             (static_cast<uint32_t>(data[i * 4 + 2]) << 16) |
             (static_cast<uint32_t>(data[i * 4 + 3]) << 24);

        k1 *= c1;
        k1 = rotl32(k1, 15);
        k1 *= c2;

        h1 ^= k1;
        h1 = rotl32(h1, 13);
        h1 = h1 * 5 + 0xe6546b64;
    }

    const uint8_t* tail = data + nblocks * 4;
    uint32_t k1 = 0;
    switch (len & 3) {
        case 3:
            k1 ^= static_cast<uint32_t>(tail[2]) << 16;
            [[fallthrough]];
        case 2:
            k1 ^= static_cast<uint32_t>(tail[1]) << 8;
            [[fallthrough]];
        case 1:
            k1 ^= static_cast<uint32_t>(tail[0]);
            k1 *= c1;
            k1 = rotl32(k1, 15);
            k1 *= c2;
            h1 ^= k1;
            break;
        default:
            break;
    }

    h1 ^= static_cast<uint32_t>(len);
    h1 ^= h1 >> 16;
    h1 *= 0x85ebca6b;
    h1 ^= h1 >> 13;
    h1 *= 0xc2b2ae35;
    h1 ^= h1 >> 16;
    return h1;
}

int Fingerprint::compute(const int16_t* mono,
                         std::size_t frameCount,
                         int sampleRate,
                         uint32_t* out,
                         int capacity) {
    if (mono == nullptr || out == nullptr || capacity <= 0) return 0;
    if (frameCount == 0 || sampleRate <= 0) return 0;

    const std::size_t windowFrames = std::max<std::size_t>(
        1, static_cast<std::size_t>(sampleRate) * kFingerprintWindowMs / 1000);

    int written = 0;
    for (std::size_t start = 0; start + windowFrames <= frameCount && written < capacity;
         start += windowFrames) {
        // Quantise to 8 bits per sample before hashing so small encoder
        // differences between two rips of the same track do not change the hash.
        std::vector<uint8_t> quantised(windowFrames);
        for (std::size_t i = 0; i < windowFrames; ++i) {
            const int16_t s = mono[start + i];
            quantised[i] = static_cast<uint8_t>((s >> 8) + 128);
        }
        // Seed with the window index so identical windows in different
        // positions hash differently. Read `written` before incrementing it —
        // doing both in one expression is unsequenced (UB).
        const uint32_t seed = static_cast<uint32_t>(written);
        out[written] = murmur3_32(quantised.data(), quantised.size(), seed);
        ++written;
    }
    return written;
}

int Fingerprint::computeFromFile(const char* path, uint32_t* out, int* inOutSize) {
    if (path == nullptr || out == nullptr || inOutSize == nullptr) return -1;
    const int capacity = *inOutSize;
    if (capacity <= 0) return -1;

    auto decoder = Decoder::open(path, kFingerprintSampleRate, /*channels=*/1);
    if (!decoder) return -2;

    const std::size_t maxFrames =
        static_cast<std::size_t>(kFingerprintSampleRate) * kFingerprintSeconds;
    std::vector<float> pcm(maxFrames, 0.0f);
    const std::size_t read = decoder->read(pcm.data(), maxFrames);
    if (read == 0) return -2;

    // Convert to 16-bit for hashing.
    std::vector<int16_t> mono(read);
    for (std::size_t i = 0; i < read; ++i) {
        const float clamped = std::max(-1.0f, std::min(1.0f, pcm[i]));
        mono[i] = static_cast<int16_t>(clamped * 32767.0f);
    }

    *inOutSize = compute(mono.data(), read, kFingerprintSampleRate, out, capacity);
    return (*inOutSize > 0) ? 0 : -2;
}

}  // namespace aura
