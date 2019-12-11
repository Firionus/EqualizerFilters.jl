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
