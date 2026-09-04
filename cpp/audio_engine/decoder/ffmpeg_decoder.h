/**
 * ffmpeg_decoder.h
 * Aura — Optional FFmpeg decoding backend.
 *
 * Compiled only when AURA_WITH_FFMPEG is defined and libavcodec/libavformat/
 * libswresample are found (see CMakeLists.txt). Without it, tryOpen() returns
 * nullptr and Decoder::open() falls through to miniaudio, so the default build
 * has no FFmpeg dependency and no binary-size cost.
 *
 * NOTE: FFmpeg is LGPL (GPL with some build flags). Review licensing and the
 * PRD's 60MB binary budget before enabling it for release builds.
 */

#pragma once

#include <cstddef>
#include <memory>
#include <string>

#include "decoder.h"

namespace aura {

class FFmpegDecoder {
public:
    /// Attempts to open [path] with FFmpeg.
    /// Returns nullptr when FFmpeg is not compiled in or cannot handle the file.
    static std::unique_ptr<Decoder> tryOpen(const std::string& path,
                                            int sampleRate,
                                            int channels);

    /// True when this build links FFmpeg.
    static bool isAvailable();
};

}  // namespace aura
