"""
All steps of data cleaning that most researchers do can be performed using the conventional cleaning funciton.

# Example
```julia
PSTT2021_conventional(radiance_datacube, ncfobs_datacube)
```
"""
function PSTT2021_conventional(radiance_datacube, ncfobs_datacube)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    GC.gc()
    tmp =  replace_negative(tmp)
    GC.gc()
    noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, 0.4)
    GC.gc()
    tmp = apply_mask(tmp, noise)
    GC.gc()
    stable_pixels = outlier_variance(tmp, noise)
    GC.gc()
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

# Example
```julia
PSTT2021(radiance_datacube, ncfobs_datacube)
```
"""
function PSTT2021(radiance_datacube, ncfobs_datacube)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    GC.gc()
    tmp = replace_negative(tmp)
    GC.gc()
    noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, 0.4)
    GC.gc()
    tmp = apply_mask(tmp, noise)
    GC.gc()
    stable_pixels = outlier_variance(tmp, noise)
    GC.gc()
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
of today, it is identical to `PSTT2021()``
"""
function clean_complete(radiance_datacube, ncfobs_datacube; bgnoise_clean = true)
    tmp = na_recode(radiance_datacube, ncfobs_datacube)
    GC.gc()
    tmp = replace_negative(tmp)
    GC.gc()
    if bgnoise_clean == true
        noise = bgnoise_PSTT2021(tmp, ncfobs_datacube, 0.4)
        GC.gc()
        tmp = apply_mask(tmp, noise)
        GC.gc()
    else
        noise = ones(size(tmp)[1:2]...)
    end
    stable_pixels = outlier_variance(tmp)
    GC.gc()
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