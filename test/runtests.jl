using NighttimeLights
using Test
using Dates
using DataFrames
using Logging
using Rasters
using SparseArrays
using Statistics
using Supposition, Supposition.Data

include("generators.jl")

load_example()

@testset "NighttimeLights" begin
    files = isempty(ARGS) ? [
        "f_apply.jl",
        "readnl.jl",
        "example.jl",
        "data_cleaning/na_recode.jl",
        "data_cleaning/replace_negative.jl",
        "data_cleaning/interpolation.jl",
        "data_cleaning/outlier_removal.jl",
        "data_cleaning/bgnoise.jl",
        "data_cleaning/bias_correction.jl",
        "data_cleaning/full_procedures.jl",
        "other/weighted_mean.jl",
        "other/detrend.jl",
        "other/rank_correlation.jl",
        "other/com.jl",
        "other/rings.jl",
        "other/date_to_int.jl",
    ] : ARGS
    for file in files
        @testset "$file" begin
            include(file)
        end
    end
end
