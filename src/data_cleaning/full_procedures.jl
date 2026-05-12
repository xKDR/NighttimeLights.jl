"""
Internal shared pipeline for all cleaning procedures.
"""
function _clean_pipeline(radiance_datacube, ncfobs_datacube; noise=nothing, bgthreshold=0.4, do_bias_correction=false, handle_all_missing=false)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    tmp = replace_negative(tmp)

    if isnothing(noise)
        noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, bgthreshold)
    end
    tmp = apply_mask(tmp, noise)

    # outlier_variance may fail if data is too sparse
    mask = noise
    try
        stable_pixels = outlier_variance(tmp, noise)
        tmp = apply_mask(tmp, stable_pixels)
        mask = noise .* stable_pixels
        GC.gc()
    catch e
        @warn "outlier_variance failed, using all pixels as stable" exception=(e, catch_backtrace())
    end

    tmp = long_apply(outlier_hampel, tmp)

    if do_bias_correction
        tmp = bias_PSTT2021(tmp, ncfobs_datacube, mask)
        GC.gc()
    end

    if handle_all_missing && length(unique(tmp)) == 1
        tmp = Raster(zeros(size(tmp)), dims(radiance_datacube))
        return tmp
    end

    tmp = long_apply(na_interp_linear, tmp)
    return tmp
end

"""
All steps of data cleaning that most researchers do can be performed using the conventional cleaning funciton.

```julia
PSTT2021_conventional(radiance_datacube, ncfobs_datacube)
```
"""
function PSTT2021_conventional(radiance_datacube, ncfobs_datacube; bgthreshold = 0.4)
    return _clean_pipeline(radiance_datacube, ncfobs_datacube; bgthreshold=bgthreshold, do_bias_correction=false)
end

"""
The PSTT2021 function performs all the steps of the new cleaning procedure described in [But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds, Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas](https://www.xkdr.org/releases/PatnaikShahTayalThomas_2021_bias_PSTT2021_nighttime_lights.html) as conventional cleaning.

It can optionally accept a pre-computed `noise` mask.

```julia
PSTT2021(radiance_datacube, ncfobs_datacube; noise=nothing, bgthreshold=0.4)
```
"""
function PSTT2021(radiance_datacube, ncfobs_datacube; noise = nothing, bgthreshold = 0.4)
    return _clean_pipeline(radiance_datacube, ncfobs_datacube; noise=noise, bgthreshold=bgthreshold, do_bias_correction=true)
end

"""
The function `clean_complete()` represents our views on an optimal set of steps for pre-
processing in the future (for the period for which this package is actively maintained). As
of today, it is identical to `PSTT2021()`.

It can optionally accept a pre-computed `noise` mask.
"""
function clean_complete(radiance_datacube, ncfobs_datacube; noise = nothing, bgthreshold = 0.4)
    return _clean_pipeline(radiance_datacube, ncfobs_datacube; noise=noise, bgthreshold=bgthreshold, do_bias_correction=true, handle_all_missing=true)
end
