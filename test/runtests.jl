using NighttimeLights
using Test
using Dates
using DataFrames
using Logging
using Random
using Rasters
using SparseArrays
using Statistics
using Supposition, Supposition.Data

# Progress lines: the last one before a hang says where it stuck.
steplog(msg...) = (println(stdout, "[step ", Dates.format(now(), "HH:MM:SS"), "] ", msg...); flush(stdout))

# DefaultTestSet that logs each testset's start and end and each result as it is recorded.
# Nested testsets inherit the type, so only the top-level one names it.
mutable struct LoggedTestSet <: Test.AbstractTestSet
    inner::Test.DefaultTestSet
    start::Float64
end
function LoggedTestSet(desc; kw...)
    steplog("start testset \"", desc, "\"")
    LoggedTestSet(Test.DefaultTestSet(desc; kw...), time())
end
function Test.record(ts::LoggedTestSet, r::Test.Result)
    src = hasproperty(r, :source) && r.source isa LineNumberNode ? string(basename(string(r.source.file)), ":", r.source.line) : "?"
    if r isa Test.Pass
        steplog("pass ", src)
    else
        expr = first(string(r.orig_expr, r isa Test.Error ? " threw " * r.value : ""), 300)
        steplog(r isa Test.Broken ? "broken " : "FAIL ", src, " in \"", ts.inner.description, "\": ", expr)
    end
    Test.record(ts.inner, r)
end
Test.record(ts::LoggedTestSet, child::Test.AbstractTestSet) = Test.record(ts.inner, child)
function Test.finish(ts::LoggedTestSet)
    steplog("end testset \"", ts.inner.description, "\" (", round(time() - ts.start; digits = 1), "s)")
    Test.finish(ts.inner)
end

include("generators.jl")

steplog("loading example data")
load_example()

@testset LoggedTestSet "NighttimeLights" begin
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
