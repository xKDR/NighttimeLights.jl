"""
For each pixel, NOAA produces monthly estimates of radiance using the mean of radiance measured on days considered free of clouds. Radiance on months with no cloud-free observations are marked as zero, these should be marked as missing or or not available. The na_recode function uses the radiance and the cloud-free observations image to marks missing wherever there no 0 cloud-free observations. 
```julia
radiance = rand(1:10.0, 10, 10)
cloud = rand(0:5, 10, 10)
na_recode(radiance, cloud)
```
"""
function na_recode_img(radiance, clouds; replacement = missing)
    for i in 1:size(clouds)[1]
        for j in 1:size(clouds)[2]
            if clouds[i,j] == 0
                radiance[i,j] = replacement
            end
        end
    end
    return radiance
end

"""
The na_recode function also works on datacubes.  
```julia
radiance = rand(1:10.0, 10, 10, 10)
cloud = rand(0:5, 10, 10, 10)
na_recode(radiance, cloud)
```
Wherever the number of cloud-free observations is 0, radiance will be marked as missing. 
"""
function na_recode(radiance_datacube, clouds_datacube; replacement = missing) 
    print(1)
    radiance_datacube = rebuild(radiance_datacube; missingval = nothing)
    radiance_datacube = replace_missing(radiance_datacube, missing)
    for i in 1:size(radiance_datacube, 1)
        for j in 1:size(radiance_datacube, 2)
            for k in 1:size(radiance_datacube, 3)
                if clouds_datacube[i,j, k] == 0
                    radiance_datacube[i,j, k] = replacement
                end                
            end
        end
    end
    return radiance_datacube
end
    