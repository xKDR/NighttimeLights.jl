# Skip garbage collection for small cubes.
collect_garbage(cube) = length(cube) >= 10_000_000 && GC.gc()

# Returned when nothing survives the noise and stability masks.
dark_result(radiance_datacube) = Raster(zeros(nonmissingtype(eltype(radiance_datacube)), size(radiance_datacube)), dims(radiance_datacube))

"""
All steps of data cleaning that most researchers do can be performed using the conventional cleaning funciton.

```julia
PSTT2021_conventional(radiance_datacube, ncfobs_datacube)
```
"""
function PSTT2021_conventional(radiance_datacube, ncfobs_datacube; bgthreshold = 4)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    collect_garbage(radiance_datacube)
    tmp =  replace_negative(tmp)
    collect_garbage(radiance_datacube)
    noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, bgthreshold)
    collect_garbage(radiance_datacube)
    tmp = apply_mask(tmp, noise)
    collect_garbage(radiance_datacube)

    # Default value for stable_pixels - will be overwritten if outlier_variance succeeds
    stable_pixels = ones(Int8, size(tmp)[1], size(tmp)[2])

    try
        stable_pixels = outlier_variance(tmp, noise)
        collect_garbage(radiance_datacube)
    catch e
        @warn "outlier_variance failed, using all pixels as stable" exception=(e, catch_backtrace())
        # stable_pixels is already set to a default value above
    end
    tmp = apply_mask(tmp, stable_pixels)
    collect_garbage(radiance_datacube)
    # Nothing survived the two masks (see `PSTT2021`).
    all(ismissing, tmp) && return dark_result(radiance_datacube)
    tmp = long_apply(outlier_hampel, tmp)
    collect_garbage(radiance_datacube)
    tmp = long_apply(na_interp_linear, tmp)
    collect_garbage(radiance_datacube)
    return tmp
end
"""
The PSTT2021 function performs all the steps of the new cleaning procedure described in [But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds, Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas](https://www.xkdr.org/releases/PatnaikShahTayalThomas_2021_bias_PSTT2021_nighttime_lights.html) as conventional cleaning.

It can optionally accept a pre-computed `noise` mask.

```julia
PSTT2021(radiance_datacube, ncfobs_datacube; noise=nothing, bgthreshold=4)
```
"""
function PSTT2021(radiance_datacube, ncfobs_datacube; noise = nothing, bgthreshold = 4)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    collect_garbage(radiance_datacube)
    tmp = replace_negative(tmp)
    collect_garbage(radiance_datacube)
    if isnothing(noise)
        noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, bgthreshold)
    end
    collect_garbage(radiance_datacube)
    tmp = apply_mask(tmp, noise)
    collect_garbage(radiance_datacube)

    # Default value for stable_pixels - will be overwritten if outlier_variance succeeds
    stable_pixels = ones(Int8, size(tmp)[1], size(tmp)[2])

    try
        stable_pixels = outlier_variance(tmp, noise)
        collect_garbage(radiance_datacube)
    catch e
        @warn "outlier_variance failed, using all pixels as stable" exception=(e, catch_backtrace())
        # stable_pixels is already set to a default value above
    end
    tmp = apply_mask(tmp, stable_pixels)
    collect_garbage(radiance_datacube)
    # Nothing survived the two masks: no pixel is lit above background, or every lit pixel
    # was dropped as unstable (with a single lit pixel, the 99.9th percentile of the standard
    # deviations is that pixel's own, so it fails `std < threshold`). The cube now has eltype
    # `Missing`, which the later steps cannot write into, so return zeros here.
    all(ismissing, tmp) && return dark_result(radiance_datacube)
    tmp = long_apply(outlier_hampel, tmp)
    collect_garbage(radiance_datacube)
    mask = noise .* stable_pixels
    collect_garbage(radiance_datacube)
    tmp = bias_PSTT2021(tmp, ncfobs_datacube, mask)
    collect_garbage(radiance_datacube)
    tmp = long_apply(na_interp_linear, tmp)
    collect_garbage(radiance_datacube)
    return tmp
end


"""
The function `clean_complete()` represents our views on an optimal set of steps for pre-
processing in the future (for the period for which this package is actively maintained). As
of today, it is identical to `PSTT2021()`.

It can optionally accept a pre-computed `noise` mask.
"""
function clean_complete(radiance_datacube, ncfobs_datacube; noise = nothing, bgthreshold = 4)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    collect_garbage(radiance_datacube)
    tmp = replace_negative(tmp)
    collect_garbage(radiance_datacube)
    if isnothing(noise)
        noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, bgthreshold)
        collect_garbage(radiance_datacube)
        tmp = apply_mask(tmp, noise)
        collect_garbage(radiance_datacube)
    else
        tmp = apply_mask(tmp, noise)
        collect_garbage(radiance_datacube)
    end
    mask = noise
    # Default value for stable_pixels - will be overwritten if outlier_variance succeeds
    try
        stable_pixels = outlier_variance(tmp, noise)
        tmp = apply_mask(tmp, stable_pixels)
        collect_garbage(radiance_datacube)
        mask = noise .* stable_pixels
    catch e
        @warn "outlier_variance failed, using all pixels as stable" exception=(e, catch_backtrace())
        # stable_pixels is already set to a default value above
    end

    collect_garbage(radiance_datacube)
    # Nothing survived the two masks (see `PSTT2021`).
    all(ismissing, tmp) && return dark_result(radiance_datacube)
    tmp = long_apply(outlier_hampel, tmp)
    collect_garbage(radiance_datacube)
    tmp = bias_PSTT2021(tmp, ncfobs_datacube, mask)
    collect_garbage(radiance_datacube)
    tmp = long_apply(na_interp_linear, tmp)
    collect_garbage(radiance_datacube)
    return tmp
end
"""
`PSTT2021_lowmem` runs exactly the same cleaning as `PSTT2021`, but keeps the datacube in
`Float16` while it is being cleaned, which lowers peak memory. It differs from `PSTT2021` only
at the two ends:

- On the way in, radiance above `ceiling` is marked `missing` (see `replace_above`) and the
  cube is converted to `Float16` in the same pass. The ceiling is what makes the conversion
  safe: a fill value left live by a file with no nodata tag would otherwise become `Inf`.
- On the way out, the cleaned cube is converted to `T`, `Float32` by default. `Float16` holds
  no number above 65504, and a single month of a city sums past that, so a `Float16` cube must
  never reach `Rasters.zonal` or any other aggregation. Converting here costs nothing, because
  peak memory is reached in the middle of the pipeline and not at the end. Pass `T = Float16`
  only if the result is going straight to disk.

```julia
cleaned_datacube = PSTT2021_lowmem(radiance_datacube, ncfobs_datacube)
```
"""
function PSTT2021_lowmem(radiance_datacube, ncfobs_datacube; noise = nothing, bgthreshold = 4, ceiling = 8000, T = Float32)
    tmp = replace_above(radiance_datacube, ceiling; T = Float16)
    collect_garbage(radiance_datacube)
    tmp = PSTT2021(tmp, ncfobs_datacube; noise = noise, bgthreshold = bgthreshold)
    collect_garbage(radiance_datacube)
    # Keep the cube's own missing-ness: the all-missing branch of PSTT2021 returns a plain cube.
    eltype_out = Missing <: eltype(tmp) ? Union{Missing, T} : T
    return rebuild(tmp; data = Array{eltype_out}(parent(tmp)))
end
