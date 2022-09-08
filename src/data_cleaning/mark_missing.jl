"""
For each pixel, NOAA produces monthly estimates of radiance using the mean of radiance measured on days considered free of clouds. Radiance on months with no cloud-free observations are marked as zero, these should be marked as missing or or not available. The mark_missing function uses the radiance and the cloud-free observations image to marks missing wherever there no 0 cloud-free observations. 
```julia
radiance = rand(1:10.0, 10, 10)
cloud = rand(0:5, 10, 10)
mark_missing(radiance, cloud)
```
"""
function mark_missing_img(radiance, clouds)
    for i in 1:size(clouds)[1]
        for j in 1:size(clouds)[2]
            if clouds[i,j] == 0
                radiance[i,j]= missing
            end
        end
    end
    return radiance
end

"""
The mark_missing function also works on datacubes.  
```julia
radiance = rand(1:10.0, 10, 10, 10)
cloud = rand(0:5, 10, 10, 10)
mark_missing(radiance, cloud)
```
Wherever the number of cloud-free observations is 0, radiance will be marked as missing. 
"""
function mark_missing(radiance_datacube, clouds_datacube) 
    for i in 1:size(clouds_datacube)[4]
        radiance_datacube[:, :, 1, i] = mark_missing_img(radiance_datacube[:, :, 1, i], clouds_datacube[:, :, 1, i])
    end
    return radiance_datacube
end

function mark_missing_dc(radiance_datacube, clouds_datacube)
    