"""
Function replaces the negative values in a datacube with a user specified value. The replacement value defaults to `missing`. 
"""
function replace_negative(radiance_datacube; replacement = missing)
    for i in 1:prod(size(radiance_datacube))
        if ismissing(radiance_datacube[i]) 
            continue
        elseif radiance_datacube[i] < 0
                radiance_datacube[i] = replacement
        else
            continue
        end
    end
    return radiance_datacube
end
