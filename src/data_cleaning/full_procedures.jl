"""
All steps of data cleaning that most researchers do can be performed using the conventional_cleaning funciton. It is described in [But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds, Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas](https://www.xkdr.org/releases/PatnaikShahTayalThomas_2021_bias_correction_nighttime_lights.html) as conventional cleaning.

# Example
```julia
radiance_datacube = rand(1:1000, 10, 10, 10)
clouds_datacube = rand(1:1000, 10, 10, 10)
conventional_cleaning(radiance_datacube, clouds_datacube)
```
"""
function conventional_cleaning(radiance_datacube, clouds_datacube)
    tmp = mark_missing(radiance_datacube, clouds_datacube)
    GC.gc()
    tmp =  replace_negative(tmp)
    GC.gc()
    noise = background_noise_mask(tmp, clouds_datacube, 0.4)
    GC.gc()
    tmp = apply_mask(tmp, noise)
    GC.gc()
    stable_pixels = outlier_mask(tmp, noise)
    GC.gc()
    tmp = apply_mask(tmp, stable_pixels)
    GC.gc()
    tmp = long_apply(outlier_ts, tmp)
    GC.gc()
    tmp = long_apply(linear_interpolation, tmp)    
    GC.gc()
    return Array{Float16}(tmp)
end
"""
The PatnaikSTT2021 function performs all the steps of the new cleaning procedure described in [But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds, Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas](https://www.xkdr.org/releases/PatnaikShahTayalThomas_2021_bias_correction_nighttime_lights.html) as conventional cleaning.

# Example
```julia
radiance_datacube = rand(1:1000, 10, 10, 10)
clouds_datacube = rand(1:1000, 10, 10, 10)
PatnaikSTT2021(radiance_datacube, clouds_datacube)
```
"""
function PatnaikSTT2021(radiance_datacube, clouds_datacube)
    tmp = mark_missing(radiance_datacube, clouds_datacube)
    GC.gc()
    tmp = replace_negative(tmp)
    GC.gc()
    noise = background_noise_mask(tmp, clouds_datacube, 0.4)
    GC.gc()
    tmp = apply_mask(tmp, noise)
    GC.gc()
    stable_pixels = outlier_mask(tmp, noise)
    GC.gc()
    tmp = apply_mask(tmp, stable_pixels)
    GC.gc()
    tmp = long_apply(outlier_ts, tmp)
    GC.gc()
    mask = noise .* stable_pixels 
    GC.gc()
    tmp = bias_correction(tmp, clouds_datacube, mask)
    GC.gc()
    tmp = long_apply(linear_interpolation, tmp)    
    GC.gc()
    return Array{Float16}(tmp)  
end
