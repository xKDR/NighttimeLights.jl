"""
Function replaces the negative values in a datacube with missing. 
"""
function replace_negative(dc)
    datacube = convert(Array{Union{Missing, Float16}}, view(dc, Band(1)))
    for i in 1:prod(size(datacube))
        if ismissing(datacube[i]) 
            continue
        elseif datacube[i] < 0
                datacube[i] = missing
        else
            continue
        end
    end
    return Raster(add_dim(datacube), dims(dc))
end
