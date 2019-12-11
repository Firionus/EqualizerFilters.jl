# Tuple Format

EQ chains can be represented in the tuple format, allowing them to be converted
to DSP.jl-filters as well as sampling rate-independent EQ APO configuration strings.

Possible tuple formats are:

```
([:PK|:LS|:HS], f, dbGain, Q)
([:LP|:HP|:BP|:NO|:AP], f, Q)
([:G|:D|:Ds], parameter)
```

The filter types have the more or less intuitive meanings of:

- `:PK` for peaking filter
- `:LS` for low shelf filter
- `:HS` for high shelf filter
- `:LP` for lowpass filter
- `:HP` for high pass filter
- `:BP` for band pass filter
- `:NO` for notch filter
- `:AP` for all pass filter
- `:G` for gain filter with gain in dB
- `:D` for delay filter with delay in ms
- `:Ds` for delay filter with delay in samples.

Delay Filters cannot be converted to DSP.jl-filters as they do not have a proper
coefficient representation.

The tuples can be arranged in arrays like this:

```
[(:LS, 60, 6, .707), (:PK, 9e3, -5, 2)]
```

The single tuples can be converted to a DSP.jl-Biquad by calling the constructor
`Biquad(tuple)`.

Arrays of Tuples can be converted to DSP.jl-SecondOrderSections
with the constructor `SecondOrderSections(tupleArray)`.

If you want to convert the filter tuple or filter tuple array to the corresponding
string in Equalizer APO configuration file format, use `eqAPOstring(tupleArray)`.

`eqAPOString` can also be used to convert an arbitrary DSP.jl-filter to Equalizer APO
by using second order IIRs with custom coefficients.

## Function Reference

### DSP.jl-filters
```@docs
Biquad
SecondOrderSections
```

### EQ APO config strings

```@docs
eqAPOstring
```
