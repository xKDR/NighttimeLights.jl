@testset "outlier_hampel" begin
    @property max_examples=CHEAP function only_adds_missings(ts = gappy_series(radiance()))
        out = outlier_hampel(ts)
        length(out) == length(ts) &&
            all(i -> ismissing(out[i]) || isequal(out[i], ts[i]), eachindex(ts))
    end

    @property max_examples=CHEAP function keeps_constant_series(c = radiance(), n = Data.Integers(1, 60))
        isequal(outlier_hampel(fill(c, n)), fill(c, n))
    end

    @property max_examples=CHEAP function removes_a_spike(ts = Data.Vectors(floats(5.0, 15.0); min_size = 12, max_size = 60),
                                                      at = Data.Integers(5, 7))
        spiked = copy(ts)
        spiked[at] = 1000.0
        ismissing(outlier_hampel(spiked)[at])
    end
end

@testset "outlier_variance" begin
    @property max_examples=CHEAP function masks_only_lit_pixels(cm = cubes(maybe_missing(radiance()), Data.SampledFrom([1, missing])),
                                                             cutoff = floats(0.01, 1.0))
        cube, m = cm
        mask = m[:, :, 1]
        assume!(any(!ismissing, mask))
        out = outlier_variance(as_raster(cube), mask; cutoff)
        all(x -> isequal(x, 1) || ismissing(x), out) && all(ismissing, out[ismissing.(mask)])
    end

    @property max_examples=CHEAP function higher_cutoff_keeps_more(c = cubes(maybe_missing(radiance())),
                                                                lo = floats(0.01, 1.0), hi = floats(0.01, 1.0))
        cube = as_raster(only(c))
        lo, hi = minmax(lo, hi)
        kept(cutoff) = .!ismissing.(outlier_variance(cube; cutoff))
        all(kept(lo) .<= kept(hi))
    end
end
