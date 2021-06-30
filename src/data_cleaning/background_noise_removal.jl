function noise_threshold(x,th = 0.4)
    if x<=th
        return 0
    else
        return 1
    end
end
"""
Pixels with no economic activity may show some light due to background noise. These pixels could be in forests, oceans, deserts etc. The background_noise_mask function generates a background moise mask such that those pixels which are considered dark are marked as 0 and those considered lit are marked as 1. The function uses the datacubes of radiance and clouds to generate annual image of the last year the data. The function considers all the pixels below a provided threshold as dark and remaining to be lit. 
```julia

```
"""
function background_noise_mask(datacube=radiance_datacube, clouds=clouds_datacube, th=0.4)
    # This function may be obsolete because Payne Institute is providing annual images for each year. 
    last_year_rad      = datacube[:,:,(size(datacube)[3]-12):size(datacube)[3]]
    last_year_cloud   = clouds[:,:,(size(datacube)[3]-12):size(datacube)[3]]
    average_lastyear = copy(datacube[:,:,1])
    for i in 1:size(last_year_rad)[1]
        for j in 1:size(last_year_rad)[2]
            average_lastyear[i,j] = weighted_mean(last_year_rad[i,j,:],last_year_cloud[i,j,:])
        end
    end
    mask = noise_threshold.(average_lastyear,th)
    return mask
end
