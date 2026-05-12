"""
For each pixel, NOAA produces monthly estimates of radiance using the mean of radiance measured on days considered free of ncfobs. Radiance on months with no cloud-free observations are marked as zero, these should be marked as missing or or not available. The na_recode function uses the radiance and the cloud-free observations image to marks missing wherever there no 0 cloud-free observations.
```julia
na_recode(radiance_image, ncfobs_image)
```
"""
function na_recode_img(radiance_image, ncfobs_image; replacement = missing)
    radiance_image[ncfobs_image .== 0] .= replacement
    return radiance_image
end

"""
The na_recode function also works on datacubes.
```julia
na_recode(radiance_datacube, ncfobs_datacube)
```
Wherever the number of cloud-free observations is 0, radiance will be marked as missing.
"""
function na_recode(radiance_datacube, ncfobs_datacube; replacement = missing)
    radiance_datacube = rebuild(radiance_datacube; missingval = nothing)
    radiance_datacube = replace_missing(radiance_datacube, missing)
    radiance_datacube[ncfobs_datacube .== 0] .= replacement
    return radiance_datacube
end
