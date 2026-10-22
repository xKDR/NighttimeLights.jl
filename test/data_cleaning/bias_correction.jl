@testset "bias_PSTT2021_pixel" begin
    @property max_examples=COSTLY function never_raises_above_observed_max(c = cubes(maybe_missing(floats(1.0, 100.0), 10), ncfobs();
                                                                                dims = map(n -> (1, 1, n), Data.Integers(24, 72)), max_size = 72))
        rad, ncf = vec.(c)
        assume!(count(!ismissing, rad) >= 3)
        out = NighttimeLights.bias_PSTT2021_pixel(rad, ncf)
        length(out) == length(rad) &&
            isequal(ismissing.(out), ismissing.(rad)) &&
            all(<=(maximum(skipmissing(rad))), skipmissing(out))
    end
end

@testset "bias_PSTT2021" begin
    @property max_examples=COSTLY function corrects_only_eligible_pixels(c = cubes(maybe_missing(floats(1.0, 100.0), 10), ncfobs(),
                                                                                Data.SampledFrom([1, missing])))
        rad, ncf, m = c
        mask = m[:, :, 1]
        out = bias_PSTT2021(as_raster(copy(rad)), as_raster(ncf), mask)
        all(CartesianIndices(mask)) do ij
            ts = rad[ij, :]
            eligible = !ismissing(mask[ij]) && count(ismissing, ts) <= 0.9 * length(ts) &&
                NighttimeLights.rank_correlation_test(collect(skipmissing(ts)), ncf[ij, :][.!ismissing.(ts)]) < 0.05
            isequal(out[ij, :], eligible ? NighttimeLights.bias_PSTT2021_pixel(ts, ncf[ij, :]) : ts)
        end
    end
end
