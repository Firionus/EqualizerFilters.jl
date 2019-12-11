"""
    Biquad(filterType::Symbol, f, dbGain, Q)

Return peak, low shelf or high shelf biquad depending on respective `filterType`
 `:PK`, `:LS` or `:HS`. Parameters are center frequency `f` in Hz,
 Gain `dbGain` in dB and the quality factor `Q`.

The sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
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

"""
    Biquad(filterType::Symbol, f, Q)

Return lowpass, highpass, bandpass, notch or allpass biquad depending on
respective `filterType` `:LP`, `:HP`, `:BP`, `:NO` or `:AP`.
Parameters are frequency `f` in Hz and the quality factor `Q`.

The sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
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

"""
    Biquad(filterType::Symbol, dbGain)

When `filterType` is `:G` for Gain return the field level ratio given by the
parameter `dbGain` in dB. Throw error for other `filterType`.
"""
function Biquad(filterType::Symbol, dbGain)
    if filterType == :G
        return 10^(dbGain/20)
    else
        error("single-argument filterType expects :G for Gain in dB")
    end
end

"""
    Biquad(x::Tuple{Symbol, Vararg})

Return Biquad of a filter specified in a tuple format, where the first argument
is a symbol and defines the filter type:
`([:LP, :HP, :BP, :NO, :AP, :PK, :LS, :HS, :G], f, dbGain, Q)`

For non-gain filter types [:LP, :HP, :BP, :NO, :AP] the argument `dbGain` is to
be omitted. For the simple gain-filter `:G` the arguments `f` and `Q` shall be
omitted.

`f` is in Hz and `dbGain` in dB. The quality factor `Q` is dimensionless.

The filter types refert to a lowpass, highpass, bandpass, notch, allpass, peaking,
low shelf, high shelf and gain filter respectively.

The sampling rate defaults to 48 kHz or can be
set with [`EqualizerFilters.sampling_rate`](@ref).
"""
function Biquad(x::Tuple{Symbol, Vararg})
    Biquad(x...)
end

"""
    SecondOrderSections(x::Array{T} where {T <: Tuple{Symbol, Vararg}})

Return SecondOrderSections that represent the filters defined in the array
in a tuple format. For details of the tuple format see
[`Biquad(x::Tuple{Symbol, Vararg})`](@ref).
"""
function SecondOrderSections(x::Array{T} where {T <: Tuple{Symbol, Vararg}})
    biquads = [Biquad(x[i]...) for i in 1:length(x)]
    *(biquads...)
end
