const pipelines = (PSTT2021_conventional, PSTT2021, clean_complete, PSTT2021_lowmem)

# Generated cubes flood the output with outlier_variance failures
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
    # single pixel: outlier_variance drops it
    noise = Array{Union{Missing, Int8}}(missing, size(radiance_datacube)[1:2])
    noise[argmax(dropdims(sum(Array(ncfobs_datacube); dims=3); dims=3))] = 1
    @test all(iszero, PSTT2021(radiance_datacube, ncfobs_datacube; noise = noise))
end

Logging.disable_logging(Logging.BelowMinLevel)
