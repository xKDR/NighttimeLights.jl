"""
For each pixel, NOAA produces monthly estimates of radiance using the mean of radiance measured on days considered free of ncfobs. Radiance on months with no cloud-free observations are marked as zero, these should be marked as missing or or not available. The na_recode function uses the radiance and the cloud-free observations image to marks missing wherever there no 0 cloud-free observations. 
```julia
na_recode(radiance_image, ncfobs_image)
```
"""
function na_recode_img(radiance_image, ncfobs_image; replacement = missing)
    for i in 1:size(ncfobs_image)[1]
        for j in 1:size(ncfobs_image)[2]
            if ncfobs_image[i,j] == 0
                radiance_image[i,j] = replacement
            end
        end
    end
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
    for i in 1:size(radiance_datacube, 1)
        for j in 1:size(radiance_datacube, 2)
            for k in 1:size(radiance_datacube, 3)
                if ncfobs_datacube[i,j, k] == 0
                    radiance_datacube[i,j, k] = replacement
                end                
            end
        end
    end
    return radiance_datacube
end
    