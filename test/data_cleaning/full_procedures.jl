const pipelines = (PSTT2021_conventional, PSTT2021, clean_complete, PSTT2021_lowmem)

# generated cubes flood the output with outlier_variance failures
Logging.disable_logging(Logging.Warn)

@testset "pipelines on generated cubes" begin
    # Float16-exact, so low-memory sees the same input
    rad16 = map(Float64, Data.Floats{Float16}(; nans = false, minimum = -5, maximum = 200))

    @property max_examples=COSTLY function keep_shape_and_leave_no_missing(c = cubes(maybe_missing(rad16, 10), ncfobs()))
        rad, ncf = as_raster.(c)
        all(pipelines) do clean
            out = clean(copy(rad), ncf)
            dims(out) == dims(rad) && !any(ismissing, out)
        end
    end

    @property max_examples=COSTLY function dark_region_is_all_zeros(c = cubes(floats(-5.0, 4.0), ncfobs()))
        rad, ncf = as_raster.(c)
        all(clean -> all(iszero, clean(copy(rad), ncf)), pipelines)
    end

    @property max_examples=COSTLY function lowmem_matches_PSTT2021(c = cubes(maybe_missing(rad16, 10), ncfobs()))
        rad, ncf = as_raster.(c)
        full = PSTT2021(copy(rad), ncf)
        low = PSTT2021_lowmem(copy(rad), ncf)
        nonmissingtype(eltype(low)) == Float32 && isapprox(Array(low), Array(full); rtol = 1e-2, atol = 0.1)
    end

    @property max_examples=COSTLY function noise_keyword_is_used(c = cubes(maybe_missing(rad16, 10), ncfobs(), Data.Integers(0, 1)))
        rad, ncf = as_raster.(c[1:2])
        noise = replace(Int8.(c[3][:, :, 1]), 0 => missing)
        own = bgnoise_PSTT2021(replace_negative(na_recode(rad, ncf)), ncf, 4)
        all((PSTT2021, clean_complete, PSTT2021_lowmem)) do clean
            out = clean(copy(rad), ncf; noise = noise)
            dark = all(ij -> !ismissing(noise[ij]) || all(iszero, out[Tuple(ij)..., :]), CartesianIndices(noise))
            dark && isequal(Array(clean(copy(rad), ncf; noise = own)), Array(clean(copy(rad), ncf)))
        end
    end

    @property max_examples=COSTLY function clean_complete_matches_PSTT2021(c = cubes(maybe_missing(radiance(), 10), ncfobs()))
        rad, ncf = as_raster.(c)
        isequal(Array(clean_complete(copy(rad), ncf)), Array(PSTT2021(copy(rad), ncf)))
    end
end

@testset "pipelines on the Mumbai example" begin
    for clean in pipelines
        @test size(clean(radiance_datacube, ncfobs_datacube)) == size(radiance_datacube)
    end
    @test eltype(PSTT2021_lowmem(radiance_datacube, ncfobs_datacube; T = Float64)) <: Union{Missing, Float64}

    # nothing survives bgnoise mask.
    dark = Raster(zeros(Float32, size(radiance_datacube)), dims(radiance_datacube))
    @test all(iszero, PSTT2021(dark, ncfobs_datacube))
    @test all(iszero, PSTT2021_lowmem(dark, ncfobs_datacube))
    # noise keyword: an all-dark mask gives zeros; a single pixel is dropped by outlier_variance
    noise = Array{Union{Missing, Int8}}(missing, size(radiance_datacube)[1:2])
    for clean in (PSTT2021, clean_complete, PSTT2021_lowmem)
        @test all(iszero, clean(radiance_datacube, ncfobs_datacube; noise = noise))
    end
    noise[argmax(dropdims(sum(Array(ncfobs_datacube); dims=3); dims=3))] = 1
    for clean in (PSTT2021, clean_complete, PSTT2021_lowmem)
        @test all(iszero, clean(radiance_datacube, ncfobs_datacube; noise = noise))
    end
end

@testset "collect_garbage" begin
    # Only the length matters, so a BitArray stands in for a 10-million-cell cube.
    @test NighttimeLights.collect_garbage(falses(9_999_999)) === false
    sweeps = Base.gc_num().full_sweep
    @test NighttimeLights.collect_garbage(falses(10_000_000)) === nothing
    @test Base.gc_num().full_sweep > sweeps
end

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
            # Float16 rounding: lowmem gets a little more room
            ratio = clean === PSTT2021_lowmem ? 0.65 : 0.6
            all(lit_pixels()) do ij
                err = relative_error(out[ij, :], s.truth[ij, :])
                err < 0.08 && err < ratio * relative_error(conventional[ij, :], s.truth[ij, :])
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
