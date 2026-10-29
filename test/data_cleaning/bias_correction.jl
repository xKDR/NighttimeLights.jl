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

    # radiance rises with ncfobs, so it is corrected, unless more than 90% is missing
    ncf = reshape(rand(Xoshiro(5), 1:30, 72), 1, 1, 72)
    gappy(n) = (rad = as_missable(10.0 .+ Float64.(ncf)); rad[1, 1, end-n+1:end] .= missing; rad)
    corrected_with(n) = !isequal(Array(bias_PSTT2021(as_raster(gappy(n)), as_raster(ncf))), gappy(n))
    @test corrected_with(50) && !corrected_with(66)
end

# seeded Monte Carlo; pixel function called directly, so no masks involved 
const n_pixels = 500
slope(y) = (fit = y .- NighttimeLights.detrend_ts(collect(Float64, y)); (fit[end] - fit[1]) / (length(y) - 1))

# level 10-60, growth 0-10%/year, depth 0.2-0.5, noise sigma = 3% of level
function dimmed_pixels(seed; growth = true)
    rng = Xoshiro(seed)
    map(1:n_pixels) do _
        L, g, depth = 10 + 50 * rand(rng), growth ? 0.1 * rand(rng) : 0.0, 0.2 + 0.3 * rand(rng)
        ncf = cloud_free_days.(rng, 1:72)
        truth = L .* (1 .+ g .* (0:71) ./ 12)
        sigma = 0.03 * L
        y = truth .* dimming.(ncf, depth) .+ sigma .* randn(rng, 72)
        (; truth, y, out = NighttimeLights.bias_PSTT2021_pixel(copy(y), ncf), ncf, sigma, L)
    end
end

@testset "bias correction on dimmed noisy pixels" begin
    px = dimmed_pixels(1; growth = false)
    # share of the dimming bias removed
    fixed = [(mean(p.out) - mean(p.y)) / (mean(p.truth) - mean(p.y)) for p in px]
    @test all(p -> mean(p.out) > mean(p.y), px)
    @test 0.8 < median(fixed) < 1.0
    @test quantile(fixed, 0.01) > 0.5
    # no overshoot beyond the noise
    @test count(p -> mean(p.out) > mean(p.truth) + 2 * p.sigma, px) <= 0.01 * n_pixels

    # cloudy months raised, clear months barely
    @test median(NighttimeLights.corspearman(p.out .- p.y, Float64.(p.ncf)) for p in px) < -0.8
    @test all(px) do p
        change = p.out .- p.y
        mean(change[p.ncf .<= 10]) > 5 * mean(abs.(change[p.ncf .>= 28]))
    end

    # absolute slope kept (yearly, share of level); fast growers lose a little, likely (unverified) from the cap at observed max
    px = dimmed_pixels(2)
    slope_change = [12 * (slope(p.out) - slope(p.y)) / p.L for p in px]
    @test abs(median(slope_change)) < 0.005
    @test quantile(slope_change, 0.05) > -0.03 && maximum(slope_change) < 0.02
end

@testset "bias correction on pure noise" begin
    rng = Xoshiro(3)
    # no dimming: noise unrelated to cloud cover
    nx, ny, nt = 20, 25, 72
    ncf = [cloud_free_days(rng, k) for _ in 1:nx, _ in 1:ny, k in 1:nt]
    rad = as_missable(20 .+ 0.6 .* randn(rng, nx, ny, nt))
    out = bias_PSTT2021(as_raster(copy(rad)), as_raster(ncf))
    # ~5% pass the rank-correlation test by chance
    @test count(ij -> !isequal(out[ij, :], rad[ij, :]), CartesianIndices((nx, ny))) < 0.08 * nx * ny

    # forced on noise, lifting to the spline top adds ~0.4sigma
    lift = map(CartesianIndices((nx, ny))) do ij
        y = collect(Float64, rad[ij, :])
        (mean(NighttimeLights.bias_PSTT2021_pixel(copy(y), ncf[ij, :])) - mean(y)) / 0.6
    end
    @test 0.2 < median(lift) < 0.7
    @test all(<(2.5), lift)
end
