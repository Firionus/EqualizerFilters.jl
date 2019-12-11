# EqualizerFilters.jl

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://Firionus.github.io/EqualizerFilters.jl/dev)
[![Build Status](https://travis-ci.com/Firionus/EqualizerFilters.jl.svg?branch=master)](https://travis-ci.com/Firionus/EqualizerFilters.jl)

This package provides:

1. [DSP.jl](https://github.com/JuliaDSP/DSP.jl)-Biquads of typical audio equalizer filters, compatible to [Equalizer APO](https://sourceforge.net/projects/equalizerapo/). This allows the development of filters in Julia, followed by deployment on a Windows PC.
2. An Array of Tuples representing an EQ filter chain which can be converted to both SecondOrderSections from [DSP.jl](https://github.com/JuliaDSP/DSP.jl) and to the [configuration file format of Equalizer APO](https://sourceforge.net/p/equalizerapo/wiki/Configuration%20reference/).
3. Conversion from arbitrary [DSP.jl](https://github.com/JuliaDSP/DSP.jl)-filters to the [Equalizer APO configuration file format](https://sourceforge.net/p/equalizerapo/wiki/Configuration%20reference/) via Second Order IIR Filters

The Biquad implementation has been directly copy-pasted from the [Equalizer APO
codebase](https://sourceforge.net/p/equalizerapo/code/HEAD/tree/tags/1.2.1/filters/BiQuad.cpp#l70), which
in turn seems to be copied from [W3 Cookbook formulae for audio equalizer biquad filter coeffiecients](https://www.w3.org/2011/audio/audio-eq-cookbook.html)
which again cites [musicdsp.org](http://www.musicdsp.org/en/latest/) as its source.

## Other packages

If you need compatibility to the [Lake DSP platform](https://www.lakeprocessing.com), you can use
[LakeBiquads.jl](https://github.com/Firionus/LakeBiquads.jl).
The package may also be of interest because the Peaking EQ uses an approach similar
to [(Orfanidis, JAES 1997)](http://www.aes.org/e-lib/browse.cfm?elib=7854) where
the Nyquist-gain is adjusted to more closely approximate analog EQs. In contrast
to the implementation in DSP.jl, it also provides
a Bessel highpass with maximally flat group delay behaviour at higher orders.
