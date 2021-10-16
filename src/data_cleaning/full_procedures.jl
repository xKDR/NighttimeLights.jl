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
    tmp = mark_nan(radiance_datacube, clouds_datacube)
    tmp = replace!(x -> x < 0 ? NaN : x, tmp) 
    noise = background_noise_mask(tmp, clouds_datacube, 0.4)
    tmp = apply_mask(tmp, noise)
    stable_pixels = outlier_mask(tmp, noise)
    tmp = apply_mask(tmp, stable_pixels)
    tmp = long_apply(outlier_ts, tmp)
    tmp = long_apply(linear_interpolation, tmp)    
    return tmp
end
"""
Using nighttime lights requires data cleaning. The PatnaikSTT2021 function performs all the steps of the new cleaning procedure described in [But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds, Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas](https://www.xkdr.org/releases/PatnaikShahTayalThomas_2021_bias_correction_nighttime_lights.html) as conventional cleaning.

# Example
```julia
radiance_datacube = rand(1:1000, 10, 10, 10)
clouds_datacube = rand(1:1000, 10, 10, 10)
PatnaikSTT2021(radiance_datacube, clouds_datacube)
```
"""
function PatnaikSTT2021(radiance_datacube, clouds_datacube)
    tmp = mark_nan(radiance_datacube, clouds_datacube)
    tmp = replace!(x -> x < 0 ? NaN : x, tmp) 
    noise = background_noise_mask(tmp, clouds_datacube, 0.4)
    tmp = apply_mask(tmp, noise)
    stable_pixels = outlier_mask(tmp, noise)
    tmp = apply_mask(tmp, stable_pixels)
    tmp = long_apply(outlier_ts, tmp)
    mask = noise .* stable_pixels 
    tmp = bias_correction(tmp, clouds_datacube, mask)
    tmp = long_apply(linear_interpolation, tmp)    
    return tmp  
end
