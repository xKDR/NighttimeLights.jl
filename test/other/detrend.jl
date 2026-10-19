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
