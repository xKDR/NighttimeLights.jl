@testset "bgnoise_PSTT2021" begin
    @property max_examples=CHEAP function lit_iff_last_year_mean_above_threshold(c = cubes(maybe_missing(floats(0.0, 10.0)), ncfobs()),
                                                                              th = floats(0.0, 10.0))
        rad, ncf = c
        mask = bgnoise_PSTT2021(as_raster(rad), as_raster(ncf), th)
        last_year = size(rad, 3)-11:size(rad, 3)
        all(CartesianIndices(mask)) do ij
            lit = NighttimeLights.weighted_mean(rad[ij, last_year], ncf[ij, last_year]) > th
            isequal(mask[ij], lit ? 1 : missing)
        end
    end

    @property max_examples=CHEAP function ignores_earlier_months(c = cubes(radiance(), ncfobs(), radiance()))
        rad, ncf, other = c
        changed = copy(rad)
        changed[:, :, 1:end-12] = other[:, :, 1:end-12]
        isequal(bgnoise_PSTT2021(as_raster(rad), as_raster(ncf)), bgnoise_PSTT2021(as_raster(changed), as_raster(ncf)))
    end
end

# 80% dark with airglow (level 0.5-3, sd 1, some negative), lit pixels level 10-60 and dimmed
function airglow_scene(rng; nx = 20, ny = 20, nt = 72)
    lit = rand(rng, nx, ny) .> 0.8
    L, glow, depth = 10 .+ 50 .* rand(rng, nx, ny), 0.5 .+ 2.5 .* rand(rng, nx, ny), 0.2 + 0.3 * rand(rng)
    ncf = [cloud_free_days(rng, k) for _ in 1:nx, _ in 1:ny, k in 1:nt]
    dimmed = [lit[i, j] * L[i, j] * dimming(ncf[i, j, k], depth) for i in 1:nx, j in 1:ny, k in 1:nt]
    rad = [lit[i, j] ? dimmed[i, j, k] * (1 + 0.03 * randn(rng)) : glow[i, j] + randn(rng) for i in 1:nx, j in 1:ny, k in 1:nt]
    (; rad = as_missable(rad), ncf, lit, dimmed)
end

@testset "bgnoise on airglow scenes" begin
    rng = Xoshiro(12)
    scenes = [airglow_scene(rng) for _ in 1:50]
    masks = [Array(bgnoise_PSTT2021(as_raster(s.rad), as_raster(s.ncf))) for s in scenes]
    @test all(((s, m),) -> isequal(.!ismissing.(m), s.lit), zip(scenes, masks))
    # airglow inflates the regional mean; masking brings it back to the lights
    bias(x, s) = mean(x) / mean(s.dimmed) - 1
    @test all(s -> bias(s.rad, s) > 0.1, scenes)
    @test all(((s, m),) -> abs(bias(coalesce.(m .* s.rad, 0.0), s)) < 0.005, zip(scenes, masks))
end
