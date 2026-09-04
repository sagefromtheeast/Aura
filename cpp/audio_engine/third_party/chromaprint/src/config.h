/* config.h — Aura's minimal Chromaprint build configuration.
 *
 * Upstream generates this from config.h.in via CMake. Aura vendors only the
 * MIT-licensed core plus KissFFT, so the FFmpeg/FFTW/vDSP options are all off.
 * Notably USE_INTERNAL_AVRESAMPLE is OFF (that code is LGPL FFmpeg), which
 * means AudioProcessor cannot resample — Aura therefore always feeds
 * chromaprint audio already decoded at kChromaprintSampleRate.
 */
#pragma once

#define HAVE_ROUND 1
#define HAVE_LRINTF 1
#define USE_KISSFFT 1
