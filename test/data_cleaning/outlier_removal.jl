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

    # a wild pixel more than 90% missing is skipped, so kept
    cube = as_missable(10.0 .+ randn(Xoshiro(6), 3, 3, 72))
    cube[2, 2, :] .= missing
    cube[2, 2, 1:6] = [0.0, 500.0, 0.0, 500.0, 0.0, 500.0]
    @test isequal(outlier_variance(as_raster(cube))[2, 2], 1)
end

# clean dimmed series: level 10-60, growth 0-10%/year, depth 0.2-0.5, 3% relative noise
function seasonal_series(rng; n = 72)
    L, g, depth = 10 + 50 * rand(rng), 0.1 * rand(rng), 0.2 + 0.3 * rand(rng)
    ncf = cloud_free_days.(rng, 1:n)
    (; y = as_missable(L .* (1 .+ g .* (0:n-1) ./ 12) .* dimming.(ncf, depth) .* (1 .+ 0.03 .* randn(rng, n))), ncf)
end
flagged(y) = ismissing.(outlier_hampel(y))

@testset "hampel on seasonal series" begin
    rng = Xoshiro(10)
    series = [seasonal_series(rng) for _ in 1:2000]
    # cloudy months are real data: few flags, and no more in cloudy months
    flags = flagged.(getproperty.(series, :y))
    @test mean(mean.(flags)) < 0.005
    @test mean(vcat((f[s.ncf .<= 10] for (f, s) in zip(flags, series))...)) < 0.005

    spiked(s, at, k) = (y = copy(s.y); y[at] *= k; flagged(y)[at])
    @test all(s -> spiked(s, rand(rng, 5:67), 5), series[1:500])
    @test mean(s -> spiked(s, rand(rng, 5:67), 2), series[1:500]) > 0.8
    # documented: the first 4 and last 5 months are not checked, so spikes there stay
    @test !any(at -> any(s -> spiked(s, at, 5), series[1:50]), [1:4; 68:72])

    # a lasting level shift (e.g. electrification) is not a spike
    shifted = map(series[1:500]) do s
        y = copy(s.y)
        y[37:end] .*= 1.5
        count(flagged(y)[30:44])
    end
    @test mean(shifted) < 0.1
end

# 40x25 = 1000 lit pixels, lognormal levels 5-~200, one depth per scene
function city_scene(rng; nx = 40, ny = 25, nt = 72)
    L = 5 .+ 20 .* exp.(0.8 .* randn(rng, nx, ny))
    depth = 0.2 + 0.3 * rand(rng)
    ncf = [cloud_free_days(rng, k) for _ in 1:nx, _ in 1:ny, k in 1:nt]
    (; rad = as_missable([L[i, j] * dimming(ncf[i, j, k], depth) * (1 + 0.03 * randn(rng)) for i in 1:nx, j in 1:ny, k in 1:nt]), L)
end

@testset "outlier_variance on city scenes" begin
    rng = Xoshiro(11)
    # one flare in 1000 pixels is the top 0.1%: it is dropped and nothing else
    @test all(1:50) do _
        s = city_scene(rng)
        s.rad[7, 7, :] = 500 .* rand(rng, 72)
        dropped = ismissing.(outlier_variance(as_raster(s.rad)))
        dropped[7, 7] && count(dropped) == 1
    end
    # no flare: the cutoff still drops the top 0.1%, usually the brightest pixel; bound the light lost
    lost = map(1:50) do _
        s = city_scene(rng)
        sum(s.L[ismissing.(outlier_variance(as_raster(s.rad)))]) / sum(s.L)
    end
    @test median(lost) < 0.015 && maximum(lost) < 0.03
end
