function noise_threshold(x,th = 0.4)
    if x<=th
        return missing
    else
        return 1
    end
end
"""
Pixels with no economic activity may show some light due to background noise. These pixels could be in forests, oceans, deserts etc. The ```bgnoise_PSTT2021``` function generates a background moise mask such that those pixels which are considered dark are marked as 0 and those considered lit are marked as 1. The function uses the datacubes of radiance and clouds to generate annual image of the last year the data. The function considers all the pixels below a provided threshold as dark and remaining to be lit. 
```julia
bgnoise_PSTT2021(radiance_datacube, clouds_datacube)
```
"""
function bgnoise_PSTT2021(radiance_datacube, clouds_datacube, th = 0.4)
    last_year_rad = radiance_datacube[:, :, (size(radiance_datacube)[3]-11):size(radiance_datacube)[3]]
    last_year_cloud   = clouds_datacube[:, :, (size(clouds_datacube)[3]-11):size(clouds_datacube)[3]]
    average_lastyear = copy(radiance_datacube[:, :, 1])
    for i in 1:size(last_year_rad)[1]
        for j in 1:size(last_year_rad)[2]
            average_lastyear[i,j] = weighted_mean(last_year_rad[i, j, :], last_year_cloud[i, j, :])
        end
    end
    mask = noise_threshold.(average_lastyear, th)
    return Raster(Array(mask), dims(radiance_datacube)[1:2])
end
