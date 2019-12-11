"""
    eqAPOstring(filterType::Symbol, f, dbGain, Q)

Convert a three-parameter filter to a string in Equalizer APO
configuration file format.

As `filterType` use:
- `:PK` for peaking filter
- `:LS` for low shelf filter
- `:HS` for high shelf filter

Parameters are the center frequency `f` in Hz, the Gain `dbGain` in dB and the
quality factor `Q`.
"""
function eqAPOstring(filterType::Symbol, f, dbGain, Q)
    if filterType in [:PK, :LS, :HS]
        return string("Filter: ON ", filterType, " Fc ", f, " Hz Gain ",
        dbGain, " dB Q ", Q, "\n")
    else
        error("three-argument filterType not recognized")
    end
end

"""
    eqAPOstring(filterType::Symbol, f, Q)

Convert a two-parameter filter to a
string in Equalizer APO configuration file format.

As `filterType` use:
- `:LP` for lowpass filter
- `:HP` for high pass filter
- `:BP` for band pass filter
- `:NO` for notch filter
- `:AP` for all pass filter

Parameters are the frequency `f` in Hz and the quality factor `Q`.
"""
function eqAPOstring(filterType::Symbol, f, Q)
    if filterType in [:LP, :HP, :BP, :NO, :AP]
        return string("Filter: ON ", filterType, " Fc ", f, " Hz Q ", Q, "\n")
    else
        error("two-argument filterType not recognized")
    end
end

"""
    eqAPOstring(filterType::Symbol, param)

Covert a gain or delay filter to a string in Equalizer APO configuration file format.

As `filterType` use:
- `:G` for gain filter with gain in dB
- `:D` for delay filter with delay in ms
- `:Ds` for delay filter with delay in samples.
"""
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

"""
    eqAPOstring(x::Array{T} where {T <: Tuple{Symbol, Vararg}})

Convert an array of filters in a tuple format to a string in
Equalizer APO configuration file format.

The tuples in the array shall constructed according to:

`([:G|:D|:Ds|:LP|:HP|:BP|:NO|:AP|:PK|:LS|:HS], f, dbGain, Q)`

Depending on the filter please omit the unneeded arguments. See other methods of
[`eqAPOstring`](@ref) for details.
"""
function eqAPOstring(x::Array{T} where {T <: Tuple{Symbol, Vararg}})
    biquadStrings = [eqAPOstring(x[i]) for i in 1:length(x)]
    string(biquadStrings...)
end

"""
    eqAPOstring(x::FilterCoefficients)

Convert the given DSP.jl Filter to a
string in Equalizer APO configuration file format.

The conversion uses second order sections and spreads the gain evenly among all
biquads.
"""
function eqAPOstring(x::FilterCoefficients)
    xsos = SecondOrderSections(x)
    biquads = xsos.biquads
    n = length(biquads)
    gain = xsos.g^(1/n)
    output = string()
    for i in eachindex(biquads)
        currentBiquad = biquads[i]
        output *= string("Filter: ON IIR Order 2 Coefficients ",
        currentBiquad.b0, " ", currentBiquad.b1, " ", currentBiquad.b2, " 1 ",
        currentBiquad.a1, " ", currentBiquad.a2, "\n")
    end
    output
end
