/**
 * decoder.h
 * Aura — Audio decoding abstraction.
 *
 * Decoder::open() picks a backend at runtime:
 *   1. FFmpegDecoder  — when built with AURA_WITH_FFMPEG (adds AAC/ALAC/DSD/
 *                       APE/WMA and anything else FFmpeg handles).
 *   2. MiniaudioDecoder — always available; MP3/FLAC/WAV/OGG.
 *
 * All backends output interleaved 32-bit float PCM at the requested rate and
 * channel count, so the DSP chain never has to care about the source format.
 */

#pragma once

#include <cstddef>
#include <cstdint>
#include <memory>
#include <string>

namespace aura {

class Decoder {
public:
    virtual ~Decoder() = default;

    /// Reads up to [frameCount] frames into [out] (interleaved float).
    /// Returns the number of frames actually read (0 at end of stream).
    virtual std::size_t read(float* out, std::size_t frameCount) = 0;

    /// Seeks to [frameIndex]. Returns false when the source is not seekable.
    virtual bool seekToFrame(uint64_t frameIndex) = 0;

    /// Total frames, or 0 when unknown (e.g. a stream).
    virtual uint64_t totalFrames() const = 0;

    /// Track length in milliseconds, or 0 when unknown.
    virtual int64_t durationMs() const = 0;

    virtual int sampleRate() const = 0;
    virtual int channels() const = 0;

    /// Human-readable backend name, for logs and tests.
    virtual const char* backendName() const = 0;

    /// Opens [path], converting to [sampleRate]/[channels].
    /// Returns nullptr when no backend can handle the file.
    static std::unique_ptr<Decoder> open(const std::string& path,
                                         int sampleRate,
                                         int channels);

    /// True when this build includes the FFmpeg backend.
    static bool ffmpegAvailable();
};

}  // namespace aura
