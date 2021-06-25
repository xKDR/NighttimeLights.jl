"""
Replaces a values with a provided replacement if the values is below a provided threshold. 
# Example: 
```
julia> threshold(3, 5, 9)
```
"""
function threshold(x,minrad=0,replacement=NaN)
    if x<=minrad
        return replacement
    else
        return x
    end
end

"""
Replaces all values of a datacube below a provided threshold with a provided replacement. 
# Example: 
```
julia> threshold(3, 5, 9)
```
"""

function threshold_datacube(datacube,minrad=0,replacement=NaN,mask=ones(Int8, (size(datacube)[1],size(datacube)[2])))
    cleaned_matrix = copy(datacube)
    for i in 1:size(cleaned_matrix)[1]
        for j in 1:size(cleaned_matrix)[2]
            for k in 1:size(cleaned_matrix)[3]
                if mask[i,j] == 1
                    cleaned_matrix[i,j,k] = threshold(cleaned_matrix[i,j,k],minrad,replacement)
                end
            end
        end
    end
    return cleaned_matrix
end

function noise_threshold(x,th = 0.4)
    if x<=th
        return 0
    else
        return 1
    end
end
"""
Generates a background noise mask for a datacube. The function first generates an annual image of the last 12 months of the data. Only pixel above a threshold in this image are considered lit. 
# Example: 
```
julia> load_shapefile("assets/mumbai_map/mumbai_districts.shp")
```
"""
function background_noise_mask(datacube=radiance_datacube, clouds=clouds_datacube, th=0.4)
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
