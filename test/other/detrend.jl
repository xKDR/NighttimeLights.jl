@testset "detrend_ts" begin
    @property max_examples=CHEAP function removes_a_linear_trend(a = floats(-100.0, 100.0), b = floats(-10.0, 10.0), n = Data.Integers(2, 120))
        t = (0:n-1) ./ 12
        isapprox(NighttimeLights.detrend_ts(a .+ b .* t), zeros(n); atol = 1e-8)
    end

    @property max_examples=CHEAP function residuals_have_zero_mean(ts = Data.Vectors(radiance(); min_size = 2, max_size = 120))
        out = NighttimeLights.detrend_ts(ts)
        length(out) == length(ts) && abs(mean(out)) <= 1e-8 * max(1, maximum(abs, ts))
    end

    @property max_examples=CHEAP function keeps_missing_positions(ts = gappy_series(radiance(); min_size = 3))
        assume!(count(!ismissing, ts) >= 2)
        isequal(ismissing.(NighttimeLights.detrend_ts(ts)), ismissing.(ts))
    end
end

@testset "detrend_ts keeps seasonality" begin
    # cosine symmetric within each year: no linear part of its own over whole years, so kept exactly
    @property max_examples=CHEAP function keeps_seasonality(a = floats(-100.0, 100.0), b = floats(-10.0, 10.0),
                                                            amp = floats(1.0, 50.0), years = Data.Integers(2, 10))
        k = 1:12 * years
        season = amp .* cos.(2pi .* (k .- 6.5) ./ 12)
        out = NighttimeLights.detrend_ts(a .+ b .* (k .- 1) ./ 12 .+ season)
        isapprox(out, season; atol = 1e-8 * (abs(a) + abs(b) * years + amp))
    end

    # gaps break the symmetry and the fit absorbs part of the cycle, but adding a line changes nothing
    @property max_examples=CHEAP function trend_is_removed_with_gaps(a = floats(-100.0, 100.0), b = floats(-10.0, 10.0), amp = floats(1.0, 50.0),
                                                                     gaps = Data.Vectors(Data.Integers(1, 72); max_size = 40))
        k = 1:72
        season = as_missable(amp .* cos.(2pi .* (k .- 6.5) ./ 12))
        season[gaps] .= missing
        assume!(count(!ismissing, season) >= 2)
        out = NighttimeLights.detrend_ts(a .+ b .* (k .- 1) ./ 12 .+ season)
        isequal(ismissing.(out), ismissing.(season)) &&
            isapprox(collect(skipmissing(out)), collect(skipmissing(NighttimeLights.detrend_ts(season))); atol = 1e-8 * (abs(a) + abs(b) * 6 + amp))
    end
end
