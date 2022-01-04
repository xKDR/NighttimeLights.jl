"""
Function replaces the negative values in a datacube with missing. 
"""
function replace_negative(datacube)
    for i in 1:prod(size(datacube))
        if ismissing(datacube[i]) 
            continue
        elseif datacube[i] < 0
                datacube[i] = missing
        else
            continue
        end
    end
    return datacube
end
