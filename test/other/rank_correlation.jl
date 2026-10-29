@testset "rank_correlation" begin
    # t = r*sqrt((n-2)/(1-r^2)): r = 0.5, n = 72 gives t = 4.8305, one-tailed p = 3.876e-6
    @test isapprox(NighttimeLights.t_test(72, 0.5), 3.876e-6; rtol = 1e-3)

    @property max_examples=CHEAP function t_test_falls_as_r_rises(n = Data.Integers(3, 200), r1 = floats(-0.99, 0.99), r2 = floats(-0.99, 0.99))
        lo, hi = minmax(r1, r2)
        NighttimeLights.t_test(n, lo) >= NighttimeLights.t_test(n, hi)
    end

    @property max_examples=CHEAP function p_value_is_a_probability(c = cubes(maybe_missing(radiance()), ncfobs();
                                                                          dims = map(n -> (1, 1, n), Data.Integers(3, 80)), max_size = 80))
        rad, ncf = vec.(c)
        y = collect(skipmissing(rad))
        assume!(length(y) >= 3 && length(unique(y)) > 1 && length(unique(ncf[.!ismissing.(rad)])) > 1)
        0 <= NighttimeLights.rank_correlation_test(rad, ncf) <= 1
    end
end

@testset "rank_correlation on seasonal cloud cover" begin
    # seeded Monte Carlo, seasonal cloud cover
    rng = Xoshiro(4)
    noisy(depth) = map(1:2000) do _
        ncf = cloud_free_days.(rng, 1:72)
        L = 10 + 50 * rand(rng)
        y = L .* dimming.(ncf, depth) .+ 0.03 * L .* randn(rng, 72)
        NighttimeLights.rank_correlation_test(y, ncf)
    end
    # no dimming: p < 0.05 ~5% of the time (+/-4 sd over 2000 draws)
    @test 0.03 < mean(noisy(0.0) .< 0.05) < 0.07
    # 20% dimming: nearly always detected
    @test mean(noisy(0.2) .< 0.05) > 0.98
end
