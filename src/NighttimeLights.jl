module NighttimeLights

using Rasters, DataFrames, Shapefile, StatsBase, SmoothingSplines, GLM, Distributions, HypothesisTests, Plots, Dates, DimensionalData, CubicSplines

## Utilities 
export Raster, load_example, radiance_datacube, clouds_datacube, long_apply, apply_mask, mumbai_map, add_dim, annular_ring, centre_of_mass

## cleaning methods
export background_noise_mask, PSTT2021_biascorrect, PSTT2021_conventional, PSTT2021, clean_complete, linear_interpolation, mark_missing, outlier_mask, outlier_ts, replace_negative

include("other/detrend.jl")
include("f_apply.jl")
include("other/rank_correlation.jl")
include("other/weighted_mean.jl")
include("data_cleaning/background_noise_removal.jl")
include("data_cleaning/outlier_removal.jl")
include("data_cleaning/bias_correction.jl")
include("data_cleaning/interpolation.jl")
include("data_cleaning/mark_missing.jl")
include("data_cleaning/full_procedures.jl")
include("data_cleaning/replace_negative.jl")
include("example.jl")
include("other/date_to_int.jl")
include("other/add_dim.jl")
include("other/rings.jl")
include("other/com.jl")
end
