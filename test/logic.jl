# logic tests: statistical bounds on synthetic data from a stand-in cloud model (see sum.md)

# seasonal clouds: 1 at the July monsoon peak, 0 in January
cloudiness(k) = (1 + cos(2pi * (k - 7) / 12)) / 2
# ncfobs ~6 in July, ~28 in January
cloud_free_days(rng, k) = clamp(round(Int, 28 - 22 * cloudiness(k)) + rand(rng, -2:2), 1, 30)
# radiance factor: 1 at ncfobs = 30, 1 - depth at 0
dimming(ncf, depth) = 1 - depth * (1 - ncf / 30)

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

# generated cubes flood the output with outlier_variance failures
Logging.disable_logging(Logging.Warn)

const corrected = (PSTT2021, clean_complete, PSTT2021_lowmem)

# dirty seasonal scenes with a known answer: clouds dim lit pixels seasonally, pipelines must recover the truth
const scene_size = (4, 4, 72)

const flare = CartesianIndex(4, 4)
lit_pixels() = filter(ij -> ij[1] > 1 && ij != flare, CartesianIndices(scene_size[1:2]))

# base levels, yearly growth, dimming depth, noise seed
const scene_params = map(tuple, Data.Vectors(floats(10.0, 60.0); min_size = 16, max_size = 16),
                         floats(0.0, 0.1), floats(0.2, 0.5), Data.Integers(0, 10^6))

# row 1 dark, `flare` jumps 0-500, lit pixels get ncfobs = 0 gaps (fill -3) and 5x spikes
function dirty_scene((base, growth, depth, seed))
    rng = Xoshiro(seed)
    nx, ny, nt = scene_size
    ncf = [cloud_free_days(rng, k) for _ in 1:nx, _ in 1:ny, k in 1:nt]
    truth = [base[i + nx * (j - 1)] * (1 + growth * (k - 1) / 12) for i in 1:nx, j in 1:ny, k in 1:nt]
    rad = as_missable(truth .* dimming.(ncf, depth) .* (1 .+ 0.03 .* randn(rng, nx, ny, nt)))
    rad[1, :, :] = randn(rng, ny, nt)
    rad[flare, :] = 500 .* rand(rng, nt)
    lit = lit_pixels()
    # spikes away from the ends, outside the Hampel window
    spikes = unique([CartesianIndex(rand(rng, lit).I..., rand(rng, 13:nt - 12)) for _ in 1:8])
    gaps = setdiff(unique([CartesianIndex(rand(rng, lit).I..., rand(rng, 1:nt)) for _ in 1:30]), spikes)
    for s in spikes
        rad[s] *= 5
    end
    for g in gaps
        ncf[g] = 0
        rad[g] = -3.0
    end
    return (rad = as_raster(rad), ncf = as_raster(ncf), truth, gaps, spikes)
end

# range of detrended month-of-year means, relative to level
function seasonal_amplitude(ts)
    d = NighttimeLights.detrend_ts(collect(Float64, ts))
    m = [mean(d[k:12:end]) for k in 1:12]
    (maximum(m) - minimum(m)) / mean(ts)
end
relative_error(out, truth) = median(abs.(out .- truth) ./ truth)
# yearly growth from a straight-line fit, share of starting level
function growth_rate(ts)
    fit = ts .- NighttimeLights.detrend_ts(collect(Float64, ts))
    (fit[end] - fit[1]) / fit[1] * 12 / (length(ts) - 1)
end
# single pixels too noisy for tight bounds
over_lit(f) = median(f(ij) for ij in lit_pixels())


@testset "pipelines on dirty seasonal scenes" begin
    @property max_examples=COSTLY function bias_correction_removes_seasonality(p = scene_params)
        s = dirty_scene(p)
        observed = s.truth .* dimming.(Array(s.ncf), p[3])
        share(out) = over_lit(ij -> seasonal_amplitude(out[ij, :]) / seasonal_amplitude(observed[ij, :]))
        # conventional keeps the seasonality
        share(Array(PSTT2021_conventional(copy(s.rad), s.ncf))) > 0.8 &&
            all(clean -> share(Array(clean(copy(s.rad), s.ncf))) < 0.4, corrected)
    end

    @property max_examples=COSTLY function recovers_true_lights(p = scene_params)
        s = dirty_scene(p)
        conventional = Array(PSTT2021_conventional(copy(s.rad), s.ncf))
        all(corrected) do clean
            out = Array(clean(copy(s.rad), s.ncf))
            all(lit_pixels()) do ij
                err = relative_error(out[ij, :], s.truth[ij, :])
                err < 0.08 && err < 0.6 * relative_error(conventional[ij, :], s.truth[ij, :])
            end
        end
    end

    # level lifted, absolute trend kept: growth understated by up to the dimming depth
    @property max_examples=COSTLY function keeps_long_run_growth(p = scene_params)
        _, growth, depth, _ = p
        s = dirty_scene(p)
        out = Array(PSTT2021(copy(s.rad), s.ncf))
        growth * (1 - depth) - 0.015 <= over_lit(ij -> growth_rate(out[ij, :])) <= growth + 0.015
    end

    @property max_examples=COSTLY function cleans_the_dirt(p = scene_params)
        s = dirty_scene(p)
        dimmed = s.truth .* dimming.(Array(s.ncf), p[3])
        all((PSTT2021_conventional, corrected...)) do clean
            out = Array(clean(copy(s.rad), s.ncf))
            # conventional keeps the dimming
            ref = clean === PSTT2021_conventional ? dimmed : s.truth
            err(ijk) = abs(out[ijk] - ref[ijk]) / s.truth[ijk]
            # spike left in: 400% off; gap left unfilled: 100%+
            !any(ismissing, out) && all(>=(0), out) &&
                all(iszero, out[1, :, :]) && all(iszero, out[flare, :]) &&
                all(<(0.5), err.(s.spikes)) && median(err.(s.spikes)) < 0.1 &&
                # conventional fills gaps from dimmed neighbours, not comparable
                (clean === PSTT2021_conventional || (all(<(0.5), err.(s.gaps)) && median(err.(s.gaps)) < 0.1))
        end
    end
end

Logging.disable_logging(Logging.BelowMinLevel)
