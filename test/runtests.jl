# Taken from https://github.com/JuliaData/DataFrames.jl/blob/main/test/runtests.jl
using NighttimeLights
using Test
using Dates
using DataFrames

fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
quiet = length(ARGS) > 0 && ARGS[1] == "-q"
anyerrors = false

my_tests = ["aggregate.jl", "coordinate_system.jl", "coordinate_conversion.jl", "data_io.jl", "f_apply.jl", "mask_area.jl", "polygons.jl",

"data_cleaning/background_noise_removal.jl", "data_cleaning/bias_correction.jl", "data_cleaning/interpolation.jl", "data_cleaning/mark_nan.jl", "data_cleaning/outlier_removal.jl", "data_cleaning/full_procedures.jl",

"other/detrend.jl", "other/nan_functions.jl", "other/rank_correlation.jl", "other/weighted_mean.jl"]

println("Running tests:")

for my_test in my_tests
    try
        include(my_test)
        println("\t\033[1m\033[32mPASSED\033[0m: $(my_test)")
    catch e
        global anyerrors = true
        println("\t\033[1m\033[31mFAILED\033[0m: $(my_test)")
        if fatalerrors
            rethrow(e)
        elseif !quiet
            showerror(stdout, e, backtrace())
            println()
        end
    end
end

if anyerrors
    throw("Tests failed")
end