module EqualizerFilters

import DSP.Biquad
using DSP

include("equalizerAPOstrings.jl")
include("DSPjlBiquads.jl")

export LP, HP, BP, NO, AP, PK, LS, HS, Biquad, eqAPOstring

#default sampling rate
fs = 48e3

function sampling_rate(custom_sampling_rate)
    global fs = custom_sampling_rate
end

function sampling_rate()
    fs
end

function biquadPrecalculations(dbGain, freq, srate, Q)
    A = 10^(dbGain/40)
    omega = 2pi * freq / srate
    sn = sin(omega)
    cs = cos(omega)
    alpha = sn / (2 * Q)
    beta = 2 * sqrt(A) * alpha
    return A, sn, cs, alpha, beta
end

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
