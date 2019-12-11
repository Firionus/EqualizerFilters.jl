using Documenter, EqualizerFilters

makedocs(
sitename="EqualizerFilters.jl",
modules=[EqualizerFilters],
pages = [
    "index.md",
    "IndividualFilters.md",
    "TupleFormat.md",
    "SamplingRateSettings.md"
])

deploydocs(repo="github.com/Firionus/EqualizerFilters.jl.git")
