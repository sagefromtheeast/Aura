/**
 * ffmpeg_decoder.cpp
 * Aura — Optional FFmpeg decoding backend.
 *
 * Build with -DAURA_WITH_FFMPEG=ON to enable. When disabled the whole backend
 * compiles down to "not available" stubs.
 */

#include "ffmpeg_decoder.h"

#ifdef AURA_WITH_FFMPEG

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/opt.h>
#include <libswresample/swresample.h>
}

#include <algorithm>
#include <vector>

namespace aura {
namespace {

/// Decodes any FFmpeg-supported container to interleaved float PCM.
class FFmpegDecoderImpl final : public Decoder {
public:
    ~FFmpegDecoderImpl() override { cleanup(); }

    bool open(const std::string& path, int sampleRate, int channels) {
        sampleRate_ = sampleRate;
        channels_ = channels;

        if (avformat_open_input(&fmt_, path.c_str(), nullptr, nullptr) < 0) return false;
        if (avformat_find_stream_info(fmt_, nullptr) < 0) return false;

        const AVCodec* codec = nullptr;
        streamIndex_ = av_find_best_stream(fmt_, AVMEDIA_TYPE_AUDIO, -1, -1, &codec, 0);
        if (streamIndex_ < 0 || codec == nullptr) return false;

        ctx_ = avcodec_alloc_context3(codec);
        if (ctx_ == nullptr) return false;
        if (avcodec_parameters_to_context(ctx_, fmt_->streams[streamIndex_]->codecpar) < 0) {
            return false;
        }
        if (avcodec_open2(ctx_, codec, nullptr) < 0) return false;

        // Resample/downmix everything to the requested float layout.
        AVChannelLayout outLayout;
        av_channel_layout_default(&outLayout, channels);
        if (swr_alloc_set_opts2(&swr_, &outLayout, AV_SAMPLE_FMT_FLT, sampleRate,
                                &ctx_->ch_layout, ctx_->sample_fmt, ctx_->sample_rate,
                                0, nullptr) < 0) {
            return false;
        }
        if (swr_init(swr_) < 0) return false;

        packet_ = av_packet_alloc();
        frame_ = av_frame_alloc();
        if (packet_ == nullptr || frame_ == nullptr) return false;

        const AVStream* st = fmt_->streams[streamIndex_];
        if (st->duration > 0) {
            durationMs_ = static_cast<int64_t>(
                st->duration * av_q2d(st->time_base) * 1000.0);
        } else if (fmt_->duration > 0) {
            durationMs_ = fmt_->duration / (AV_TIME_BASE / 1000);
        }
        totalFrames_ = (durationMs_ > 0)
                           ? static_cast<uint64_t>(durationMs_ * sampleRate_ / 1000)
                           : 0;
        return true;
    }

    std::size_t read(float* out, std::size_t frameCount) override {
        if (out == nullptr || frameCount == 0) return 0;
        std::size_t written = 0;

        // Drain anything left over from the previous call first.
        written += drainPending(out, frameCount);

        while (written < frameCount) {
            if (av_read_frame(fmt_, packet_) < 0) break;

            if (packet_->stream_index != streamIndex_) {
                av_packet_unref(packet_);
                continue;
            }
            if (avcodec_send_packet(ctx_, packet_) < 0) {
                av_packet_unref(packet_);
                continue;
            }
            av_packet_unref(packet_);

            while (avcodec_receive_frame(ctx_, frame_) == 0) {
                convertFrame();
                written += drainPending(out + written * channels_, frameCount - written);
                if (written >= frameCount) break;
            }
        }
        return written;
    }

    bool seekToFrame(uint64_t frameIndex) override {
        if (fmt_ == nullptr || sampleRate_ <= 0) return false;
        const int64_t ts = static_cast<int64_t>(frameIndex) * AV_TIME_BASE / sampleRate_;
        if (av_seek_frame(fmt_, -1, ts, AVSEEK_FLAG_BACKWARD) < 0) return false;
        avcodec_flush_buffers(ctx_);
        pending_.clear();
        pendingOffset_ = 0;
        return true;
    }

    uint64_t totalFrames() const override { return totalFrames_; }
    int64_t durationMs() const override { return durationMs_; }
    int sampleRate() const override { return sampleRate_; }
    int channels() const override { return channels_; }
    const char* backendName() const override { return "ffmpeg"; }

private:
    /// Resamples the current AVFrame into pending_.
    void convertFrame() {
        const int maxOut = swr_get_out_samples(swr_, frame_->nb_samples);
        if (maxOut <= 0) return;

        const std::size_t base = pending_.size();
        pending_.resize(base + static_cast<std::size_t>(maxOut) * channels_);

        uint8_t* outPtr = reinterpret_cast<uint8_t*>(pending_.data() + base);
        const int got = swr_convert(swr_, &outPtr, maxOut,
                                    const_cast<const uint8_t**>(frame_->data),
                                    frame_->nb_samples);
        if (got < 0) {
            pending_.resize(base);
            return;
        }
        pending_.resize(base + static_cast<std::size_t>(got) * channels_);
    }

    /// Copies up to [frameCount] frames out of pending_ into [out].
    std::size_t drainPending(float* out, std::size_t frameCount) {
        if (pending_.empty() || frameCount == 0) return 0;
        const std::size_t availableFrames =
            (pending_.size() - pendingOffset_) / static_cast<std::size_t>(channels_);
        const std::size_t take = std::min(availableFrames, frameCount);
        if (take == 0) return 0;

        std::copy(pending_.begin() + pendingOffset_,
                  pending_.begin() + pendingOffset_ + take * channels_, out);
        pendingOffset_ += take * channels_;

        if (pendingOffset_ >= pending_.size()) {
            pending_.clear();
            pendingOffset_ = 0;
        }
        return take;
    }

    void cleanup() {
        if (frame_) av_frame_free(&frame_);
        if (packet_) av_packet_free(&packet_);
        if (swr_) swr_free(&swr_);
        if (ctx_) avcodec_free_context(&ctx_);
        if (fmt_) avformat_close_input(&fmt_);
    }

    AVFormatContext* fmt_ = nullptr;
    AVCodecContext* ctx_ = nullptr;
    SwrContext* swr_ = nullptr;
    AVPacket* packet_ = nullptr;
    AVFrame* frame_ = nullptr;
    int streamIndex_ = -1;

    std::vector<float> pending_;
    std::size_t pendingOffset_ = 0;

    int sampleRate_ = 0;
    int channels_ = 0;
    int64_t durationMs_ = 0;
    uint64_t totalFrames_ = 0;
};

}  // namespace

std::unique_ptr<Decoder> FFmpegDecoder::tryOpen(const std::string& path,
                                                int sampleRate,
                                                int channels) {
    auto d = std::make_unique<FFmpegDecoderImpl>();
    if (d->open(path, sampleRate, channels)) return d;
    return nullptr;
}

bool FFmpegDecoder::isAvailable() { return true; }

}  // namespace aura

#else  // !AURA_WITH_FFMPEG

namespace aura {

std::unique_ptr<Decoder> FFmpegDecoder::tryOpen(const std::string&, int, int) {
    return nullptr;  // Built without FFmpeg — caller falls back to miniaudio.
}

bool FFmpegDecoder::isAvailable() { return false; }

}  // namespace aura

#endif  // AURA_WITH_FFMPEG
