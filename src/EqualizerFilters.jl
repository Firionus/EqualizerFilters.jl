module EqualizerFilters

import DSP.Biquad
import DSP.SecondOrderSections
using DSP

include("equalizerAPOstrings.jl")
include("DSPjlBiquads.jl")

export LP, HP, BP, NO, AP, PK, LS, HS, Biquad, eqAPOstring, SecondOrderSections

#default sampling rate
fs = 48e3

"""
    EqualizerFilters.sampling_rate(custom_sampling_rate)

Set the sampling rate for calculation of the biquads in Hz.

Defaults to 48 kHz.
"""
function sampling_rate(custom_sampling_rate)
    global fs = custom_sampling_rate
end

"""
    EqualizerFilters.sampling_rate()

Return the current sampling rate for biquad calculation in Hz.

Defaults to 48 kHz.
"""
function sampling_rate()
    fs
end

"""
    biquadPrecalculations(dbGain, freq, srate, Q)

Returns `(A, sn, cs, alpha, beta)` that have to be calculated for all
filter types.

The parameter A is not needed for gain-less filters.
The calling functions simply pass 0 dB Gain and do not use the returned parameter
`A`.
"""
function biquadPrecalculations(dbGain, freq, srate, Q)
    A = 10^(dbGain/40)
    omega = 2pi * freq / srate
    sn = sin(omega)
    cs = cos(omega)
    alpha = sn / (2 * Q)
    beta = 2 * sqrt(A) * alpha
    return A, sn, cs, alpha, beta
end

"""
    LP(f, Q, fs=sampling_rate)

Return lowpass biquad at frequency `f` in Hz with quality factor `Q`.

This second order lowpass falls of with 12 dB/oct.

If not given in the arguments, the sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function LP(f, Q, fs=fs)
    A, sn, cs, alpha, beta = biquadPrecalculations(0, f, fs, Q)
    b0 = (1 - cs) / 2
    b1 = 1 - cs
    b2 = (1 - cs) / 2
    a0 = 1 + alpha
    a1 = -2 * cs
    a2 = 1 - alpha
    biquadCoefs = [b0, b1, b2, a1, a2]./a0
    return Biquad(biquadCoefs...)
end

"""
    HP(f, Q, fs=sampling_rate)

Return highpass biquad at frequency `f` in Hz with quality factor `Q`.

This second order highpass falls of with 12 dB/oct.

If not given in the arguments, the sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function HP(f, Q, fs=fs)
    A, sn, cs, alpha, beta = biquadPrecalculations(0, f, fs, Q)
    b0 = (1 + cs) / 2;
    b1 = -(1 + cs);
    b2 = (1 + cs) / 2;
    a0 = 1 + alpha;
    a1 = -2 * cs;
    a2 = 1 - alpha;
    biquadCoefs = [b0, b1, b2, a1, a2]./a0
    return Biquad(biquadCoefs...)
end

"""
    BP(f, Q, fs=sampling_rate)

Return bandpass biquad at frequency `f` in Hz with quality factor `Q`.

If not given in the arguments, the sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function BP(f, Q, fs=fs)
    A, sn, cs, alpha, beta = biquadPrecalculations(0, f, fs, Q)
    b0 = alpha;
    b1 = 0;
    b2 = -alpha;
    a0 = 1 + alpha;
    a1 = -2 * cs;
    a2 = 1 - alpha;
    biquadCoefs = [b0, b1, b2, a1, a2]./a0
    return Biquad(biquadCoefs...)
end

"""
    NO(f, Q, fs=sampling_rate)

Return notch biquad at frequency `f` in Hz with quality factor `Q`.

If not given in the arguments, the sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function NO(f, Q, fs=fs)
    A, sn, cs, alpha, beta = biquadPrecalculations(0, f, fs, Q)
    b0 = 1;
    b1 = -2 * cs;
    b2 = 1;
    a0 = 1 + alpha;
    a1 = -2 * cs;
    a2 = 1 - alpha;
    biquadCoefs = [b0, b1, b2, a1, a2]./a0
    return Biquad(biquadCoefs...)
end

"""
    AP(f, Q, fs=sampling_rate)

Return allpass biquad at frequency `f` in Hz with quality factor `Q`.

This second order allpass rotates the phase by a total of ``2π``.

If not given in the arguments, the sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function AP(f, Q, fs=fs)
    A, sn, cs, alpha, beta = biquadPrecalculations(0, f, fs, Q)
    b0 = 1 - alpha;
    b1 = -2 * cs;
    b2 = 1 + alpha;
    a0 = 1 + alpha;
    a1 = -2 * cs;
    a2 = 1 - alpha;
    biquadCoefs = [b0, b1, b2, a1, a2]./a0
    return Biquad(biquadCoefs...)
end

"""
    PK(f, dbGain, Q, fs=sampling_rate)

Return peaking biquad with Gain `dbGain` in dB at frequency `f` in Hz
with quality factor `Q`.

In this implementation the Gain at 0 Hz and at the Nyquist frequency will
always be 0 dB. For an Orfanidis-like peak EQ with analog-inspired
Nyquist-gain see the package LakeBiquads.jl.

If not given in the arguments, the sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function PK(f, dbGain, Q, fs=fs)
    A, sn, cs, alpha, beta = biquadPrecalculations(dbGain, f, fs, Q)
    b0 = 1 + (alpha * A);
    b1 = -2 * cs;
    b2 = 1 - (alpha * A);
    a0 = 1 + (alpha / A);
    a1 = -2 * cs;
    a2 = 1 - (alpha / A);
    biquadCoefs = [b0, b1, b2, a1, a2]./a0
    return Biquad(biquadCoefs...)
end

"""
    LS(f, dbGain, Q, fs=sampling_rate)

Return low shelf biquad with Gain `dbGain` in dB, center frequency `f` in Hz and
quality factor `Q`.

If not given in the arguments, the sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function LS(f, dbGain, Q, fs=fs)
    A, sn, cs, alpha, beta = biquadPrecalculations(dbGain, f, fs, Q)
    b0 = A * ((A + 1) - (A - 1) * cs + beta);
    b1 = 2 * A * ((A - 1) - (A + 1) * cs);
    b2 = A * ((A + 1) - (A - 1) * cs - beta);
    a0 = (A + 1) + (A - 1) * cs + beta;
    a1 = -2 * ((A - 1) + (A + 1) * cs);
    a2 = (A + 1) + (A - 1) * cs - beta;
    biquadCoefs = [b0, b1, b2, a1, a2]./a0
    return Biquad(biquadCoefs...)
end

"""
    HS(f, dbGain, Q, fs=sampling_rate)

Return high shelf biquad with Gain `dbGain` in dB, center frequency `f` in Hz and
quality factor `Q`.

If not given in the arguments, the sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function HS(f, dbGain, Q, fs=fs)
    A, sn, cs, alpha, beta = biquadPrecalculations(dbGain, f, fs, Q)
    b0 = A * ((A + 1) + (A - 1) * cs + beta);
    b1 = -2 * A * ((A - 1) + (A + 1) * cs);
    b2 = A * ((A + 1) + (A - 1) * cs - beta);
    a0 = (A + 1) - (A - 1) * cs + beta;
    a1 = 2 * ((A - 1) - (A + 1) * cs);
    a2 = (A + 1) - (A - 1) * cs - beta;
    biquadCoefs = [b0, b1, b2, a1, a2]./a0
    return Biquad(biquadCoefs...)
end

end # module
