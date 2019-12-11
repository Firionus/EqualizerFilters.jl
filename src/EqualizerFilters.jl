module EqualizerFilters

import DSP.Biquad

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

function Biquad(filterType::Symbol, f, dbGain, Q)
    if filterType == :PK
        return PK(f, dbGain, Q)
    elseif filterType == :LS
        return LS(f, dbGain, Q)
    elseif filterType == :HS
        return HS(f, dbGain, Q)
    else
        error("three-argument filterType not recognized")
    end
end

function Biquad(filterType::Symbol, f, Q)
    if filterType == :LP
        return LP(f, Q)
    elseif filterType == :HP
        return HP(f, Q)
    elseif filterType == :BP
        return BP(f, Q)
    elseif filterType == :NO
        return NO(f, Q)
    elseif filterType == :AP
        return AP(f,Q)
    else
        error("two-argument filterType not recognized")
    end
end

function Biquad(filterType::Symbol, dbGain)
    if filterType == :G
        return 10^(dbGain/20)
    else
        error("single-argument filterType expects :G for Gain in dB")
    end
end

function Biquad(x::Tuple{Symbol, Vararg})
    Biquad(x...)
end

function Biquad(x::Array{T} where {T <: Tuple{Symbol, Vararg}})
    biquads = [Biquad(x[i]...) for i in 1:length(x)]
    *(biquads...)
end

function eqAPOstring(filterType::Symbol, f, dbGain, Q)
    if filterType in [:PK, :LS, :HS]
        return string("Filter: ON ", filterType, " Fc ", f, " Hz Gain ",
        dbGain, " dB Q ", Q, "\n")
    else
        error("three-argument filterType not recognized")
    end
end

function eqAPOstring(filterType::Symbol, f, Q)
    if filterType in [:LP, :HP, :BP, :NO, :AP]
        return string("Filter: ON ", filterType, " Fc ", f, " Hz Q ", Q, "\n")
    else
        error("two-argument filterType not recognized")
    end
end

function eqAPOstring(filterType::Symbol, param)
    if filterType == :G
        return string("Preamp: ", param, " dB\n")
    elseif filterType == :D
        return string("Delay: ", param, " ms\n")
    elseif filterType == :Ds
        return string("Delay: ", param, " samples\n")
    else
        error("single-argument filterType not recognized")
    end
end

function eqAPOstring(x::Tuple{Symbol, Vararg})
    eqAPOstring(x...)
end

function eqAPOstring(x::Array{T} where {T <: Tuple{Symbol, Vararg}})
    biquadStrings = [eqAPOstring(x[i]) for i in 1:length(x)]
    string(biquadStrings...)
end

end # module
