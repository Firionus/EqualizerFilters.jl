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
