# Quickstart

## Installation

```
]add https://github.com/Firionus/EqualizerFilters.jl
```

Start using the package with

```
using EqualizerFilters
```

## Sample Rate

The default sample rate is 48 kHz. To set a different sample rate of 96 kHz use

```
EqualizerFilters.sampling_rate(96e3)
```

You can always check the current sample rate with

```
EqualizerFilters.sampling_rate()
```

## Filters

To get the Biquad filter corresponding to a 6 dB low shelf of Q 0.707 at 60 Hz use:

```
LS(60, 6, .707)
```

Chaining the filters into SecondOrderSections, for example with an additional peaking filter, is no problem:

```
LS(60, 6, .707)*PK(9e3, -5, 2)
```

You could convert these filters into Equalizer APO configuration strings by doing:

```
eqAPOstring(LS(60, 6, .707)*PK(9e3, -5, 2))
```

which results in custom coefficient IIR filters.

However you may want to have the EQ APO filters in non-sample rate dependent manner
or more easily adjustable after the fact. For this purpose you can define the filters
in an array of tuples and then convert them to DSP.jl-filters:

```
x = [
  (:LS, 60, 6, .707), (:PK, 9e3, -5, 2)
  ]
SecondOrderSections(x)
```

or to Equalizer APO configuration strings:

```
eqAPOstring(x)
```

For a list of available filters see [Individual Filters](@ref).
