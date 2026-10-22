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
