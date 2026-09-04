/**
 * decoder.cpp
 * Aura — Decoder factory + the always-available miniaudio backend.
 */

#include "decoder.h"

#include "../third_party/miniaudio.h"
#include "ffmpeg_decoder.h"

namespace aura {

namespace {

/// miniaudio-backed decoder: MP3, FLAC, WAV and OGG/Vorbis.
class MiniaudioDecoder final : public Decoder {
public:
    ~MiniaudioDecoder() override {
        if (initialised_) ma_decoder_uninit(&decoder_);
    }

    bool open(const std::string& path, int sampleRate, int channels) {
        ma_decoder_config cfg = ma_decoder_config_init(
            ma_format_f32, static_cast<ma_uint32>(channels),
            static_cast<ma_uint32>(sampleRate));
        if (ma_decoder_init_file(path.c_str(), &cfg, &decoder_) != MA_SUCCESS) {
            return false;
        }
        initialised_ = true;
        sampleRate_ = sampleRate;
        channels_ = channels;

        ma_uint64 frames = 0;
        if (ma_decoder_get_length_in_pcm_frames(&decoder_, &frames) == MA_SUCCESS) {
            totalFrames_ = frames;
        }
        return true;
    }

    std::size_t read(float* out, std::size_t frameCount) override {
        if (!initialised_ || out == nullptr) return 0;
        ma_uint64 read = 0;
        if (ma_decoder_read_pcm_frames(&decoder_, out, frameCount, &read) != MA_SUCCESS) {
            return 0;
        }
        return static_cast<std::size_t>(read);
    }

    bool seekToFrame(uint64_t frameIndex) override {
        if (!initialised_) return false;
        return ma_decoder_seek_to_pcm_frame(&decoder_, frameIndex) == MA_SUCCESS;
    }

    uint64_t totalFrames() const override { return totalFrames_; }

    int64_t durationMs() const override {
        if (totalFrames_ == 0 || sampleRate_ <= 0) return 0;
        return static_cast<int64_t>((totalFrames_ * 1000ULL) /
                                    static_cast<uint64_t>(sampleRate_));
    }

    int sampleRate() const override { return sampleRate_; }
    int channels() const override { return channels_; }
    const char* backendName() const override { return "miniaudio"; }

private:
    ma_decoder decoder_{};
    bool initialised_ = false;
    int sampleRate_ = 0;
    int channels_ = 0;
    uint64_t totalFrames_ = 0;
};

}  // namespace

std::unique_ptr<Decoder> Decoder::open(const std::string& path,
                                       int sampleRate,
                                       int channels) {
    if (path.empty() || sampleRate <= 0 || channels <= 0) return nullptr;

    // Prefer FFmpeg when compiled in — it covers strictly more formats.
    if (auto ff = FFmpegDecoder::tryOpen(path, sampleRate, channels)) {
        return ff;
    }

    auto ma = std::make_unique<MiniaudioDecoder>();
    if (ma->open(path, sampleRate, channels)) {
        return ma;
    }
    return nullptr;
}

bool Decoder::ffmpegAvailable() { return FFmpegDecoder::isAvailable(); }

}  // namespace aura
