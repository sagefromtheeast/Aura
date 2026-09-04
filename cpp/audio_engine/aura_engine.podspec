#
# aura_engine.podspec
# Aura — CocoaPods wrapper so the C++ engine builds into the iOS app.
#
# The iOS Runner target does not compile cpp/ by default. To wire it up, add to
# ios/Podfile inside `target 'Runner' do`:
#
#     pod 'aura_engine', :path => '../cpp/audio_engine'
#
# then run `cd ios && pod install`. The engine links statically into Runner, so
# DynamicLibrary.process() in audio_engine_ffi.dart resolves the symbols.
#
Pod::Spec.new do |s|
  s.name             = 'aura_engine'
  s.version          = '1.0.0'
  s.summary          = 'Aura audiophile C++ audio engine (miniaudio + DSP).'
  s.description      = <<-DESC
    Handle-based audio engine for Aura: gapless playback, 10-band parametric EQ,
    ReplayGain normalisation, equal-power crossfade, feature extraction and
    acoustic fingerprinting. Offline only, no network access.
  DESC
  s.homepage         = 'https://github.com/sagefromtheeast/Aura'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Aura' => 'support@aura.app' }
  s.source           = { :path => '.' }

  s.ios.deployment_target = '13.0'

  s.source_files = [
    'audio_engine.{h,cpp}',
    'dsp/*.{h,cpp}',
    'decoder/*.{h,cpp}',
    'analyzer/*.{h,cpp}',
    'third_party/miniaudio.h',
    # Vendored Chromaprint: upstream's MIT core plus KissFFT. avresample/,
    # the FFmpeg/FFTW/vDSP FFT backends and the CLI tools are excluded, so the
    # engine always feeds chromaprint audio already at 11025 Hz.
    'third_party/chromaprint/src/*.{h,cpp}',
    'third_party/chromaprint/src/audio/audio_slicer.h',
    'third_party/chromaprint/src/include/chromaprint.h',
    'third_party/chromaprint/src/utils/*.{h,cpp}',
    'third_party/chromaprint/src/3rdparty/kissfft/kiss_fft.{h,c}',
    'third_party/chromaprint/src/3rdparty/kissfft/kiss_fftr.{h,c}',
    'third_party/chromaprint/src/3rdparty/kissfft/_kiss_fft_guts.h',
    'third_party/chromaprint/src/3rdparty/kissfft/kiss_fft_log.h',
  ]
  s.exclude_files = [
    # Other FFT backends, selected by config.h; only KissFFT is vendored.
    'third_party/chromaprint/src/fft_lib_avfft.*',
    'third_party/chromaprint/src/fft_lib_avtx.*',
    'third_party/chromaprint/src/fft_lib_fftw3.*',
    'third_party/chromaprint/src/fft_lib_vdsp.*',
  ]
  s.public_header_files = 'audio_engine.h'
  s.header_mappings_dir = '.'

  s.libraries   = 'c++'
  s.frameworks  = 'AudioToolbox', 'CoreAudio', 'CoreFoundation', 'AVFoundation'

  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY'           => 'libc++',
    'GCC_OPTIMIZATION_LEVEL'      => '3',
    'HEADER_SEARCH_PATHS'         =>
      '"$(PODS_TARGET_SRCROOT)/third_party/chromaprint/src" ' \
      '"$(PODS_TARGET_SRCROOT)/third_party/chromaprint/src/include" ' \
      '"$(PODS_TARGET_SRCROOT)/third_party/chromaprint/src/3rdparty/kissfft"',
    'GCC_PREPROCESSOR_DEFINITIONS' =>
      '$(inherited) HAVE_CONFIG_H=1 CHROMAPRINT_NODLL=1 kiss_fft_scalar=float',
    # Keep the C API visible to dart:ffi's DynamicLibrary.process().
    'GCC_SYMBOLS_PRIVATE_EXTERN'  => 'NO',
    'DEFINES_MODULE'              => 'YES',
  }
end
