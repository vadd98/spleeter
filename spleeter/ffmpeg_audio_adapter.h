///
/// @file
/// @copyright Copyright (c) 2020, MIT License
///
#ifndef SPLEETER_FFMPEG_AUDIO_ADAPTER_H_
#define SPLEETER_FFMPEG_AUDIO_ADAPTER_H_

#include "spleeter/i_audio_adapter.h"

#ifndef __cplusplus__
extern "C"
{
#endif
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libavutil/frame.h>
#include <libavutil/mem.h>
#include <libavutil/opt.h>
#include <libswresample/swresample.h>
#ifndef __cplusplus__
}
#endif

#include <cstdint>
#include <string>
#include <tuple>

/**
 * References:
 * 1) https://rodic.fr/blog/libavcodec-tutorial-decode-audio-file/
 * 2) https://medium.com/@donturner/using-ffmpeg-for-faster-audio-decoding-967894e94e71  <--- Looks good.
 */

namespace spleeter
{
/// @brief An AudioAdapter implementation that use FFMPEG libraries to perform I/O operation for audio processing.
class FfmpegAudioAdapter : public IAudioAdapter
{
  public:
    /// @brief Constructor.
    FfmpegAudioAdapter();

    /// @brief Destructor.
    virtual ~FfmpegAudioAdapter() override;

    /// @brief Loads the audio file denoted by the given path and returns it data as a waveform.
    ///
    /// @param path[in]         - Path of the audio file to load data from.
    /// @param offset[in]       - (Optional) Start offset to load from in seconds.
    /// @param duration[in]     - (Optional) Duration to load in seconds.
    /// @param sample_rate[in]  - (Optional) Sample rate to load audio with.
    ///
    /// @returns Loaded data a (waveform, sample_rate) tuple.
    virtual std::tuple<Waveform, std::int32_t> Load(const std::string& path, const double offset, const double duration,
                                                    const std::int32_t& sample_rate) override;

    /// @brief Write waveform data to the file denoted by the given path using FFMPEG process.
    ///
    /// @param path[in]        - Path of the audio file to save data in.
    /// @param data[in]        - Waveform data to write.
    /// @param sample_rate[in] - Sample rate to write file in.
    /// @param codec[in]       - (Optional) Writing codec to use.
    /// @param bitrate[in]     - (Optional) Bitrate of the written audio file.
    virtual void Save(const std::string& path, const std::string& data, const std::int32_t& sample_rate,
                      const std::string& codec) override;

  private:
    AVFormatContext* format_;
};
}  // namespace spleeter

#endif  /// SPLEETER_FFMPEG_AUDIO_ADAPTER_H_
