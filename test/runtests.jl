using Test, EqualizerFilters, DSP

@testset "sampling_rate setting" begin
    @test EqualizerFilters.sampling_rate() == 48e3 #test default
    @test EqualizerFilters.sampling_rate(1.) == 1.
    @test EqualizerFilters.sampling_rate() == 1.
    @test EqualizerFilters.sampling_rate(48e3) == 48e3
    @test EqualizerFilters.sampling_rate() == 48e3
end

fTest = 1e3
Qtest = .7
dbGainTest = -10

@testset "individual filter functions" begin
    #missing validation measurements from real EQ APO
    @test_nowarn LP(fTest, Qtest)
    @test_nowarn HP(fTest, Qtest)
    @test_nowarn BP(fTest, Qtest)
    @test_nowarn NO(fTest, Qtest)
    @test_nowarn AP(fTest, Qtest)
    @test_nowarn PK(fTest, dbGainTest, Qtest)
    @test_nowarn LS(fTest, dbGainTest, Qtest)
    @test_nowarn HS(fTest, dbGainTest, Qtest)
end

@testset "Biquad(Symbol, ...)" begin
    @test Biquad(:LP, fTest, Qtest) == LP(fTest, Qtest)
    @test Biquad(:HP, fTest, Qtest) == HP(fTest, Qtest)
    @test Biquad(:BP, fTest, Qtest) == BP(fTest, Qtest)
    @test Biquad(:NO, fTest, Qtest) == NO(fTest, Qtest)
    @test Biquad(:AP, fTest, Qtest) == AP(fTest, Qtest)
    @test Biquad(:PK, fTest, dbGainTest, Qtest) == PK(fTest, dbGainTest, Qtest)
    @test Biquad(:LS, fTest, dbGainTest, Qtest) == LS(fTest, dbGainTest, Qtest)
    @test Biquad(:HS, fTest, dbGainTest, Qtest) == HS(fTest, dbGainTest, Qtest)
end

@testset "Biquad(Tuple-Format)" begin
    @test Biquad((:LP, fTest, Qtest)) == LP(fTest, Qtest)
    @test Biquad((:HP, fTest, Qtest)) == HP(fTest, Qtest)
    @test Biquad((:BP, fTest, Qtest)) == BP(fTest, Qtest)
    @test Biquad((:NO, fTest, Qtest)) == NO(fTest, Qtest)
    @test Biquad((:AP, fTest, Qtest)) == AP(fTest, Qtest)
    @test Biquad((:PK, fTest, dbGainTest, Qtest)) == PK(fTest, dbGainTest, Qtest)
    @test Biquad((:LS, fTest, dbGainTest, Qtest)) == LS(fTest, dbGainTest, Qtest)
    @test Biquad((:HS, fTest, dbGainTest, Qtest)) == HS(fTest, dbGainTest, Qtest)
end

function sos_approx(x::SecondOrderSections,y::SecondOrderSections)
    if !(x.g ≈ y.g)
        return false
    elseif !(length(x.biquads) == length(y.biquads))
        return false
    else
        for i in eachindex(x.biquads)
            if biquad_approx(x.biquads[i],y.biquads[i]) == false
                return false
            end
        end
    end
    return true
end

function biquad_approx(x::Biquad, y::Biquad)
    x.b0 ≈ y.b0 &&
    x.b1 ≈ y.b1 &&
    x.b2 ≈ y.b2 &&
    x.a1 ≈ y.a1 &&
    x.a2 ≈ y.a2
end

@testset "Biquad(Array{Tuple-Format})" begin
    @test sos_approx(
    Biquad([(:LP, fTest, Qtest)]),
    LP(fTest, Qtest)|>SecondOrderSections
    )

    testArray = [(:LP, fTest, Qtest), (:HP, fTest, Qtest), (:BP, fTest, Qtest),
    (:NO, fTest, Qtest), (:AP, fTest, Qtest), (:PK, fTest, dbGainTest, Qtest),
    (:LS, fTest, dbGainTest, Qtest), (:HS, fTest, dbGainTest, Qtest)]
    @test sos_approx(
    Biquad(testArray),
    LP(fTest, Qtest)*HP(fTest, Qtest)*BP(fTest, Qtest)*
    NO(fTest, Qtest)*AP(fTest, Qtest)*PK(fTest, dbGainTest, Qtest)*
    LS(fTest, dbGainTest, Qtest)*HS(fTest, dbGainTest, Qtest)
    )
end

@testset "eqAPOstring(Symbol, ...)" begin
    @test_nowarn eqAPOstring(:LP, fTest, Qtest)
    @test_nowarn eqAPOstring(:HP, fTest, Qtest)
    @test_nowarn eqAPOstring(:BP, fTest, Qtest)
    @test_nowarn eqAPOstring(:NO, fTest, Qtest)
    @test_nowarn eqAPOstring(:AP, fTest, Qtest)
    @test_nowarn eqAPOstring(:PK, fTest, dbGainTest, Qtest)
    @test_nowarn eqAPOstring(:LS, fTest, dbGainTest, Qtest)
    @test_nowarn eqAPOstring(:HS, fTest, dbGainTest, Qtest)
end

@testset "eqAPOstring(Tuple-Format)" begin
    @test_nowarn eqAPOstring((:LP, fTest, Qtest))
    @test_nowarn eqAPOstring((:HP, fTest, Qtest))
    @test_nowarn eqAPOstring((:BP, fTest, Qtest))
    @test_nowarn eqAPOstring((:NO, fTest, Qtest))
    @test_nowarn eqAPOstring((:AP, fTest, Qtest))
    @test_nowarn eqAPOstring((:PK, fTest, dbGainTest, Qtest))
    @test_nowarn eqAPOstring((:LS, fTest, dbGainTest, Qtest))
    @test_nowarn eqAPOstring((:HS, fTest, dbGainTest, Qtest))
end

@testset "eqAPOstring(Array{Tuple-Format})" begin
    @test_nowarn eqAPOstring([(:LP, fTest, Qtest)])

    testArray = [(:LP, fTest, Qtest), (:HP, fTest, Qtest), (:BP, fTest, Qtest),
    (:NO, fTest, Qtest), (:AP, fTest, Qtest), (:PK, fTest, dbGainTest, Qtest),
    (:LS, fTest, dbGainTest, Qtest), (:HS, fTest, dbGainTest, Qtest)]
    @test_nowarn Biquad(testArray)
end

@testset "eqAPOstring(x::FilterCoefficients)" begin
    @test_nowarn eqAPOstring(Biquad(1,2,3,4,5))
    @test_nowarn eqAPOstring(LP(fTest, Qtest))
    @test_nowarn eqAPOstring(PK(fTest, dbGainTest, Qtest)*AP(fTest, Qtest))
end
