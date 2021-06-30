"""
For each pixe, NOAA produces monthly estimates of radiance using the mean of radiance measured on days considered free of clouds. Radiance on months with no cloud-free observations are marked as zero, these should be marked as missing or or not available. The mark_nan function uses the radiance and the cloud-free observations image to marks NaN (missing and NaN are used interchangeably in this package) wherever there no 0 cloud-free observations. 
```julia
radiance = rand(1:10.0, 10, 10)
cloud = rand(0:5, 10, 10)
mark_nan(radiance, cloud)
```
"""
function mark_nan(radiance::Array{T, 2}, clouds) where T <: Real
    for i in 1:size(clouds)[1]
        for j in 1:size(clouds)[2]
            if clouds[i,j] == 0
                radiance[i,j]=NaN
            end
        end
    end
    return radiance
end

"""
The mark_nan function also works on datacubes.  
```julia
radiance = rand(1:10.0, 10, 10, 10)
cloud = rand(0:5, 10, 10, 10)
mark_nan(radiance, cloud)
```
Wherever the number of cloud-free observations is 0, radiance will be marked as NaN. 
"""
function mark_nan(radiance_datacube::Array{T, 3}, clouds_datacube) where T <: Real 
    for i in 1:size(clouds_datacube)[3]
        radiance_datacube[:, :, i] = mark_nan(radiance_datacube[:, :, i], clouds_datacube[:, :, i])
    end
    return radiance_datacube
end