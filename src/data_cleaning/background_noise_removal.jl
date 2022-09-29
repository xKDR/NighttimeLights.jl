function noise_threshold(x,th = 0.4)
    if x<=th
        return missing
    else
        return 1
    end
end
"""
Pixels with no economic activity may show some light due to background noise. These pixels could be in forests, oceans, deserts etc. The ```background_noise_mask``` function generates a background moise mask such that those pixels which are considered dark are marked as 0 and those considered lit are marked as 1. The function uses the datacubes of radiance and clouds to generate annual image of the last year the data. The function considers all the pixels below a provided threshold as dark and remaining to be lit. 
```julia
background_noise_mask(radiance_datacube, clouds_datacube)
```
"""
function background_noise_mask(radiance_datacube, clouds_datacube, th = 0.4)
    # This function may be obsolete because Payne Institute is providing annual images for each year. 
    r_dc = convert(Array{Union{Missing, Float16}}, view(radiance_datacube, Band(1)))
    cf_dc = convert(Array{UInt8, 3}, view(clouds_datacube, Band(1)))
    last_year_rad      = r_dc[:, :, (size(r_dc)[3]-11):size(r_dc)[3]]

    last_year_cloud   = cf_dc[:, :, (size(r_dc)[3]-11):size(r_dc)[3]]
    average_lastyear = copy(r_dc[:, :, 1])
    for i in 1:size(last_year_rad)[1]
        for j in 1:size(last_year_rad)[2]
            average_lastyear[i,j] = weighted_mean(last_year_rad[i, j, :], last_year_cloud[i, j, :])
        end
    end
    mask = noise_threshold.(average_lastyear, th)
    return Raster(mask, dims(radiance_datacube)[1:2])
end
