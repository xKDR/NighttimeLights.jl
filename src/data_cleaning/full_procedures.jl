"""
All steps of data cleaning that most researchers do can be performed using the conventional cleaning funciton.

```julia
PSTT2021_conventional(radiance_datacube, ncfobs_datacube)
```
"""
function PSTT2021_conventional(radiance_datacube, ncfobs_datacube; bgthreshold = 0.4)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    GC.gc()
    tmp =  replace_negative(tmp)
    GC.gc()
    noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, bgthreshold)
    GC.gc()
    tmp = apply_mask(tmp, noise)
    GC.gc()
    
    # Default value for stable_pixels - will be overwritten if outlier_variance succeeds
    stable_pixels = ones(Int8, size(tmp)[1], size(tmp)[2])
    
    try
        stable_pixels = outlier_variance(tmp, noise)
        GC.gc()
    catch e
        @warn "outlier_variance failed, using all pixels as stable" exception=(e, catch_backtrace())
        # stable_pixels is already set to a default value above
    end
    tmp = apply_mask(tmp, stable_pixels)
    GC.gc()
    tmp = long_apply(outlier_hampel, tmp)
    GC.gc()
    tmp = long_apply(na_interp_linear, tmp)    
    GC.gc()
    return tmp
end
"""
The PSTT2021 function performs all the steps of the new cleaning procedure described in [But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds, Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas](https://www.xkdr.org/releases/PatnaikShahTayalThomas_2021_bias_PSTT2021_nighttime_lights.html) as conventional cleaning.

It can optionally accept a pre-computed `noise` mask.

```julia
PSTT2021(radiance_datacube, ncfobs_datacube; noise=nothing, bgthreshold=0.4)
```
"""
function PSTT2021(radiance_datacube, ncfobs_datacube; noise = nothing, bgthreshold = 0.4)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    GC.gc()
    tmp = replace_negative(tmp)
    GC.gc()
    if isnothing(noise)
        noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, bgthreshold)
    end
    GC.gc()
    tmp = apply_mask(tmp, noise)
    GC.gc()
    
    # Default value for stable_pixels - will be overwritten if outlier_variance succeeds
    stable_pixels = ones(Int8, size(tmp)[1], size(tmp)[2])
    
    try
        stable_pixels = outlier_variance(tmp, noise)
        GC.gc()
    catch e
        @warn "outlier_variance failed, using all pixels as stable" exception=(e, catch_backtrace())
        # stable_pixels is already set to a default value above
    end
    tmp = apply_mask(tmp, stable_pixels)
    GC.gc()
    tmp = long_apply(outlier_hampel, tmp)
    GC.gc()
    mask = noise .* stable_pixels 
    GC.gc()
    tmp = bias_PSTT2021(tmp, ncfobs_datacube, mask)
    GC.gc()
    tmp = long_apply(na_interp_linear, tmp)    
    GC.gc()
    return tmp  
end


"""
The function `clean_complete()` represents our views on an optimal set of steps for pre-
processing in the future (for the period for which this package is actively maintained). As
of today, it is identical to `PSTT2021()`.

It can optionally accept a pre-computed `noise` mask.
"""
function clean_complete(radiance_datacube, ncfobs_datacube; noise = nothing, bgthreshold = 0.4)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    GC.gc()
    tmp = replace_negative(tmp)
    GC.gc()
    if isnothing(noise)
        noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, bgthreshold)
        GC.gc()
        tmp = apply_mask(tmp, noise)
        GC.gc()
    else
        tmp = apply_mask(tmp, noise)
        GC.gc()
    end
    mask = noise
    # Default value for stable_pixels - will be overwritten if outlier_variance succeeds    
    try
        stable_pixels = outlier_variance(tmp, noise)
        tmp = apply_mask(tmp, stable_pixels)
        GC.gc()
        mask = noise .* stable_pixels 
    catch e
        @warn "outlier_variance failed, using all pixels as stable" exception=(e, catch_backtrace())
        # stable_pixels is already set to a default value above
    end
    
    GC.gc()
    tmp = long_apply(outlier_hampel, tmp)    
    GC.gc()
    tmp = bias_PSTT2021(tmp, ncfobs_datacube, mask)
    GC.gc()
    if length(unique(tmp)) == 1 # If every value is missing. 
        tmp = Raster(zeros(size(tmp)), dims(radiance_datacube))
        return tmp
    end
    tmp = long_apply(na_interp_linear, tmp)    
    GC.gc()
    return tmp
end